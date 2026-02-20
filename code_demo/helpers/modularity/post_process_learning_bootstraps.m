function post_process_learning_bootstraps(path, file)
% function loads learning bootstrapping results from file and plots figure
load(fullfile(path, file));

%% get consensus modules across bootstraps
S_boot_conn_n = get_bootstrap_consensus(S_multi_n_boot, dropped_rows);
S_boot_conn_t = get_bootstrap_consensus(S_multi_t_boot, dropped_rows);

%% get allegiance matrices for bootstrap consensus
C_boot_n = get_consensus_w_NaN(S_boot_conn_n);
C_boot_t = get_consensus_w_NaN(S_boot_conn_t);

%% average allegiance matrices across bootstraps
C_boot_n_mean = average_allegiance_matrices(allegiance_n_boot, dropped_rows);
C_boot_t_mean = average_allegiance_matrices(allegiance_t_boot, dropped_rows);

%% drop rows
valid = sum(dropped_rows,2) < size(dropped_rows,2)*0.5;

S_boot_conn_n = S_boot_conn_n(valid,:);
S_boot_conn_t = S_boot_conn_t(valid,:);
C_boot_n = C_boot_n(valid, valid);
C_boot_t = C_boot_t(valid, valid);
C_boot_n_mean = C_boot_n_mean(valid, valid);
C_boot_t_mean = C_boot_t_mean(valid, valid);

folded_IDs = folded_IDs(valid);
flexibility_n_boot = flexibility_n_boot(valid,:);
flexibility_t_boot = flexibility_t_boot(valid,:);
allegiance_n_boot = allegiance_n_boot(valid,valid,:);
allegiance_t_boot = allegiance_t_boot(valid,valid,:);
dropped_rows = dropped_rows(valid,:);

%% find modules in averaged allegiance matrices

% find from averaged allegiance matrices
%[~, S_conn_n] = sort_by_modularity(C_boot_n_mean, 1);
%[~, S_conn_t] = sort_by_modularity(C_boot_t_mean, 1);

% find from bootstrapped consensus assignments
[~, S_conn_n] = sort_by_modularity(C_boot_n, 1);
[~, S_conn_t] = sort_by_modularity(C_boot_t, 1);

% register S_conn_n and S_conn_t
S_conn_temp = reindex_modules([S_conn_n, S_conn_t]);
S_conn_n = S_conn_temp(:,1);
S_conn_t = S_conn_temp(:,2);

[~, order_n] = sort(S_conn_n);
[~, order_t] = sort(S_conn_t);

%% get recruitment and integration for bootstrap consensus
RI_mat_conn_n = get_recruitment_and_integration(C_boot_n, S_conn_n, zeros(length(S_conn_n),1));
RI_mat_conn_t = get_recruitment_and_integration(C_boot_t, S_conn_t, zeros(length(S_conn_n),1));

%% get recruitment and integration across bootstraps
n_boots = size(allegiance_n_boot, 3);

nModulesN = max(S_conn_n);
nModulesT = max(S_conn_t);
nModules = max(nModulesN, nModulesT);
RI_mat_boot_n = NaN([nModules, nModules, n_boots]);
RI_mat_boot_t = NaN([nModules, nModules, n_boots]);

for i = 1:n_boots
    RI_mat_boot_n(1:nModulesN,1:nModulesN,i) = get_recruitment_and_integration(allegiance_n_boot(:,:,i), S_conn_n, dropped_rows(:,i));
    RI_mat_boot_t(1:nModulesT,1:nModulesT,i) = get_recruitment_and_integration(allegiance_t_boot(:,:,i), S_conn_t, dropped_rows(:,i));
end

%% make plot
naive_color = [0.9290 0.6940 0.1250];
trained_color = [0.4660 0.6740 0.1880];

% initialize figure
f = figure;
f.Position(3:4) = [1080, 750];
t = tiledlayout(4,5);
title(t, strrep(file, '_', ' '))

% plot naive module assingments
nexttile(1, [1 2]);
imagesc(t_end/5, 1:length(folded_IDs), S_boot_conn_n(order_n,:));
naive_cmap = one_color_gradient(naive_color, max(S_boot_conn_n(:))+1);
naive_cmap = naive_cmap(2:end,:);
ax = gca;
ax.Colormap = naive_cmap;
ax.YTick = 1:length(folded_IDs);
ax.YTickLabels = folded_IDs(order_n);
ax.XTick = 0:30:90;
ax.XLim = [0 90];

