%% load in screened data
clear
% allData = readtable('20250909_data_NaN_SNR_Duplicate_screened.csv');
load('20251224_data_NaN_SNR_Duplicate_screened.mat', 'validData');
allData = validData;

% check that all traces have channels and background
allDataKeys = string(allData.TraceID) + string(allData.SignalType);
allTraceKeys = string(allData.TraceID);

if length(unique(allDataKeys)) < length(allDataKeys)
    warning("Not all data keys are unique, some traces may be missing channels and/or background");
elseif length(unique(allDataKeys)) ~= 4*length(unique(allTraceKeys))
    warning("Mismatch between number of traces and size of extracted data, some traces may be missing channels and/or background");
end

%% Sort data by Primary and Secondary keys
allData = sortrows(allData, ["TraceID","SignalType"], ["ascend","descend"]);

% Verify expected secondary key order per primary key
expectedOrder = ["_mcherry","_gcamp","-bg_mcherry","-bg_gcamp"];
g = findgroups(allData.TraceID);
actualOrder = splitapply(@(x){x}, allData.SignalType, g);
assert(all(cellfun(@(x) isequal(x(:), expectedOrder(:)), actualOrder)), ...
    'Secondary keys not in expected order for at least one primary key.');

%% Validation checks
% Identify numeric data columns (assumes first 10 are metadata)
dataVars = allData.Properties.VariableNames(11:end);

% Check for gaps larger than maxGap
maxGap = 3;
numData = allData{:, dataVars};
badRun = any(movsum(isnan(numData), maxGap+1, 2) == (maxGap+1), 2);
assert(~any(badRun), 'Found a gap of >=%d NaNs in numerical data.', maxGap+1);

% Fill missing values (safe since max-gap rule already enforced)
allData{:, dataVars} = fillmissing(allData{:, dataVars}, 'nearest', 2);

% Check row count is divisible by 4
dataHeight = height(allData);
assert(mod(dataHeight, 4) == 0, 'Row count is not divisible by 4.');

%% Calculate Ratio = (Fg - bkgG)/(Fr - bkgR)
% Build block indices
mCh_i = 1:4:dataHeight;
GCa_i = mCh_i + 1;
bMC_i = mCh_i + 2;
bGC_i = mCh_i + 3;

% Perform calculation (enforcing non-negativity of F)
F_mCherry = allData{GCa_i, dataVars} - allData{bGC_i, dataVars};
F_GCaMP = allData{mCh_i, dataVars} - allData{bMC_i, dataVars};
Ratio = F_mCherry ./ F_GCaMP;

% check Ratio for NaN values introduced by dim mCherry 
badRun = any(movsum(isnan(Ratio), maxGap+1, 2) > maxGap, 2);
assert(~any(badRun), 'Found a gap of >=%d NaNs in numerical data.', maxGap+1);

%% Reattach metadata (taking from mCh row)
RatioTable = allData(mCh_i, 1:8); % explicitly keep metadata cols
RatioTable.Data = Ratio;

% save imprecise CSV and full precision .mat files
writetable(RatioTable, '20251224_RatioFgFr_imprecise.csv');
save('20251224_RatioFgFr_fullPrecisionMatrix.mat', 'Ratio');

% load imprecise CSV
RatioTable = readtable('20251224_RatioFgFr_imprecise.csv');
load('20251224_RatioFgFr_fullPrecisionMatrix.mat', 'Ratio');
RatioTable{:, 9:end} = Ratio;
save('20251224_RatioFgFr_fullPrecisionTable.mat', 'RatioTable');

%% calculate dRRo
clear;
load('20251224_RatioFgFr_fullPrecisionTable.mat', 'RatioTable');

t_baseline = 101:150;
R = RatioTable{:, 9:end};
Ro = mean(R(:, t_baseline), 2);

assert(any(isnan(Ro)) == false, 'Found NaN when calculating Ro');
dRRo = (R - Ro)./Ro;

dRRoTable = RatioTable;
dRRoTable{:, 9:end} = dRRo;
save('20251224_dRRo_101to150base.mat', 'dRRoTable');