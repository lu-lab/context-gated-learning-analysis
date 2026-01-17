%% base path for data on dropbox
basePath = "/Users/sihoonmoon/Library/CloudStorage/Dropbox-GaTech/" + ...
                "coe-hl94-personal/PEOPLE/COLLABORATORS/yun/Lu-Zhang lab share/" + ...
                "learning data/Imaging";

%% read in table with filepaths and metadata
metadata = readtable('20251224_metadata.csv');

%% Filter metadata to CSV files
xlsxMeta = metadata(metadata.FileType == ".xlsx", :);

%% pick path and filename to test
relPath = 'Buffer-buffer data/flp-3p+flp-7p+sro-1p+nmr-1p/Analysis/excel-reformat';
fileName = 'ZC4061_20240130_naive_buffer_buffer_worm1.xlsx';
%[statusMsg, formatChk] = check_csv(basePath, relPath, fileName)

%% Collect all sheetnames across all files
allFilepaths = {};
allFilenames = {};
allTabNames  = {};
allStimulus  = {};
allPromoter  = {};
allTraining  = {};

for i = 1:height(xlsxMeta)
    path2sheet = fullfile(basePath, xlsxMeta{i, 'RelativePath'}, xlsxMeta{i, 'Filename'});
    temp_tab_names = sheetnames(path2sheet);
    n_sheets = numel(temp_tab_names);

    allTabNames  = [allTabNames;  temp_tab_names(:)];
    allFilepaths = [allFilepaths; repmat(xlsxMeta{i, 'RelativePath'}, n_sheets, 1)];
    allFilenames = [allFilenames; repmat(xlsxMeta{i, 'Filename'}, n_sheets, 1)];
    allStimulus = [allStimulus; repmat(xlsxMeta{i, 'Stimulus'}, n_sheets, 1)];
    allPromoter = [allPromoter; repmat(xlsxMeta{i, 'Promoter'}, n_sheets, 1)];
    allTraining = [allTraining; repmat(xlsxMeta{i, 'Training'}, n_sheets, 1)];
end

n_tabs = numel(allTabNames);

%% Loop through sheets (parallelized)
% Preallocate outputs
n_filled     = zeros(n_tabs,1);
n_found      = nan(n_tabs,1);
n_indicated  = zeros(n_tabs,1);
matchesPattern = false(n_tabs,1);
prefix       = strings(n_tabs,1);
numbers      = cell(n_tabs,1);
nonNumPlanes = true(n_tabs,1); % tracks if non-numeric plane number accidentally entered
repeatNums  = true(n_tabs,1); % tracks if plane number is repeated

% Loop through sheets
tic
parfor i = 1:n_tabs
    name = allTabNames{i};
    % --- Step 1: Match prefix (starts with letter, up to 5 total chars) ---
    prefixMatch = regexp(name, '^([A-Za-z][A-Za-z0-9]{0,4})(?:-|$)', 'tokens', 'once');
    
    if isempty(prefixMatch)
        % No valid prefix -> not matching expected pattern
        matchesPattern(i) = false;
        prefix(i)         = "";
        numbers{i}        = [];
        repeatNums(i)     = false;
        nonNumPlanes(i)   = true;
    elseif length(prefixMatch{1}) > 5

    else
        % Valid prefix found
        matchesPattern(i) = true;
        prefix(i)         = prefixMatch{1};

        % --- Step 2: Check for trailing "-" after prefix ---
        rest = extractAfter(name, strlength(prefix(i)));

        if isempty(rest) || rest(1) ~= '-'
            % No dash -> treat as missing numeric part
            numbers{i}      = [];
            repeatNums(i)   = false;
            nonNumPlanes(i) = true;  % flag unusual case
        else
            % --- Step 3: Split numbers on "&" ---
            numStrs   = split(extractAfter(rest, 1), '&'); % skip leading "-"
            numVals   = str2double(numStrs);
            numbers{i}= numVals;

            % --- Step 4: Check for issues ---
            validNums       = numVals(~isnan(numVals));
            repeatNums(i)   = numel(unique(validNums)) < numel(validNums);
            nonNumPlanes(i) = any(isnan(numVals));
        end
    end

    % --- Count filled columns from row 2 ---
    try
        temp_row = readtable(fullfile(basePath, allFilepaths{i}, allFilenames{i}), ...
                             'Sheet', name, 'Range', 2:2);
        n_filled(i) = size(temp_row,2);
    catch
        n_filled(i) = NaN;
    end

    % --- Map filled columns to "found" counts ---
    switch n_filled(i)
        case 1
            n_found(i) = 0;
        case {12, 13, 15}
            n_found(i) = 1;
        case {25, 26, 27, 28, 31}
            n_found(i) = 2;
        case {38, 41, 44, 47}
            n_found(i) = 3;
        case {51, 56}
            n_found(i) = 4;
        case {64, 71}
            n_found(i) = 5;
        otherwise
            n_found(i) = NaN;
    end

    % --- Indicated number of groups from parsed numbers ---
    n_indicated(i) = numel(numbers{i});