% plot trained module assignments
nexttile(6, [1 2]);
imagesc(t_end/5, 1:length(folded_IDs), S_boot_conn_t(order_t,:));
trained_cmap = one_color_gradient(trained_color, max(S_boot_conn_t(:))+1);
trained_cmap = trained_cmap(2:end,:);
ax = gca;
ax.Colormap = trained_cmap;
ax.YTick = 1:length(folded_IDs);
ax.YTickLabels = folded_IDs(order_t);
ax.XTick = 0:30:90;
ax.XLim = [0 90];

% plot naive consensus allegiance matrix
nexttile(3, [1 1]);
imagesc(C_boot_n(order_n,order_n));
ax = gca;
ax.Colormap = gray;
ax.CLim = [0 1];
ax.YTick = [];
ax.XTick = [];

% plot trained consensus allegiance matrix
nexttile(8, [1 1]);
imagesc(C_boot_t(order_t,order_t));
ax = gca;
ax.Colormap = gray;
ax.CLim = [0 1];
ax.YTick = [];
ax.XTick = [];

% plot naive average allegiance matrix
nexttile(4, [1 1]);
imagesc(C_boot_n_mean(order_n,order_n));
ax = gca;
ax.Colormap = gray;
ax.CLim = [0 1];
ax.YTick = [];
ax.XTick = [];

% plot trained average allegiance matrix
nexttile(9, [1 1]);
imagesc(C_boot_t_mean(order_t,order_t));
ax = gca;
ax.Colormap = gray;
ax.CLim = [0 1];
ax.YTick = [];
ax.XTick = [];

%% plot naive vs. trained recruitment/integration bar
nexttile(5, [1 1]);
% flatten naive data
[n_modules, ~, n_boots] = size(RI_mat_boot_n);
data_n = reshape(RI_mat_boot_n,n_modules*n_modules,n_boots);
inds = find(tril(ones(n_modules)));
data_n = data_n(inds,:);
% flatten trained data
[n_modules, ~, n_boots] = size(RI_mat_boot_t);
data_t = reshape(RI_mat_boot_t,n_modules*n_modules,n_boots);
inds = find(tril(ones(n_modules)));
data_t = data_t(inds,:);
% append naive and trained data
n_bars = max(size(data_n,1), size(data_t,1));
data = NaN(n_bars, n_boots, 2);
data(1:size(data_n,1),:,1) = data_n;
data(1:size(data_t,1),:,2) = data_t;
% plot bars
plot_bars_w_error(data);
ax = gca;
temp_lims = ax.XLim;
ax.ColorOrder = [naive_color; trained_color];

