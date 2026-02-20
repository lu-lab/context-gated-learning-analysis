function outTbl = read_excel_data(basePath, relPath, fileName, sheetName)
%READ_EXCEL_DATA Extracts longform data from a single Excel sheet
%
% Returns table with columns:
%   RelPath, FileName, GroupNum, Prefix, Suffix, Data

    % ---- Setup output schema ----
    outTbl = table('Size',[0 7], ...
        'VariableTypes', {'string',  'string',  'double',    'string',  'string',  'string',    'cell'}, ...
        'VariableNames', {'FilePath','FileName','FocalPlane','Position','NeuronID','SignalType','Data'});

    % ---- Read the sheet ----
    filePath = fullfile(basePath, relPath, fileName);
    raw = readcell(filePath, "Sheet", sheetName);  % cell array

    % Parse sheet name to get neuron ID and focalPlanes
    NeuronID = extractBefore(sheetName,"-");
    FcPlanes = split(extractAfter(sheetName,"-"), '&');
    FcPlanes = str2double(FcPlanes);

    % ---- Detect blank columns ----
    isBlank = @(x) isempty(x) || ismissing(string(x)) || ...
                    (isstring(x) && strlength(x)==0) || ...
                    (ischar(x) && all(isspace(x)));
    
    blankCols = all(cellfun(isBlank, raw), 1);

    % Detect Focal Planes via transitions in blankCols
    isData = ~blankCols;
    d = diff([0 isData 0]);             % pad with 0s to detect edges
    groupStartIdx = find(d == 1);       % rising edge = start
    nGroups = numel(groupStartIdx);

    %% loop through focal planes to get data
    for g = 1:nGroups
        % Extract data from columns of interest
        cols = groupStartIdx(g) + [2 3 6 7] - 1;
        
        % swap missing values with NaN and convert to matrix
        rawData = raw(2:end, cols);
        isMissing = cellfun(@ismissing, rawData);   % logical mask
        rawData(isMissing) = {NaN};                 % replace missing with NaN
        dataBlock = cell2mat(rawData); % 451 x 4

        % Fill in information about FilePath, FileName, FocalPlane,
        % NeuronID, SignalType
        groupTbl = table(...'VariableNames',NeuronID ...
            repmat(string(relPath), 4, 1), ...
            repmat(string(fileName), 4, 1), ...
            repmat("FP" + FcPlanes(g), 4, 1), ...
            repmat("A" + g, 4, 1),...
            repmat(NeuronID, 4, 1), ...
            ["_gcamp"; "-bg_gcamp"; "_mcherry"; "-bg_mcherry"], ...
            num2cell(dataBlock', 2));

        groupTbl.Properties.VariableNames = {...
            'FilePath', 'FileName','FocalPlane','Position'...
            'NeuronID','SignalType','Data'};
        % Build Temp Table and Append to full table

        outTbl = [outTbl; groupTbl];
    end
end