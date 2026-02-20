%% run plotting for multi slice modularity results
addpath(genpath('helpers'))
path = '';
plotAll = false;
if plotAll
    % plots all results contained in folder "path"
    x = dir(path);
    dataName = {x.name}';
    dataName = dataName(endsWith(string(dataName), ".mat"));
else
    % pick specific results in path folder to plot (for clean up later)
    dataName = {...
        'demo-1p_stimulus1_w100_s10_o0.4_nb10.mat', ...
        'demo-1p_stimulus2_w100_s10_o0.4_nb10.mat', ...
        };
end
%%
for i =1:length(dataName)
    % post process results
    data = postProcessSingleSliceModularityResults(path, dataName{i}, "multi");
    
    % run function for plotting results
    [t, ax1, ax2] = plotModularityResults_stimSpecific(data);
%     ax1.YLim = [0 0.5];
%     ax2.YLim = [-0.3 0.2];
    f = gcf;
    % scale and export figure for main text
    figWidth = 1.2*180/25.4/2;
    figHeight = 170/25.4;
    f = applyNatureFigStyleResize(f, figWidth, figHeight);
    title(t, strrep(dataName{i}, '_', ' '), 'FontSize', 6);
    print(f, '-dpdf', '-painters', [extractBefore(dataName{i}, '.mat'), '_main.pdf'])

    % scale and export figure for SI
    figWidth = 180/25.4;
    figHeight = 200/25.4;
    f = applyNatureFigStyleResize(f, figWidth, figHeight);
    print(f, '-dpdf', '-painters', [extractBefore(dataName{i}, '.mat'), '_SI.pdf'])   
    close all
end

%% snippet to test plotting for multi-slice results
% path = "results/092625_multislice/full_data_n1000";
% dataName = {...
%     'ncs-1p_OP-PA_w100_s10_o0.4_nb1000.mat',...
%     'ncs-1p_PA-buffer_w100_s10_o0.4_nb1000.mat',...
%     };
% 
% for i = 1%:length(dataName)
%     data = postProcessSingleSliceModularityResults(path, dataName{i}, "multi");
%     sum(data.Ea1 > data.Eb1);
%     sum(data.Ea2 > data.Eb2);
%     sum(data.Ca1 > data.Cb1, 3)
%     sum(data.Ca2 > data.Cb2, 3)
% 
%     [t, ax1, ax2] = plotModularityResults_stimSpecific(data);
%     ax1.YLim = [0 0.5];
%     ax2.YLim = [-0.2 0.3];
%     f = gcf;
%     figWidth = 1.2*180/25.4/2;
%     figHeight = 170/25.4;
%     f = applyNatureFigStyleResize(f, figWidth, figHeight);
%     title(t, strrep(dataName{i}, '_', ' '), 'FontSize', 6);
%     print(f, '-dpdf', '-painters', [extractBefore(dataName{i}, '.mat'), '.pdf'])
% end

%% helper function for post processing modularity results
function data = postProcessSingleSliceModularityResults(path, dataName, method)
%% load target data
if method == "single"
    targetVars = {"Q_ms_n_boot", "Q_ms_t_boot", "S_singl_n_boot", "S_singl_t_boot", "dropped_rows", "folded_IDs", "t_end"};
    load(fullfile(path, dataName), targetVars{:})
elseif method == "multi"
    targetVars = {"Q_ms_n_boot", "Q_ms_t_boot", "S_multi_n_boot", "S_multi_t_boot", "dropped_rows", "folded_IDs", "t_end"};
    load(fullfile(path, dataName), targetVars{:})
    S_singl_n_boot = S_multi_n_boot;
    S_singl_t_boot = S_multi_t_boot;
else
    error("method must either be ""single"" or ""multi""")
end

%% post-process results
% figure out often dropped neurons across bootstraps
valid = sum(dropped_rows, 2) < 0.5*size(dropped_rows, 2);

% drop neurons that are frequently dropped
folded_IDs = folded_IDs(valid);
S_singl_n_boot = S_singl_n_boot(valid, :, :);
S_singl_t_boot = S_singl_t_boot(valid, :, :);
dropped_rows = dropped_rows(valid, :);

% convert t_end from frames to seconds
t_end = t_end/5;

% get consensus module assignments across bootstraps 
if method == "single"
    Sn_bootConn = getBootstrapConsensus(S_singl_n_boot);
    St_bootConn = getBootstrapConsensus(S_singl_t_boot);
elseif method == "multi"
    Sn_bootConn = getBootstrapConsensusMulti(S_singl_n_boot);
    St_bootConn = getBootstrapConsensusMulti(S_singl_t_boot);
end

allegiance_n_bootConn = get_consensus(Sn_bootConn);
allegiance_t_bootConn = get_consensus(St_bootConn);

[~, S_conn_n] = sort_by_modularity(allegiance_n_bootConn, 1);
[~, S_conn_t] = sort_by_modularity(allegiance_t_bootConn, 1);

% register S_conn_n and S_conn_t
S_conn_temp = reindex_modules([S_conn_n, S_conn_t]);
S_conn_n = S_conn_temp(:,1);
S_conn_t = S_conn_temp(:,2);

