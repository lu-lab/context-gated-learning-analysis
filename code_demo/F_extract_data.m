%% base path for data
clear
basePath = "DemoData/";

%convert relative to absolute base path
x = dir(basePath);
basePath = string(x(1).folder);

% add helper functions to path
addpath(genpath("helpers"))

%% read in table with filepaths and metadata
xlsxTbl = readtable('20251224_xlsx_to_extract.csv', 'Delimiter',',');
csvTbl = readtable('20251224_csv_to_extract.csv', 'Delimiter',',');

%% extract data from csv
n_csvs = height(csvTbl);
tmpResults = cell(n_csvs, 1);

tic
parfor i_csvFile = 1:n_csvs
    % read out data from csv file
    outTbl = read_csv_data(basePath, string(csvTbl{i_csvFile, 'RelPath'}), string(csvTbl{i_csvFile, 'FileName'}));
    
    % add stimulus, promoter, and training metadata
    tempStim = string(csvTbl{i_csvFile, 'Stimulus'});
    tempProm = string(csvTbl{i_csvFile, 'Promoter'});
    tempTrain = string(csvTbl{i_csvFile, 'Training'});
    
    outTbl.Stimulus = repmat(tempStim, [height(outTbl), 1]);
    outTbl.Promoter = repmat(tempProm, [height(outTbl), 1]);
    outTbl.Training = repmat(tempTrain, [height(outTbl), 1]);
    
    outTbl = movevars(outTbl, {'Stimulus', 'Promoter', 'Training'}, 'After', 'FileName');
    
    tmpResults{i_csvFile} = outTbl;
end

resultsCSV = vertcat(tmpResults{:});
toc

if ~isempty(resultsCSV)
    writetable(resultsCSV, '20251224_all_CSVtraces.csv')
else
    vTypes = {'string'  'string' 'string'  'string'  'string' 'string'  'string'  'string'  'string'  'double'};
    vNames = {'FilePath'  'FileName'  'Stimulus' 'Promoter' 'Training' 'FocalPlane'  'Position'  'NeuronID'  'SignalType'  'Data'};
    resultsCSV = table('Size', [0 10], 'VariableTypes', vTypes, 'VariableNames', vNames);
    writetable(resultsCSV, '20251224_all_CSVtraces.csv')
end

%% extract data from excel
n_xlsx = height(xlsxTbl);
tmpResults = cell(n_xlsx, 1);

tic
parfor i_xlsxFile = 1:n_xlsx
    % read out data from excel sheet
    relPath = string(xlsxTbl{i_xlsxFile, 'RelPath'});
    fileName = string(xlsxTbl{i_xlsxFile, 'FileName'});
    sheetName = string(xlsxTbl{i_xlsxFile, 'SheetName'});
    outTbl = read_excel_data(basePath, relPath, fileName, sheetName);
    
    % add stimulus, promoter, and training metadata
    tempStim = string(xlsxTbl{i_xlsxFile, 'Stimulus'});
    tempProm = string(xlsxTbl{i_xlsxFile, 'Promoter'});
    tempTrain = string(xlsxTbl{i_xlsxFile, 'Training'});
    
    outTbl.Stimulus = repmat(tempStim, [height(outTbl), 1]);
    outTbl.Promoter = repmat(tempProm, [height(outTbl), 1]);
    outTbl.Training = repmat(tempTrain, [height(outTbl), 1]);
    
    outTbl = movevars(outTbl, {'Stimulus', 'Promoter', 'Training'}, 'After', 'FileName');
    tmpResults{i_xlsxFile} = outTbl;
end
resultsXLSX = vertcat(tmpResults{:});
toc

writetable(resultsXLSX, '20251224_all_XLSXtraces.csv')

%% write stacked table
stacked = [resultsCSV; resultsXLSX];
writetable(stacked, '20251224_all_traces_stackCsvXlsx.csv');

% convert cell array to NaN padded matrix and save as .mat
% .csv will truncate data to length 12 (not full double precision of 17)
dataCell = stacked.Data;
maxLen = max(cellfun(@numel, dataCell));
M = cellfun(@(x) [x nan(1, maxLen - numel(x))], dataCell, 'UniformOutput', false);
M = vertcat(M{:});
FullPrecisionData = M;
save('20251224_all_traces_stackCsvXlsx_fullPrecision.mat', "FullPrecisionData");

