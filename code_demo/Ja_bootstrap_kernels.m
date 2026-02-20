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
clear
%load('20250918_dRRo_101to150base.mat', 'dRRoTable');
load('20251224_dRRo_101to150base.mat', 'dRRoTable');
addpath(genpath('helpers'));

%% define list of target input/output neurons
% PA-OP key neurons
% keySensory = ["ASEL", "AWA", "OLL", "ADF", "FLP", "URYD", "ASI"];
% keyInter = ["RIG", "RIM", "AVE", "AVA", "ALA", "ADA"];
% keyMotor = ["RMDV"];

% % PA-Buffer key neurons
% keySensory = ["OLL", "FLP"];
% keyInter = ["AVA", "RIG", "IL1"];
% keyMotor = ["SMDD"];

% example neurons for demo
keySensory = ["ASEL", "AWA", "OLL", "ADF", "ASI"];
keyInter = [];
keyMotor = keySensory; % these are actually sensory, for demo purposes only

keySensory = sort(keySensory);
keyInter = sort(keyInter);
keyMotor = sort(keyMotor);

% --- Parameters for running bootstrapping later ---
nBootstrap = 30;       % number of Monte Carlo iterations (30 - 100 for testing, 1-2k for statistics)
kernelLength = 150;     % length of kernel (number of timepoints)
inputIDs = [keySensory, keyInter]; % define IDs to fit kernels between
outputIDs = [keyInter, keyMotor]; 

%% run kernel fitting for desired stimulus condition
% filter data down to desired stimulus condition and separate Naive and Trained
targetStim = "stimulus1";
targetData = dRRoTable(string(dRRoTable.Stimulus) == targetStim  , :);

% fold L/R neuron IDs
targetData.NeuronID = foldIDs(targetData.NeuronID);
 
% run kernel fitting between bootstrapped input/output traces
tic
results = fit_bootstrapped_kernels(targetData, nBootstrap, kernelLength, inputIDs, outputIDs);
toc

% save results
save(targetStim + "_nBoot" + num2str(nBootstrap) + "_kernelResults.mat", "results", "targetStim", "keySensory", "keyMotor", "keyInter", "targetData", "-v7.3");

%% run kernel fitting for desired stimulus condition
% filter data down to desired stimulus condition and separate Naive and Trained
targetStim = "stimulus2";
targetData = dRRoTable(string(dRRoTable.Stimulus) == targetStim  , :);

% fold L/R neuron IDs
targetData.NeuronID = foldIDs(targetData.NeuronID);
 
% run kernel fitting between bootstrapped input/output traces
tic
results = fit_bootstrapped_kernels(targetData, nBootstrap, kernelLength, inputIDs, outputIDs);
toc

% save results
save(targetStim + "_nBoot" + num2str(nBootstrap) + "_kernelResults.mat", "results", "targetStim", "keySensory", "keyMotor", "keyInter", "targetData", "-v7.3");

%%
function results = fit_bootstrapped_kernels(targetData, nBootstrap, kernelLength, inputIDs, outputIDs)
% function runs kernel fitting between bootstrapped input/output traces
% 
% --- example inputs ---
% nBootstrap = 30;       % number of bootstraps (30 - 100 for testing, 1-2k for statistics)
% kernelLength = 150;     % length of kernel (number of timepoints)
% inputIDs = [keySensory, keyInter]; % define IDs to fit kernels between
% outputIDs = [keyInter, keyMotor]; 
%
% --- fields of output results structure ---
% results.inputID = inID;
% results.outputID = outID;
% results.Training = (naive or trained)
% results.nBootstrap = (number of bootstraps)
% results.kernels = (fitted kernels, stored as time x bootstraps)
% results.inputs = (input traces for fit validation, stored as time x bootstraps);
% results.outputs = (output traces for fit validation, stored as time x bootstraps);
% results.varExp = (variance explained for each fitted kernel)

% --- Preallocate results struct ---
results = struct();
resultCounter = 1;

% --- Loop over input IDs ---
for i_in = 1:numel(inputIDs)
    inID = inputIDs(i_in);
    
    % Subset targetData for this input ID
    idx_in = strcmp(targetData.NeuronID, inID);
    X_trials = targetData{idx_in, end-450:end}; % assuming last 451 cols are timepoints
    X_training = string(targetData.Training(idx_in));
    
    % Loop over output IDs
    for i_out = 1:numel(outputIDs)
        outID = outputIDs(i_out);
        if strcmp(outID, inID)
            continue
        end
        idx_out = strcmp(targetData.NeuronID, outID);
        Y_trials = targetData{idx_out, end-450:end};
        Y_training = string(targetData.Training(idx_out));
        
        % Determine unique training conditions shared by in/out
        trainingConditions = intersect(unique(X_training), unique(Y_training));
        
        for t = 1:numel(trainingConditions)
            cond = trainingConditions(t);
            
            % Select trials of this training condition
            X_sel = X_trials(X_training==cond, :);
            Y_sel = Y_trials(Y_training==cond, :);
            
            nX = size(X_sel,1);
            nY = size(Y_sel,1);
            
            % Monte Carlo iterations
            bootKernels   = nan(kernelLength, nBootstrap);
            bootInputs   = nan(451, nBootstrap);
            bootOuputs   = nan(451, nBootstrap);
            bootvarExp    = nan(nBootstrap,1);
            
            parfor b = 1:nBootstrap
                % Bootstrap resample trials with replacement
                xIdx = randi(nX, [1 nX]);
                yIdx = randi(nY, [1 nY]);
            
                % Average resampled trials
                x = mean(X_sel(xIdx,:), 1, 'omitnan')';
                y = mean(Y_sel(yIdx,:), 1, 'omitnan')';

                xNorm = x/std(x);
                yNorm = y/std(x);
            
                % Fit kernel
                [kNorm, ~] = fit_dbl_exp_kernel(xNorm, yNorm, kernelLength);
                k = std(y) * kNorm / std(x);
            
                % Predicted output (causal)
                yhat = conv(x, k, 'full');
                yhat = yhat(1:length(y));
            
                % Variance explained (R^2)
                ss_res = sum((y - yhat).^2);
                ss_tot = sum((y - mean(y)).^2);
                bootvarExp(b) = 1 - ss_res/ss_tot;
            
                % Store
                bootKernels(:,b) = k;
                bootInputs(:,b) = x(:);
                bootOutputs(:,b) = y(:);
            end
            
            % Save results to struct
            results(resultCounter).inputID = inID;
            results(resultCounter).outputID = outID;
            results(resultCounter).Training = cond;
            results(resultCounter).nBootstrap = nBootstrap;
            results(resultCounter).kernels = bootKernels;
            results(resultCounter).inputs = bootInputs;
            results(resultCounter).outputs = bootOutputs;
            results(resultCounter).varExp = bootvarExp;

            resultCounter = resultCounter + 1;
        end
    end
end

end