[~, order_n] = sort(S_conn_n);
[~, order_t] = sort(S_conn_t);

% get stimulus specific allegiance matrices for bootstrap consensus module assignments
stim1 = (t_end >= 30) & (t_end <= 60);
stim2 = (t_end > 60);
alleg_Na1 = get_consensus(Sn_bootConn(:, stim1));
alleg_Na2 = get_consensus(Sn_bootConn(:, stim2));
alleg_Tr1 = get_consensus(St_bootConn(:, stim1));
alleg_Tr2 = get_consensus(St_bootConn(:, stim2));

% get stimulus specific recruitment and integration based on bootstrap consensus module assignments
n_boots = size(S_singl_n_boot, 3);
nModulesN = max(S_conn_n);
nModulesT = max(S_conn_t);
nModules = max(nModulesN, nModulesT);

RI_mats_Na1 = NaN([nModules, nModules, n_boots]);
RI_mats_Na2 = NaN([nModules, nModules, n_boots]);
RI_mats_Tr1 = NaN([nModules, nModules, n_boots]);
RI_mats_Tr2 = NaN([nModules, nModules, n_boots]);

for b = 1:n_boots
    % get stimulus specific allegiance matrices
    alleg_Na1_temp = get_consensus(S_singl_n_boot(:, stim1, b));
    alleg_Na2_temp = get_consensus(S_singl_n_boot(:, stim2, b));
    alleg_Tr1_temp = get_consensus(S_singl_t_boot(:, stim1, b));
    alleg_Tr2_temp = get_consensus(S_singl_t_boot(:, stim2, b));

    % NaN out dropped rows
    drop_mask = dropped_rows(:,b) | dropped_rows(:,b)';
    alleg_Na1_temp(drop_mask) = NaN;
    alleg_Na2_temp(drop_mask) = NaN;
    alleg_Tr1_temp(drop_mask) = NaN;
    alleg_Tr2_temp(drop_mask) = NaN;

    % get recruitment and integration
    RI_mats_Na1(1:nModulesN,1:nModulesN,b) = get_recruitment_and_integration(alleg_Na1_temp, S_conn_n, "allegiance");
    RI_mats_Na2(1:nModulesN,1:nModulesN,b) = get_recruitment_and_integration(alleg_Na2_temp, S_conn_n, "allegiance");
    RI_mats_Tr1(1:nModulesT,1:nModulesT,b) = get_recruitment_and_integration(alleg_Tr1_temp, S_conn_t, "allegiance");
    RI_mats_Tr2(1:nModulesT,1:nModulesT,b) = get_recruitment_and_integration(alleg_Tr2_temp, S_conn_t, "allegiance");
end

% get stimulus specific network flexibility
f_Na1 = zeros(n_boots, 1);
f_Na2 = zeros(n_boots, 1);
f_Tr1 = zeros(n_boots, 1);
f_Tr2 = zeros(n_boots, 1);

for b = 1:n_boots
    valid = ~dropped_rows(:,b);
    f_Na1(b) = mean(get_flexibility(S_singl_n_boot(valid, stim1, b)));
    f_Na2(b) = mean(get_flexibility(S_singl_n_boot(valid, stim2, b)));
    f_Tr1(b) = mean(get_flexibility(S_singl_t_boot(valid, stim1, b)));
    f_Tr2(b) = mean(get_flexibility(S_singl_t_boot(valid, stim2, b)));
end

%% write post-processed results to data structure for plotting
data = struct();

% add bootstrapped modularity data
% Time series
data.A       = Q_ms_n_boot;  % [time x bootstraps]
data.B       = Q_ms_t_boot;  % [time x bootstraps]
data.t       = t_end;  % [time x 1]

% get and add stimulus specific recruitment and integration data
% Group × group trial-based matrices
data.Ca1     = RI_mats_Na1;  % [group x group x bootstraps]
data.Ca2     = RI_mats_Na2;
data.Cb1     = RI_mats_Tr1;
data.Cb2     = RI_mats_Tr2;

% Get and add bootstrapped average module assignments
data.Da      = Sn_bootConn(order_n, :);  % [rows x time]
data.Db      = St_bootConn(order_t, :);

% Get and add bootstrapped stimulus specific flexibility
data.Ea1     = f_Na1;  % [bootstraps x 1]
data.Ea2     = f_Na2;
data.Eb1     = f_Tr1;
data.Eb2     = f_Tr2;

% Get and add stimulus specific allegiance matrices
data.Fa1     = alleg_Na1(order_n, order_n);  % [rows x rows]
data.Fa2     = alleg_Na2(order_n, order_n);
data.Fb1     = alleg_Tr1(order_t, order_t);
data.Fb2     = alleg_Tr2(order_t, order_t);

% Heatmap row labels
data.rowsA   = folded_IDs(order_n);  % string array
data.rowsB   = folded_IDs(order_t);  % string array

% Colors
data.colorA  = [136 134 102]/255;  % naive color
data.colorB  = [107 62  152]/255;  % trained color
data.colorBA = [0    0.4470    0.7410];  % RGB triplet for B-A difference
end