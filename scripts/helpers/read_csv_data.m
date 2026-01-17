function outTbl = read_csv_data(basePath, relPath, fileName)
%READ_CSV_DATA Extracts normalized data + metadata from validated CSV
%
% Output table columns:
%   FilePath  - relative path
%   FileName  - filename only
%   GroupNum  - group number (row 1, col 1 of group)
%   Prefix    - parsed prefix from header
%   Suffix    - parsed suffix (-bg_c1, -c1, -bg_C2, -C2)
%   Data      - numeric vector (length = 451)

%% Read CSV file
fpath = fullfile(basePath, relPath, fileName);
raw = readcell(fpath, 'Delimiter', ',');
[nRows, nCols] = size(raw);

%% Detect blank columns
isBlank = @(x) isempty(x) || ismissing(string(x)) || ...
                (isstring(x) && strlength(x)==0) || ...
                (ischar(x) && all(isspace(x)));

blankCols = all(cellfun(isBlank, raw), 1);

%% Detect groups via transitions in blankCols
isData = ~blankCols;
d = diff([0 isData 0]);             % pad with 0s to detect edges
groupStartIdx = find(d == 1);       % rising edge = start
groupEndIdx   = find(d == -1) - 1;  % falling edge = end
nGroups = numel(groupStartIdx);

%% Preallocate results table
results = table('Size',[0 7], ...
    'VariableTypes', {'string',  'string',  'double',    'string',  'string',  'string',    'cell'}, ...
    'VariableNames', {'FilePath','FileName','FocalPlane','Position','NeuronID','SignalType','Data'});

%% Process each group
for g = 1:nGroups
    cols = groupStartIdx(g):groupEndIdx(g);

    % Group number (row 1, first col)
    groupNum = raw{1, cols(1)};

    % Header row (row 2, exclude first col)
    headerRow = string(raw(2, cols(2:end)))';  % nColsGroup x 1
    
    % Parse header row to figure out NeuronIDs and signalType
    expr = '^(?<prefix>[A-Za-z][A-Za-z0-9]{1,4})(?<modifier>-bg)?_(?<suffix>gcamp|mcherry)$';
    tokens = regexp(headerRow, expr, 'names');
    
    neuronIDs  = string(cellfun(@(x) x.prefix,  tokens, 'UniformOutput', false));
    modifiers = string(cellfun(@(x) x.modifier, tokens, 'UniformOutput', false));
    suffixes  = string(cellfun(@(x) x.suffix,  tokens, 'UniformOutput', false));
    signalType = modifiers + "_" + suffixes;

    % Numeric data (rows 3:end)
    rawData = raw(3:end, cols(2:end));
    isMissing = cellfun(@ismissing, rawData);   % logical mask
    rawData(isMissing) = {NaN};                 % replace missing with NaN
    dataBlock = cell2mat(rawData); % 451 x nColsGroup

    % Build table for this group
    nColsGroup = numel(headerRow);
    groupTbl = table( ...
        repmat(string(relPath), nColsGroup, 1), ...
        repmat(string(fileName), nColsGroup, 1), ...
        repmat(groupNum, nColsGroup, 1), ...
        repmat("A" + g, nColsGroup, 1),...
        neuronIDs, ...
        signalType, ...
        num2cell(dataBlock', 2));  % transpose numeric data to make each column = one row

    groupTbl.Properties.VariableNames = {'FilePath','FileName','FocalPlane','Position', 'NeuronID','SignalType','Data'};

    % Append to results
    results = [results; groupTbl];
end

outTbl = results;
end