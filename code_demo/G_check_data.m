%% read in stacked results
% load from .mat to save full double precision
% allData = readtable('20251224_all_traces_stackCsvXlsx.csv');
clear
load('20251224_all_traces_stackCsvXlsx_fullPrecision.mat', 'allData');
%% sort data to group all SignalTypes for traces together
traceID = string(allData.FilePath) ...
        + string(allData.FileName) ...
        + string(allData.Stimulus) ...
        + string(allData.Promoter) ...
        + string(allData.Training) ...
        + string(allData.FocalPlane)...
        + string(allData.Position)...
        + string(allData.NeuronID);

% add to table and sort table by values;
allData.TraceID = traceID;
allData = movevars(allData, 'TraceID', 'Before', 'Data_1');
[~, I] = sort(traceID);
allData = allData(I,:); 

% check that all traces have channels and background
allDataKeys = string(allData.TraceID) + string(allData.SignalType);
allTraceKeys = string(allData.TraceID);

if length(unique(allDataKeys)) < length(allDataKeys)
    warning("Not all data keys are unique, some traces may be missing channels and/or background");
elseif length(unique(allDataKeys)) ~= 4*length(unique(allTraceKeys))
    warning("Mismatch between number of traces and size of extracted data, some traces may be missing channels and/or background");
end

%% check lengths of vectors and flag files with unexpected lengths
traceData = table2array(allData(:, 11:end));

nTraces = height(traceData);
effLength = zeros(nTraces, 1);
for i = 1:nTraces
    effLength(i) = find(~isnan(traceData(i,:)), 1, 'last');
end

% get list of short data
okay_idx = (effLength == 450) | (effLength == 451);
weird_idx = ~okay_idx;

% separate out short data and save as xlsx
shortData = allData(weird_idx, :);
shortData.Length = effLength(weird_idx);
shortData = movevars(shortData, 'Length', 'Before', 'Data_1');
writetable(shortData, '20251224_missing_frames.xlsx')

% potentially work out programattic fix for traces with 447 timepoints

% separate out okay data and save as csv
okayData = allData(okay_idx, :);
writetable(okayData, '20251224_data_w450or451_frames.csv')
save('20251224_data_w450or451_frames.mat', 'okayData')

%% load back in data that seems okay, check that we still have all channels for all traces
clear
% allData = readtable('20251224_data_w450or451_frames.csv', 'Delimiter', ',');
load('20251224_data_w450or451_frames.mat', 'okayData');
allData = okayData;

% check that all traces have channels and background
allDataKeys = string(allData.TraceID) + string(allData.SignalType);
allTraceKeys = string(allData.TraceID);

if length(unique(allDataKeys)) < length(allDataKeys)
    warning("Not all data keys are unique, some traces may be missing channels and/or background");
elseif length(unique(allDataKeys)) ~= 4*length(unique(allTraceKeys))
    warning("Mismatch between number of traces and size of extracted data, some traces may be missing channels and/or background");
end

%% check for traces where corresponding signal is less than corresponding background
% Hierachichally sort data by trace ID (condition + worm + cell + plane), then signal type (mCherry, GCaMP,
% mCherry_bk, GCaMP_bk)
allData = sortrows(allData, ["TraceID", "SignalType"], ["ascend", "descend"]);

nRows = height(allData);
mCher_data    = allData{1:4:nRows, 11:end};
GCaMP_data    = allData{2:4:nRows, 11:end};
mCher_data_bk = allData{3:4:nRows, 11:end};
GCaMP_data_bk = allData{4:4:nRows, 11:end};

% count number of times ROI trace < than corresponding bkgrd
mCher_sub_bk = sum(mCher_data < mCher_data_bk, 2);
GCaMP_sub_bk = sum(GCaMP_data < GCaMP_data_bk, 2);

%% get traces with signal below bkg and filter out data with dim ROI
maxFramesBelowBkg = 10; % change to increase tolerance