end
toc

% Build output table
sheet_checks = table( ...
    string(allFilepaths), ...
    string(allFilenames), ...
    string(allTabNames), ...
    matchesPattern, prefix, numbers, ...
    nonNumPlanes, repeatNums, ...
    n_filled, n_found, n_indicated, ...
    'VariableNames', {'FilePath','FileName','SheetName', ...
                      'MatchesPattern','CellID','Plane', ...
                      'WeirdPlaneName', 'RepeatedPlane', ...
                      'NumFilledCols','NumFound','NumIndicated'});

%% Derive subsets
% split sheets that follow/don't follow expected name format
unexpected_sheets = sheet_checks(~sheet_checks.MatchesPattern,:);
expected_sheets   = sheet_checks(sheet_checks.MatchesPattern,:);

% look at sheets that match pattern, but have unexpected number of planes
unexpected_columns = expected_sheets(isnan(expected_sheets.NumFound),:);

% look at sheets that match pattern, but have weird plane name, repeated
% plane name, or mismatch between number of filled and found columns
mismatch_idx = expected_sheets.WeirdPlaneName | ...
               expected_sheets.RepeatedPlane | ...
               (expected_sheets.NumFound ~= expected_sheets.NumIndicated);
mismatch = expected_sheets(mismatch_idx,:);

%% Write outputs
outPrefix = '20251224_Excel_SheetchecksV3';
writetable(sheet_checks,        outPrefix + "_all_sheets.xlsx");
writetable(unexpected_sheets,   outPrefix + "_unexpected_sheets.xlsx");
writetable(mismatch,            outPrefix + "_sheets_to_rename.xlsx");
writetable(unexpected_columns,  outPrefix + "_unexpected_columns.xlsx");

%% Build output table for running data extraction
extractableXLSX = table( ...
    expected_sheets.FilePath, ...
    expected_sheets.FileName, ...
    expected_sheets.SheetName, ...
    string(allStimulus(sheet_checks.MatchesPattern)), ...
    string(allPromoter(sheet_checks.MatchesPattern)), ...
    string(allTraining(sheet_checks.MatchesPattern)), ...
    'VariableNames', {'RelPath', 'FileName', 'SheetName', ...
                      'Stimulus', 'Promoter', 'Training'});

%% filter out sheetnames that don't contain - (plane number not indicated)
% pretty sure these sheets are all empty, but double check that
PlaneIndicated = contains(string(expected_sheets.SheetName), '-');
extractableXLSX = extractableXLSX(PlaneIndicated, :);

%%
writetable(extractableXLSX, '20251224_xlsx_to_extract.csv');
test = readtable('20251224_xlsx_to_extract.csv', 'Delimiter',',');

isequaln(extractableXLSX, test)