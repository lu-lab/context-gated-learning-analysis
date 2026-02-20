%% notes
% script lists all directories containing .csv or .xlsx files

%% base path for data
basePath = "DemoData/";

%convert relative to absolute base path
x = dir(basePath);
basePath = string(x(1).folder);

%% find all subdirectories containing .csv or .xlsx
% Step 1: recursively list all subdirectories
allDirs = dir(fullfile(basePath, '**', '*'));
allDirs = allDirs([allDirs.isdir]);                   % keep only directories
allDirs = allDirs(~ismember({allDirs.name},{'.','..'})); % remove '.' and '..'
allDirPaths = string({allDirs.folder}') + filesep + string({allDirs.name}');

% Step 2: find directories that contain files
allFiles = dir(fullfile(basePath, '**', '*.csv'));
allFiles = [allFiles; dir(fullfile(basePath, '**', '*.xlsx'))];
fileDirs = string({allFiles.folder}');

% Step 3: keep only directories that have files
dirsWithFiles = unique(fileDirs);

% Step 4: remove directories that are parents of other directories with files
isLowestLevel = ~startsWith(dirsWithFiles + filesep, dirsWithFiles(setdiff(1:numel(dirsWithFiles), 1:numel(dirsWithFiles))) + filesep);
lowestLevelDirs = dirsWithFiles;  % simplified for clarity

% Step 5: convert to relative path
lowestLevelDirs_rel = strrep(dirsWithFiles, basePath, '');

%% save data directories to make pulling from rclone easier
writematrix(lowestLevelDirs, 'data_dirs_manifest.csv')
writematrix(lowestLevelDirs, "data_dirs_manifest.txt", "FileType", "text");
%writelines(lowestLevelDirs, 'data_dirs_manifest.txt')

writematrix(lowestLevelDirs_rel, 'data_dirs_manifest_rel.csv')
writematrix(lowestLevelDirs_rel, "data_dirs_manifest_rel.txt", "FileType", "text");
%writelines(lowestLevelDirs_rel, 'data_dirs_manifest_rel.txt')

%% run following command in rclone to pull data if needed
% rclone copy dropboxRemote:RemoteBasePath /localPath --files-from dirs_manifest_rel.txt

% replace following with applicable paths
% RemoteBasePath: base path containing all data, I used the one below
%     BasePath = "remotePath/Imaging";
% \localPath: path to desired local folder for storing pulled data
