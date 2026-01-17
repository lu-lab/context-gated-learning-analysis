%% base path for data on dropbox
basePath = "/Users/sihoonmoon/Library/CloudStorage/Dropbox-GaTech/" + ...
                "coe-hl94-personal/PEOPLE/COLLABORATORS/yun/Lu-Zhang lab share/" + ...
                "learning data/Imaging";

%% read in table with filepaths and metadata
metadata = readtable('20251224_metadata.csv');

%% pick path and filename to test
relPath = 'OP-gacA/Analysis/Analysis summary/Naive';
fileName = 'raw_results_ncs-1p_20240521-naive-OP_gacA_OP-worm001.csv';
%[statusMsg, formatChk] = check_csv(basePath, relPath, fileName)
%raw = readcell(fullfile(basePath, relPath, fileName), 'Delimiter', ',');

%% loop through csv files
% 1. Filter metadata to CSV files
csvMeta = metadata(metadata.FileType == ".csv", :);

% 2. Pre-allocate columns for results
nFiles = height(csvMeta);
statusMsg = strings(nFiles,1);
formatChk = true(nFiles,1);

% 3. Loop through CSV entries
tic
parfor k = 1:nFiles
    [statusMsg(k), formatChk(k)] = check_csv(...
        basePath, csvMeta.RelativePath{k}, csvMeta.Filename{k});
end
toc

% 4. Append results to metadata table
csvMeta.StatusMsg  = statusMsg;
csvMeta.FormatChk  = formatChk;

% 5. Filter rows that pass the checks
csvMetaValid = csvMeta(csvMeta.FormatChk, :);
csvMetaFailed = csvMeta(~csvMeta.FormatChk, :);

%% write failed data to table
writetable(csvMetaFailed, '20251224_weird_csv_files.xlsx');

%% build output table for running data extraction
extractableCsv = table( ...
    csvMetaValid.FileType, ...
    csvMetaValid.RelativePath, ...
    csvMetaValid.Filename, ...
    csvMetaValid.Stimulus, ...
    csvMetaValid.Promoter, ...
    csvMetaValid.Training, ...
    'VariableNames', {'FileType', 'RelPath', 'FileName', ...
                      'Stimulus', 'Promoter', 'Training'});

%%
writetable(extractableCsv, '20251224_csv_to_extract.csv');
test = readtable('20251224_csv_to_extract.csv');

isequaln(extractableCsv, test)
%%
function [statusMsg, formatChk] = check_csv(basePath, relPath, fileName)
%   Stops at the first failed check and returns a message.

    % --- Read in data ---
    raw = readcell(fullfile(basePath, relPath, fileName), 'Delimiter', ',');
    [nRows, nCols] = size(raw);

    % --- Define blank detection function ---
    isBlank = @(x) ...
        isempty(x) || ...
        ismissing(string(x)) || ...
        (isstring(x) && strlength(x)==0) || ...
        (ischar(x) && all(isspace(x)));

    blankMask = cellfun(isBlank, raw);
    blankCols = all(blankMask, 1);
    nBlanks = sum(blankCols);
    nPages  = (nBlanks / 2) + 1;  % expected number of column groups

    % --- Sequential validation checks (grouped for clarity) ---
    checks = {
        nRows < 452, ...           % check for expected number of rows (timepoints)
        mod(nBlanks, 2) ~= 0, ...   % check for even number of blank columns (spacers between planes)
        mod(nCols - nBlanks - nPages, 4) ~= 0 % check that number of filled columns 
    };

    messages = [
        "Fewer than 452 rows, some timepoints might be missing";
        "Uneven number of blank columns, planes might not be separated properly";
        "Unexpected number of filled columns, might be missing GCaMP/mCherry or ROI/bkgrd for some neurons"
    ];

    % --- Run checks in order, stop on first failure ---
    for k = 1:numel(checks)
        if checks{k}
            statusMsg = messages(k);
            formatChk = false;
            return
        end
    end

    % --- All checks passed ---
    statusMsg = "Format matches assumptions, file seems ready to process";
    formatChk = true;
end