%% plot stacked bars of naive vs. trained recrutiment/integration
nexttile(10, [1 1])
[gr, eq, le] = count_comparisons(data(:,:,1), data(:,:,2));
data = [le'; eq'; gr'];
bar(data', 'stacked', 'BarWidth', 0.5);
hold on
plot(1:length(gr), sum(data)*0.95, 'k')
plot(1:length(gr), sum(data)*0.05, 'k')
ax = gca;
ax.XLim = temp_lims;
ax.ColorOrder = [trained_color; [0 0.4470 0.7410]; naive_color];

% plot naive vs. trained modularity
nexttile(11, [1 2])
trace_color = naive_color;
plot_traces_w_shaded_90CI(t_end/5, Q_ms_n_boot, trace_color);
hold on
trace_color = trained_color;
plot_traces_w_shaded_90CI(t_end/5, Q_ms_t_boot, trace_color);
ax1 = gca; 
ax1.XLim = [0 90];
ax1.XTick = 0:30:90;

% plot trained-naive modularity for each bootstrap
nexttile(16, [1 2])
trace_color = [0 0.4470 0.7410];
plot_traces_w_shaded_90CI(t_end/5, Q_ms_t_boot-Q_ms_n_boot, trace_color);
hold on
plot(t_end/5, zeros(size(t_end)),'r')
ax1 = gca; 
ax1.XLim = [0 90];
ax1.XTick = 0:30:90;

% plot naive vs. trained neuron flexibilities
nexttile(13, [1 2])
data = cat(3, flexibility_n_boot, flexibility_t_boot);
plot_bars_w_error(data(order_n, :, :));
% means = squeeze(mean(data,2,'omitnan'));
% stdevs = squeeze(std(data, [], 2, 'omitnan'));
% 
% b = bar(means(order_n, :));
% hold on;
% 
% for c = size(data,3)
%     x = b(c).XEndPoints;
%     errorbar(x, means(order_n,c), stdevs(order_n, c), 'k.')
% end
ax = gca;
ax.ColorOrder = [naive_color; trained_color];
ax.XTick = 1:length(folded_IDs);
ax.XTickLabel = folded_IDs(order_n);
ax.YLim = [0 ax.YLim(2)];
temp_lims = ax.XLim;

% plot stacked bars of neuron flexibilities
nexttile(18, [1 2])
[gr, eq, le] = count_comparisons(flexibility_n_boot, flexibility_t_boot);
data = [le'; eq'; gr'];
bar(data(:, order_n)', 'stacked', 'BarWidth', 0.5);
hold on
plot(1:length(gr), sum(data(:,order_n))*0.95, 'k')
plot(1:length(gr), sum(data(:,order_n))*0.05, 'k')
ax = gca;
ax.XTick = 1:length(folded_IDs);
ax.XTickLabel = folded_IDs(order_n);
ax.XLim = temp_lims;
ax.ColorOrder = [trained_color; [0 0.4470 0.7410]; naive_color];

% plot naive vs. trained network flexibilities
nexttile(15, [1 1])
net_flex_n = mean(flexibility_n_boot, 'omitnan');
net_flex_t = mean(flexibility_t_boot, 'omitnan');
data = [net_flex_n; net_flex_t];
x = 1:2;
bar(1, mean(net_flex_n));
hold on;
bar(2, mean(net_flex_t));
errorbar(x, mean(data'), std(data'), 'k.')
ax = gca;
ax.ColorOrder = [naive_color; trained_color];
ax.XTick = [];

% plot stacked bars of network flexibilities
nexttile(20, [1 1])
[gr, eq, le] = count_comparisons(net_flex_n, net_flex_t);
data = [le'; eq'; gr'];
bar(1, data', 'stacked');
hold on
plot([0.5 1.5], 0.95*sum(data)*[1 1], 'k')
plot([0.5 1.5], 0.05*sum(data)*[1 1], 'k')
ax = gca;
ax.ColorOrder = [trained_color; [0 0.4470 0.7410]; naive_color];

saveas(f, [file(1:(end-4)), '.fig'])
saveas(f, [file(1:(end-4)), '.jpg'])
end

%% subfunctions
function S_multi_boot_padded = get_bootstrap_consensus(S_multi_boot, dropped_rows)
[n_cells, n_windows, n_boots] = size(S_multi_boot);

% find often dropped rows and eliminate
often_dropped = sum(dropped_rows,2) > n_boots*0.5;
S_multi_boot = S_multi_boot(~often_dropped, :, :);
S_multi_boot = reshape(S_multi_boot, [], n_boots);

% replace remaining dropped entries with NaN and reshape
drop_mask = logical(repmat(dropped_rows(~often_dropped, :), n_windows, 1));
S_multi_boot(drop_mask) = NaN;

% generate shuffled null controls for finding consensus
S_multi_boot_null = S_multi_boot;

for i = 1:n_boots
    % find non-NaN value locations
    valid_idx = ~isnan(S_multi_boot(:,i));
    
    % extract values, randomly permute, and write to array
    valid_values = S_multi_boot(valid_idx, i);
    S_multi_boot_null(valid_idx, i) = valid_values(randperm(length(valid_values)));
end

% find signed, thresholded consensus
C_multi_boot = get_consensus_w_NaN(S_multi_boot);
C_multi_boot_null = get_consensus_w_NaN(S_multi_boot_null);

[C_boot_thresh] = threshold_consensus_from_C(C_multi_boot, C_multi_boot_null);

% get consensus module assignment
n_iter = 20;
Q = zeros(n_iter,1);
S_multi_boot_conn = zeros(size(C_boot_thresh,1), n_iter);
for i = 1:n_iter
    [S_multi_boot_conn(:,i), Q(i)] = get_modularity(C_boot_thresh, 1);
end
[~, max_idx] = max(Q);
S_multi_boot_conn = S_multi_boot_conn(:, max_idx);

S_multi_boot_padded = NaN(n_cells, n_windows);
S_multi_boot_padded(~often_dropped, :) = reshape(S_multi_boot_conn,[],n_windows);
end

function A_avg = average_allegiance_matrices(allegiance, dropped_rows)
    [~, n_boots] = size(dropped_rows);
    dropped_rows = logical(dropped_rows);
    for k = 1:n_boots
        allegiance(dropped_rows(:,k), :, k) = NaN;
        allegiance(:, dropped_rows(:,k), k) = NaN;
    end
    A_avg = mean(allegiance,3,'omitnan');
end

function [order, S] = sort_by_modularity(A, gamma)
n_iter = 5;
[B, ~] = modularity_w_sign(A, gamma);

%run multiple iterations to get consensus assignment
[S, ~] = genlouvain(B);
S = [S zeros(length(S), n_iter-1)];
for i = 2:n_iter
    [S(:,i), ~] = genlouvain(B);
end

C = get_consensus_w_NaN(S);
[B, ~] = modularity(C, gamma);
[S, ~] = genlouvain(B);

[~, order] = sort(S);
end

function RI_mat = get_recruitment_and_integration(allegiance, S, dropped_rows)
% find number of modules
n_modules = max(S);

% mask out diagonal and dropped rows
dropped_rows = logical(dropped_rows);
allegiance(dropped_rows, :) = NaN;
allegiance(:, dropped_rows) = NaN;
allegiance(logical(eye(size(allegiance)))) = NaN;

% initialize loop output
RI_mat = NaN(n_modules);

% loop through modules
for i = 1:n_modules
    for j = i:n_modules
        block_ij = allegiance(S == i, S == j);
        RI_mat(i, j) = mean(block_ij(:), 'omitnan');
        RI_mat(j,i) = RI_mat(i,j);
    end
end

end

function plot_bars_w_error(data)
% data indexed as bars x observations x groups
means = squeeze(mean(data,2,'omitnan'));
stdevs = squeeze(std(data, [], 2, 'omitnan'));

b = bar(means(:, :));
hold on

for c = 1:size(data,3)
    x = b(c).XEndPoints;
    errorbar(x, means(:,c), stdevs(:, c), 'k.')
end

hold off
end

function b = plot_horizontal_bars_w_error(data)
    means = squeeze(mean(data,2,'omitnan'));
    stdevs = squeeze(std(data, [], 2, 'omitnan'));

    b = barh(means);
    hold on;

    for c = 1:size(data,3)
        y = b(c).XEndPoints;
        x = means(:, c);
        dx = stdevs(:, c);

        % Horizontal-only error bars
        errorbar(x, y, ...
                 zeros(size(x)), zeros(size(x)), ... % no vertical error
                 dx, dx, ...
                 'k.', 'CapSize', 8)
    end

    hold off;
end

function [C_thresh] = threshold_consensus_from_C(C_multi, C_multi_null)
% uses output of get multi-slice modularity (module assignments + null
% control across multiple optimization runs) to get thresholded consensus
% matrices (frequency of co-clustering across runs)
%
% threshold is based on co-clustering at significantly higher than chance
% levels (C_pos)
%
% C_thresh also accounts for co-clustering at significantly lower than
% chance levels
%
% both outputs should be square with size = (neurons x windows)

null_vals = squareform(C_multi_null - eye(size(C_multi_null) ) );
[lL, uL] = bounds(null_vals);

lL = min(lL, mean(null_vals)-3*std(null_vals));
uL = max(uL, mean(null_vals)+3*std(null_vals));

% threshold to find pairs with
C_pos = C_multi;
C_pos(C_multi < uL) = 0;
C_pos = sparse(C_pos);

C_neg = C_multi;
C_neg(C_multi > lL) = 1;
C_neg = 1 - C_neg;

C_thresh = C_pos - C_neg;
C_thresh = sparse(C_thresh);
end

function c_map = one_color_gradient(color1, n_colors)
    c_map = (color1 - [1 1 1]).*gray(ceil(n_colors)) + [1 1 1];
end

function [gr, eq, le] = count_comparisons(A, B)
% Example arrays
% A = [1   4   NaN 7;
%      3   NaN 2   6];
% 
% B = [2   4   5   NaN;
%      1   2   2   7];

% Create a valid mask where neither A nor B is NaN
valid = ~isnan(A) & ~isnan(B);

% Logical comparisons (element-wise)
gt_mask = A > B & valid;   % A > B
eq_mask = A == B & valid;  % A == B
lt_mask = A < B & valid;   % A < B

% Count occurrences per row
gr = sum(gt_mask, 2);  % Greater-than count
eq = sum(eq_mask, 2);  % Equal count
le = sum(lt_mask, 2);  % Less-than count
end