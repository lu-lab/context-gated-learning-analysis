%% notes
% script for batch generation of learning summaries with different window
% lengths and coupling paramter values

%% add required custom functions to path
addpath(genpath('GenLouvain'))
addpath(genpath('custom_helpers'))
addpath(genpath('utils'))

%% load in full dataset
% data_path = '/Users/sihoonmoon/GaTech Dropbox/coe-hl94-personal/PEOPLE/COLLABORATORS/yun/Lu-Zhang lab share/learning data/data_verification/20250206_verified_traces';
data_path = '/Users/sihoonmoon/Downloads/';
filename = '20250206_fully_checked_dRRo_bl_101_151.csv';
full_data = readtable([data_path, '/', filename]);

%% add promoter metadata to table
promoter_list = ["acr-5", "glr-1", "inx-4", "inx-4_mbr-1", "ncs-1"];
promoter = repmat("acr-5",[size(full_data,1), 1]);
for i_prom = 1:length(promoter_list)
    % get indices of rows containting target promoter
    idx = contains(string(full_data.filepaths), join([promoter_list(i_prom),"/",], ''));

    promoter(idx) = promoter_list(i_prom);
end

full_data = addvars(full_data,promoter,'After','filenames');

%% make desired summary figures
f = get_learning_summary(full_data, "acr-5", "PA-Buffer", 100, 10, 0.2);
saveas(f,'acr5_PB_20s_w02.jpg');
 
f = get_learning_summary(full_data, "acr-5", "PA-Buffer", 100, 10, 1);
saveas(f,'acr5_PB_20s_w1.jpg');

f = get_learning_summary(full_data, "acr-5", "PA-Buffer", 100, 10, 5);
saveas(f,'acr5_PB_20s_w5.jpg');

%%
f = get_learning_summary_acr5PO(full_data, "acr-5", "OP-PA", 100, 10, 0.1);
saveas(f,'acr5_PB_20s_w01.jpg');

f = get_learning_summary_acr5PO(full_data, "acr-5", "OP-PA", 100, 10, 0.01);
saveas(f,'acr5_PB_20s_w001.jpg');

f = get_learning_summary_acr5PO(full_data, "acr-5", "OP-PA", 100, 10, 0.001);
saveas(f,'acr5_PB_20s_w0001.jpg');

f = get_learning_summary_acr5PO(full_data, "acr-5", "OP-PA", 100, 10, 0.0001);
saveas(f,'acr5_PB_20s_w00001.jpg');

%% glr-1 PA-Buffer
f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 20, 2, 0.2);
saveas(f,'glr-1_PB_4s_w02.fig');

f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 20, 2, 1);
saveas(f,'glr-1_PB_4s_w1.fig');

f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 20, 2, 5);
saveas(f,'glr-1_PB_4s_w5.fig');

%%
f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 100, 10, 0.2);
saveas(f,'glr-1_PB_20s_w02.jpg');

f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 100, 10, 1);
saveas(f,'glr-1_PB_20s_w1.jpg');

f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 100, 10, 5);
saveas(f,'glr-1_PB_20s_w5.jpg');

f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 100, 10, 2);
saveas(f,'glr-1_PB_20s_w2.jpg');

f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 100, 10, 3);
saveas(f,'glr-1_PB_20s_w3.jpg');

f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 100, 10, 4);
saveas(f,'glr-1_PB_20s_w4.jpg');
%%
f = get_learning_summary(full_data, "glr-1", "PA-Buffer", 100, 10, 0.5);
saveas(f,'glr-1_PB_20s_w05.jpg');

%% glr-1 PA-OP
f = get_learning_summary(full_data, "glr-1", "OP-PA", 20, 2, 0.2);
saveas(f,'glr-1_PO_4s_w02.fig');

f = get_learning_summary(full_data, "glr-1", "OP-PA", 20, 2, 1);
saveas(f,'glr-1_PO_4s_w1.fig');

f = get_learning_summary(full_data, "glr-1", "OP-PA", 20, 2, 5);
saveas(f,'glr-1_PO_4s_w5.fig');

f = get_learning_summary(full_data, "glr-1", "OP-PA", 100, 10, 0.2);
saveas(f,'glr-1_PO_20s_w02.fig');

f = get_learning_summary(full_data, "glr-1", "OP-PA", 100, 10, 1);
saveas(f,'glr-1_PO_20s_w1.fig');

f = get_learning_summary(full_data, "glr-1", "OP-PA", 100, 10, 5);
saveas(f,'glr-1_PO_20s_w5.fig');

% inx-4 PA-Buffer
f = get_learning_summary(full_data, "inx-4", "PA-Buffer", 20, 2, 0.2);
saveas(f,'inx-4_PB_4s_w02.fig');

f = get_learning_summary(full_data, "inx-4", "PA-Buffer", 20, 2, 1);
saveas(f,'inx-4_PB_4s_w1.fig');

f = get_learning_summary(full_data, "inx-4", "PA-Buffer", 20, 2, 5);
saveas(f,'inx-4_PB_4s_w5.fig');

