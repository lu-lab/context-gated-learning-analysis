%% base path for data
clear
basePath = "DemoData/";

%convert relative to absolute base path
x = dir(basePath);
basePath = string(x(1).folder);

%% recursive search for csv and xlsx files
csvDir = dir(fullfile(basePath, '**', '*.csv'));
xlsxDir = dir(fullfile(basePath, '**', '*.xlsx'));

%% tabulate  filenames, relative paths, and file types
% Combine CSV and XLSX files
allFiles = [csvDir; xlsxDir];

% Convert fields to string arrays
fileNames = string({allFiles.name});
folders   = string({allFiles.folder});

% Compute relative paths
relPaths = strrep(folders, basePath, '');
relPaths = regexprep(relPaths, ['^' filesep], ''); % remove leading slash

% File extensions
[~,~,fileTypes] = cellfun(@fileparts, {allFiles.name}, 'UniformOutput', false);
fileTypes = string(fileTypes);

% Build table
fileTable = table(fileNames', relPaths', fileTypes', ...
                  'VariableNames', {'Filename','RelativePath','FileType'});

% Display first few rows
disp(fileTable(1:min(10,height(fileTable)), :))

%% check for redundancies and tabulate
% Step 1: compute basenames
[baseNames, ~] = strtok(fileTable.Filename, '.'); % removes extension
fileTable.BaseName = baseNames;

% Step 2: identify basenames with both csv and xlsx
basenamesCSV   = unique(fileTable.BaseName(fileTable.FileType==".csv"));
basenamesXLSX  = unique(fileTable.BaseName(fileTable.FileType==".xlsx"));
redundantBase  = intersect(basenamesCSV, basenamesXLSX); % basenames that appear in both

% Step 3: create table of redundant files
isRedundant = ismember(fileTable.BaseName, redundantBase);
redundantFiles = fileTable(isRedundant, :);

% Step 4: create table of unique files, keeping csv if redundant
% For redundant files, prefer csv
keepCSV = (fileTable.FileType==".csv" & isRedundant);
keepNonRedundant = ~isRedundant;
uniqueFiles = fileTable(keepCSV | keepNonRedundant, :);

%% save resulting tables
writetable(redundantFiles, '20251224_redundant_files.csv');
writetable(uniqueFiles, '20251224_unique_files_preferCSV.csv');

%% test that unique file table can be read back in properly
test = readtable('20251224_unique_files_preferCSV.csv');