%% base path for data on dropbox
basePath = "/Users/sihoonmoon/Library/CloudStorage/Dropbox-GaTech/" + ...
                "coe-hl94-personal/PEOPLE/COLLABORATORS/yun/Lu-Zhang lab share/" + ...
                "learning data/Imaging";

%% load in table of csv files and relative paths
uniqueFiles = readtable('20251224_unique_files_preferCSV.csv');

%% get training status
% first try getting training status from file path
training = regexpi(string([uniqueFiles.RelativePath]), '(naive|trained|train|niave)', 'match');

% if training status is missing from filepath, check file name
missing_idx = cellfun(@isempty, training);
training(missing_idx) = regexpi(string(uniqueFiles{missing_idx, 'Filename'}), '(naive|trained|train|niave)', 'match');

% convert to string
% missing entries will prevent successful conversion to string
training = string(training);

% convert to lowercase and fix typos
training = regexprep(training, '(?i)(naive|niave)', 'naive');
training = regexprep(training, '(?i)(trained|train)', 'trained');

% add to table
uniqueFiles.Training = training;
%sum(isempty(training))
%% get stimulus condition (first folder in relative filepath
all_paths = string([uniqueFiles.RelativePath]);
stimulus = regexp(all_paths, '^[^\\/]+/', 'match');

% convert to string and remove training slash
stimulus = string(stimulus);
stimulus = strrep(stimulus, '/', '');

% add to table
uniqueFiles.Stimulus = stimulus;

%% get promoter
%%% initial search for promoter
all_paths = string([uniqueFiles.RelativePath]);
promoters = regexp(all_paths, '[^/]+-\d+(\(\d+\))?p', 'match');

% get strain name instead of promoter for decorrelation validation data
isDecorr = stimulus == "Decorrelation_validation";
promoters(isDecorr) = regexp(all_paths(isDecorr), '(?<=/)(ZC\d{4})(?=/)', 'match');

% add promoter data for OP-buffer-OP and OP-gacA conditions (always ncs-1p)
idx = stimulus == "OP-buffer-OP";
promoters(idx) = {"ncs-1p"};

idx = stimulus == "OP-gacA";
promoters(idx) = {"ncs-1p"};

% convert to string and add to table
promoters = string(promoters);
uniqueFiles.Promoter = promoters;

%% save metadata file and test that it loads back in properly
writetable(uniqueFiles, '20251224_metadata.csv')
test = readtable('20251224_metadata.csv');

isequaln(uniqueFiles, test)