f = get_learning_summary(full_data, "inx-4", "PA-Buffer", 100, 10, 0.2);
saveas(f,'inx-4_PB_20s_w02.fig');

f = get_learning_summary(full_data, "inx-4", "PA-Buffer", 100, 10, 1);
saveas(f,'inx-4_PB_20s_w1.fig');

f = get_learning_summary(full_data, "inx-4", "PA-Buffer", 100, 10, 5);
saveas(f,'inx-4_PB_20s_w5.fig');

% inx-4 PA-OP
f = get_learning_summary(full_data, "inx-4", "OP-PA", 20, 2, 0.2);
saveas(f,'inx-4_PO_4s_w02.fig');

f = get_learning_summary(full_data, "inx-4", "OP-PA", 20, 2, 1);
saveas(f,'inx-4_PO_4s_w1.fig');

f = get_learning_summary(full_data, "inx-4", "OP-PA", 20, 2, 5);
saveas(f,'inx-4_PO_4s_w5.fig');

f = get_learning_summary(full_data, "inx-4", "OP-PA", 100, 10, 0.2);
saveas(f,'inx-4_PO_20s_w02.fig');

f = get_learning_summary(full_data, "inx-4", "OP-PA", 100, 10, 1);
saveas(f,'inx-4_PO_20s_w1.fig');

f = get_learning_summary(full_data, "inx-4", "OP-PA", 100, 10, 5);
saveas(f,'inx-4_PO_20s_w5.fig');

% inx-4_mbr-1 PA-Buffer
f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "PA-Buffer", 20, 2, 0.2);
saveas(f,'inx-4_mbr-1_PB_4s_w02.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "PA-Buffer", 20, 2, 1);
saveas(f,'inx-4_mbr-1_PB_4s_w1.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "PA-Buffer", 20, 2, 5);
saveas(f,'inx-4_mbr-1_PB_4s_w5.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "PA-Buffer", 100, 10, 0.2);
saveas(f,'inx-4_mbr-1_PB_20s_w02.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "PA-Buffer", 100, 10, 1);
saveas(f,'inx-4_mbr-1_PB_20s_w1.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "PA-Buffer", 100, 10, 5);
saveas(f,'inx-4_mbr-1_PB_20s_w5.fig');

% inx-4_mbr-1 PA-OP
f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "OP-PA", 20, 2, 0.2);
saveas(f,'inx-4_mbr-1_PO_4s_w02.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "OP-PA", 20, 2, 1);
saveas(f,'inx-4_mbr-1_PO_4s_w1.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "OP-PA", 20, 2, 5);
saveas(f,'inx-4_mbr-1_PO_4s_w5.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "OP-PA", 100, 10, 0.2);
saveas(f,'inx-4_mbr-1_PO_20s_w02.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "OP-PA", 100, 10, 1);
saveas(f,'inx-4_mbr-1_PO_20s_w1.fig');

f = get_learning_summary_folding(full_data, "inx-4_mbr-1", "OP-PA", 100, 10, 5);
saveas(f,'inx-4_mbr-1_PO_20s_w5.fig');

% ncs-1 PA-Buffer
f = get_learning_summary_folding(full_data, "ncs-1", "PA-Buffer", 20, 2, 0.2);
saveas(f,'ncs-1_PB_4s_w02.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "PA-Buffer", 20, 2, 1);
saveas(f,'ncs-1_PB_4s_w1.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "PA-Buffer", 20, 2, 5);
saveas(f,'ncs-1_PB_4s_w5.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "PA-Buffer", 100, 10, 0.2);
saveas(f,'ncs-1_PB_20s_w02.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "PA-Buffer", 100, 10, 1);
saveas(f,'ncs-1_PB_20s_w1.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "PA-Buffer", 100, 10, 5);
saveas(f,'ncs-1_PB_20s_w5.fig');

% ncs-1 PA-OP
f = get_learning_summary_folding(full_data, "ncs-1", "OP-PA", 20, 2, 0.2);
saveas(f,'ncs-1_PO_4s_w02.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "OP-PA", 20, 2, 1);
saveas(f,'ncs-1_PO_4s_w1.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "OP-PA", 20, 2, 5);
saveas(f,'ncs-1_PO_4s_w5.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "OP-PA", 100, 10, 0.2);
saveas(f,'ncs-1_PO_20s_w02.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "OP-PA", 100, 10, 1);
saveas(f,'ncs-1_PO_20s_w1.fig');

f = get_learning_summary_folding(full_data, "ncs-1", "OP-PA", 100, 10, 5);
saveas(f,'ncs-1_PO_20s_w5.fig');

%% batch save as jpg
x = dir();
n_files = length(x);

for i = 1:n_files
    if endsWith(x(i).name, ".fig")
        f = openfig(x(i).name);
        f = applyPresentationStyle(f);
        new_fig_name = x(i).name;
        saveas(f,[new_fig_name(1:(end-3)), 'jpg'])
    end
end