g_filt_inds = GCaMP_sub_bk > maxFramesBelowBkg;
r_filt_inds = mCher_sub_bk > maxFramesBelowBkg;
filter = g_filt_inds | r_filt_inds; % combine red and green filters 
filter = repelem(filter, 4, 1);     % expand filter to cover all four traces (R/G, ROI/BKG) for flagged data

% get information about times below background and add to table
timesBelowBk = [mCher_sub_bk, GCaMP_sub_bk];
timesBelowBk = [timesBelowBk,  zeros(size(timesBelowBk))];
timesBelowBk = timesBelowBk'; timesBelowBk = timesBelowBk(:); % row-major linearization

ROI_flagged_data = allData(filter, :);
ROI_flagged_data.FramesBelowBackground = timesBelowBk(filter);
ROI_flagged_data = movevars(ROI_flagged_data,'FramesBelowBackground','Before','Data_1');

writetable(ROI_flagged_data, '20251224_signals_below_bkg_max10.xlsx')

%% save filtered list of traces
okayData = allData(~filter, :);
writetable(okayData, '20251224_data_NaN_and_SNR_screened.csv');
save('20251224_data_NaN_and_SNR_screened.mat', 'okayData');

% test that written table and re-read from csv are equivalent
% test = readtable('20251224_data_NaN_and_SNR_screened.csv', 'Delimiter', ',');
% isequaln(okayData, test)

%% load back in data that seems okay, check that we still have all channels for all traces
clear
%allData = readtable('20251224_data_w450or451_frames.csv', 'Delimiter', ',');
%allData = readtable('20251224_data_NaN_and_SNR_screened.csv', 'Delimiter', ',');
load('20251224_data_NaN_and_SNR_screened.mat', 'okayData');
allData = okayData;

% check that all traces have channels and background
allDataKeys = string(allData.TraceID) + string(allData.SignalType);
allTraceKeys = string(allData.TraceID);

if length(unique(allDataKeys)) < length(allDataKeys)
    warning("Not all data keys are unique, some traces may be missing channels and/or background");
elseif length(unique(allDataKeys)) ~= 4*length(unique(allTraceKeys))
    warning("Mismatch between number of traces and size of extracted data, some traces may be missing channels and/or background");
end

%% check for instances where ROI signal is duplicated
% Hierachichally sort data by trace ID (condition + worm + cell + plane), then signal type (mCherry, GCaMP,
% mCherry_bk, GCaMP_bk)
allData = sortrows(allData, ["TraceID", "SignalType"], ["ascend", "descend"]);

% get mCherry and GCaMP ROI data
nRows = height(allData);
mCher_data    = allData{1:4:nRows, 11:end};
GCaMP_data    = allData{2:4:nRows, 11:end};
ROI_data = [mCher_data; GCaMP_data];
ROI_data(isnan(ROI_data)) = -Inf;

% look for duplicated rows
[~, ~, ic] = unique(ROI_data,'rows');
instances = accumarray(ic,1);
duplicate_inds = instances(ic) > 1;

% get table of duplicated rows
ROI_rows = [1:4:nRows, 2:4:nRows];
duplicated_rows = allData(ROI_rows(duplicate_inds), :);

%% write table of duplicated rows
writetable(duplicated_rows, '20251224_duplicated_rows.xlsx');

%% filter data based on detected duplicates
r_duplicates = duplicate_inds(1:(nRows/4));
g_duplicates = duplicate_inds((nRows/4) + (1:(nRows/4)));
filter = (r_duplicates | g_duplicates);
filter = repelem(filter, 4, 1);

%% save data
validData = allData(~filter, :);
writetable(validData, '20251224_data_NaN_SNR_Duplicate_screened.csv');
save('20251224_data_NaN_SNR_Duplicate_screened.mat', 'validData');

%% test saved data
clear
% test = readtable('20250909_data_NaN_SNR_Duplicate_screened.csv');
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