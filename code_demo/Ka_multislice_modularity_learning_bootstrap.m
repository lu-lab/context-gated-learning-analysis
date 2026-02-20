%% Load tabulated matlab data
% The extracted dataset is stored in a long-form table with the following columns:
%
%   FilePath   - Relative path to the source file
%   FileName   - Name of the source file, each file corresponds to individual worm
%   Stimulus   - Stimulus condition
%       possible values: 
%       "Buffer-buffer data", "Decorrelation_validation", "OP-PA", "OP-buffer-OP", "OP-gacA", "PA-buffer"
%   Promoter   - Multi-cell strain/promoter used
%       Possible values: 
%       "ZC4251", "ZC4255", "acr-5p", "flp-3p+flp-7p+nmr-1p+sro-1p", "flp-3p+flp-7p+sro-1p+nmr-1p", 
%       "glr-1p", "inx-4+mbr-1p", "inx-4p", "inx-4p+mbr-1p", "ncs-1p", "odr-2(2b)+odr-2(18)p"
%   Training   - Training condition, possible values: "naive", "trained"
%   FocalPlane - Focal plane of trace, needed for calculating correlations between co-recorded neurons
%       Possible values: FP1, FP2, FP3, FP4, FP5 
%   Position   - Useful for separating traces when same NeuronID occurs twice in same FocalPlane 
%       Example usage:
%           Drop L/R, but have both AVFL/R in FP2 
%           Worm will have two traces for AVF-FP2, 
%           But one will be AVF-FP2-A1 and other will be AVF-FP2-A2  
%   NeuronID   - Neuron ID of recorded cell, some are labeled L/R and
%   others don't have L/R information. 
%       Run unique(string(dRRoTable.NeuronID)) to see possible values, most
%       neurons will have 3 values (Base + BaseL + BaseR, e.g. ADA + ADAL +
%       ADAR)
%
%   Data_1 ... Data_451 - Numerical columns corresponding to dRRo for different timepoints
%                         (e.g., Data_1 = timepoint 1, Data_2 = timepoint 2, etc.).
%
% Notes:
% - Numerical data vectors are expected to be length 451 (tolerating 450 in some cases).
% - Table can be exported to CSV for use in external programs or re-import into MATLAB.
% - Composite keys may be constructed from FilePath, FileName, and selected Metadata
%   fields to ensure unique identification of each row.

addpath(genpath('helpers'));
%load('20250918_dRRo_101to150base.mat', 'dRRoTable');
load('20251224_dRRo_101to150base.mat', 'dRRoTable');
full_data = dRRoTable;

%% standardize promoter names
full_data.Promoter(string(full_data.Promoter) == "flp-3p+flp-7p+sro-1p+nmr-1p") = {"flp-3p+flp-7p+nmr-1p+sro-1p"};
full_data.Promoter(string(full_data.Promoter) == "inx-4+mbr-1p") = {"inx-4p+mbr-1p"};

%% rename table variables for compatibility with legacy code
currNames   = ["Promoter", "Stimulus", "Training", "NeuronID", "FileName", "FocalPlane"];
legacyNames = ["promoter", "stimulus", "training_status", "ID", "filenames", "plane"];

full_data = renamevars(full_data, currNames, legacyNames);

%% setup table of conditions to test
% get unique stimulus promoter combos
unique_stim_promCombos = unique(join(string(full_data{:, ["stimulus", "promoter"]}), '/', 2));
nRows = length(unique_stim_promCombos);

% initialize table
varNames  = ["promoter", "stimulus", "window", "slide", "omega", "nBoots"];
paramsTbl = table('Size', [nRows, numel(varNames)], ...
    'VariableTypes', ["string", "string", "double", "double", "double", "double"], ...
    'VariableNames', varNames);

% split stimulus prom combos to populate table
unique_stim_promCombos = split(unique_stim_promCombos, '/');
paramsTbl.stimulus = unique_stim_promCombos(:, 1);
paramsTbl.promoter = unique_stim_promCombos(:, 2);

% populate table with other params (modify if different values desired for
% diff conditions)
window = 100;
slide = 10;
nBoots = 10;

paramsTbl.window = window * ones(nRows, 1);
paramsTbl.slide  = slide  * ones(nRows, 1);
paramsTbl.nBoots = nBoots * ones(nRows, 1);

%% set individual omega values for each promoter
paramsTbl.omega  = NaN(nRows, 1);
% paramsTbl.omega(paramsTbl.promoter == "ncs-1p") = 0.4;
% paramsTbl.omega(paramsTbl.promoter == "ZC4251") = 0.4;
% paramsTbl.omega(paramsTbl.promoter == "ZC4255") = 0.4;
% paramsTbl.omega(paramsTbl.promoter == "acr-5p") = 0.4;
% paramsTbl.omega(paramsTbl.promoter == "glr-1p") = 0.4;
% paramsTbl.omega(paramsTbl.promoter == "inx-4p") = 0.4;
% paramsTbl.omega(paramsTbl.promoter == "inx-4p+mbr-1p") = 0.4;
% paramsTbl.omega(paramsTbl.promoter == "odr-2(2b)+odr-2(18)p") = 0.4;
% paramsTbl.omega(paramsTbl.promoter == "flp-3p+flp-7p+nmr-1p+sro-1p") = 0.4;
paramsTbl.omega(paramsTbl.promoter == "demo-1p") = 0.4;

%%% sort params table based on priority of running
priority = zeros(nRows, 1);

% priority 1: run ncs-1p, acr-5p x OP-PA, PA-buffer first  
rule1 = ismember(paramsTbl.promoter, ["ncs-1p","acr-5p"]) & ismember(paramsTbl.stimulus, ["OP-PA","PA-buffer"]);
priority(rule1) = 1;

% priority 2: run all other stimulus conditons for ncs-1p and acr-5p
rule2 = ismember(paramsTbl.promoter, ["ncs-1p","acr-5p"]) & ~rule1;
priority(rule2) = 2;

% priority 3: run OP-PA and PA-buffer for all other promoters
rule3 = ismember(paramsTbl.stimulus, ["OP-PA","PA-buffer"]) & ~rule1 & ~rule2;
priority(rule3) = 3;

% priority 4: run everything else
priority(priority==0) = 4;

% sort table based on priority
paramsTbl.priority = priority;
paramsTbl = sortrows(paramsTbl, 'priority');

%% loop through paramsTbl and run modularity analysis
runtimes = zeros(nRows, 1);

for r = 1:nRows
    tic
    save_bootstrapped_modularity_results(full_data, ...
        paramsTbl.promoter(r), ...
        paramsTbl.stimulus(r), ...
        paramsTbl.window(r), ...
        paramsTbl.slide(r), ...
        paramsTbl.omega(r),...
        paramsTbl.nBoots(r))
    runtimes(r) = toc;
end