%% read in saved table and check similarity of read-in
test = readtable('20251224_all_traces_stackCsvXlsx.csv', 'Delimiter',',');

% check for exact equality of metadata
metaSame = isequaln(stacked(:, 1:9), test(:, 1:9))

% check for exact equality of numerical data
dataSame = isequaln(M, test{:, 10:end}) 

% check for preserved pattern of missing values
missingFramesSame = isequal(isnan(M), isnan(test{:, 10:end}))

% check for presence/severity of rounding errors
maxDev = max(sum(M - test{:, 10:end}, 2, 'omitnan'))
meanDev = mean(sum(M - test{:, 10:end}, 2, 'omitnan'))
numDevs = sum(sum(M - test{:, 10:end}, 2, 'omitnan') ~= 0)
numTraces = height(test) 

%% re-run checks after replacing with full precision data
test = readtable('20251224_all_traces_stackCsvXlsx.csv', 'Delimiter',',');
load('20251224_all_traces_stackCsvXlsx_fullPrecision.mat');
test{:, 10:end} = FullPrecisionData;

% check for exact equality of metadata
metaSame = isequaln(stacked(:, 1:9), test(:, 1:9))

% check for exact equality of numerical data
dataSame = isequaln(M, test{:, 10:end}) 

% check for preserved pattern of missing values
missingFramesSame = isequal(isnan(M), isnan(test{:, 10:end}))

% check for presence/severity of rounding errors
maxDev = max(sum(M - test{:, 10:end}, 2, 'omitnan'))
meanDev = mean(sum(M - test{:, 10:end}, 2, 'omitnan'))
numDevs = sum(sum(M - test{:, 10:end}, 2, 'omitnan') ~= 0)
numTraces = height(test) 

%% write full precision table
allData = test;
save('20251224_all_traces_stackCsvXlsx_fullPrecision.mat', 'allData');

%% 

% %% check lengths of extracted data from XLSX
% vectorLengths = cellfun(@numel, resultsXLSX.Data);
% 
% %%
% oddLengths = resultsXLSX(vectorLengths ~= 451, :);
% oddLengths.nTimepoints = vectorLengths(vectorLengths ~= 451);
% 
% %% tabulate sheets with weird numbers of data
% % Preallocate a cell array to store info for "bad" sheets
% badPaths = strings(n_xlsx, 1);
% badFiles = strings(n_xlsx, 1);
% badSheets = strings(n_xlsx, 1);
% maxLengths = zeros(n_xlsx, 1);
% badIdx = false(n_xlsx,1);     % track which entries are bad
% 
% tic
% parfor i_xlsxFile = 1:n_xlsx
%     % Read out data from excel sheet
%     relPath   = string(xlsxTbl{i_xlsxFile, 'RelPath'});
%     fileName  = string(xlsxTbl{i_xlsxFile, 'FileName'});
%     sheetName = string(xlsxTbl{i_xlsxFile, 'SheetName'});
%     
%     outTbl = read_excel_data(basePath, relPath, fileName, sheetName);
%     
%     % Check vector lengths (assuming Data column contains vectors)
%     expectedLength = 451;
%     vecLengths = cellfun(@numel, outTbl.Data);
%     maxLength = max(vecLengths);
%     
%     if any(vecLengths ~= expectedLength)
%         badPaths(i_xlsxFile) = relPath;
%         badFiles(i_xlsxFile) = fileName;
%         badSheets(i_xlsxFile) = sheetName;
%         maxLengths(i_xlsxFile) = maxLength;
%         badIdx(i_xlsxFile) = true;
%     end
% end
% toc
% 
% % Concatenate only the "bad" entries
% badSheetsTbl = table(badPaths, badFiles, badSheets, maxLengths, ...
%     'VariableNames', {'RelPath','FileName','SheetName','MaxLength'});
% badSheetsTbl = badSheetsTbl(badIdx, :);
% 
% %%
% writetable(badSheetsTbl, '20251224_excel_sheets_with_weird_row_numbers.xlsx');
