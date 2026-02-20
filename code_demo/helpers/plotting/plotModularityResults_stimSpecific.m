function [tl, ax1, ax3] = plotModularityResults_stimSpecific(data)
% PLOTMODULARITYRESULTS_STIMSPECIFIC
%   Creates a 6x3 tiled layout figure to plot modularity results
%
% Inputs in data struct:
%   A, B          : [time x trials] matrices
%   t             : [time x 1] vector
%   Ca1, Ca2      : [group x group x trials]
%   Cb1, Cb2
%   Da, Db        : [rows x time]
%   Ea1, Ea2      : [trials x 1]
%   Eb1, Eb2
%   Fa1, Fa2      : [rows x rows]
%   Fb1, Fb2
%   rowsA, rowsB  : string arrays for heatmap y-axis labels
%   colorA, colorB, colorBA : RGB triplets

figure;
tl = tiledlayout(6,3,'TileSpacing','compact','Padding','compact');

%% --- Row 1, Cols 1-2: Average traces
ax1 = nexttile(1,[1 2]);
[~, nSR] = plot_traces_w_shaded_90CI(data.t, data.A, data.colorA); hold on
[~, tSR] = plot_traces_w_shaded_90CI(data.t, data.B, data.colorB);
xlabel(''); ylabel('Modularity, Q');
%legend([nSR, tSR], ["naive", "trained"]);
ax1.XTick = 0:30:90;

%% Row 1, Col 3: split violin of Ca1/Cb1
ax2 = nexttile(3);
plotSplitViolinMatrix(data.Ca1, data.Cb1, data.colorA, data.colorB);
xlabel(''); ylabel('Stim 1'); title('Rec/Int');
ax2.YLim = [0 1.5]; ax2.YTick = [0 1];

%% Row 2, Cols 1-2: Difference trace B - A
ax3 = nexttile(4,[1 2]);
plot_traces_w_shaded_90CI(data.t, data.B - data.A, data.colorBA); hold on
yline(0,'r-','LineWidth',1)
xlabel(''); ylabel('Q_t - Q_n');
ax3.XTick = 0:30:90;

%% Row 2, Col 3: split violin of Ca2/Cb2
ax4 = nexttile(6);
plotSplitViolinMatrix(data.Ca2, data.Cb2, data.colorA, data.colorB);
xlabel(''); ylabel('Stim2');
ax4.YLim = [0 1.5]; ax4.YTick = [0 1];

%% Row 3, Cols 1-2: Heatmap Da
ax5 = nexttile(7,[1 2]);
imagesc(data.t, 1:size(data.Da,1), data.Da)
colormap(ax5, getOneColorGradient(data.colorA, max(data.Da(:))))
%colorbar
yticks(1:numel(data.rowsA))
yticklabels(data.rowsA)
xlabel(''); ylabel('');
ax5.XTick = 0:30:90;
ax5.CLim = ax5.CLim + [-0.5, 0.5];

%% Row 3, Col 3: splitViolin(Ea1,Eb1)
ax6 = nexttile(9);
title('Flexibility')
plotSplitViolin(data.Ea1, data.Eb1, data.colorA, data.colorB, 1);
xlabel(''); ylabel('');
%ax6.YLim = [0 1]; ax6.YTick = [0 1];
ax6.XLim = [0.5 1.5]; ax6.XTick = [];

%% Row 4, Cols 1-2: Heatmap Db
ax7 = nexttile(10,[1 2]);
imagesc(data.t, 1:size(data.Db,1), data.Db)
colormap(ax7, getOneColorGradient(data.colorB, max(data.Db(:))))
%colorbar
yticks(1:numel(data.rowsB))
yticklabels(data.rowsB)
xlabel('Time'); ylabel('');
ax7.XTick = 0:30:90;
ax7.CLim = ax7.CLim + [-0.5, 0.5];

%% Row 4, Col 3: splitViolin(Ea2,Eb2)
ax8 = nexttile(12);
plotSplitViolin(data.Ea2, data.Eb2, data.colorA, data.colorB, 1);
xlabel(''); ylabel('');
%ax8.YLim = [0 1]; ax8.YTick = [0 1]; 
ax8.XLim = [0.5 1.5]; ax8.XTick = [];
legend('Naive', '', 'Trained', 'Location', 'bestoutside')

%% Rows 5-6, Cols 1-2: imagesc of Fa1/Fb1, Fa2/Fb2
% Row 5
ax9 = nexttile(13);
imagesc(data.Fa1); colormap(ax9, gray); caxis([0 1]); xlabel(''); ylabel('');
yticks(1:numel(data.rowsA))
yticklabels(data.rowsA); ax9.XTick = [];
title('Stim 1')
ylabel('Naive')
ax10 = nexttile(14);
imagesc(data.Fa2); colormap(ax10, gray); caxis([0 1]); xlabel(''); ylabel('');
ax10.YTick = []; ax10.XTick = [];
title('Stim 2')

% Row 6
ax11 = nexttile(16);
imagesc(data.Fb1); colormap(ax11, gray); caxis([0 1]); xlabel(''); ylabel('');
yticks(1:numel(data.rowsB))
yticklabels(data.rowsB); ax11.XTick = [];
ylabel('Trained')
ax12 = nexttile(17);
imagesc(data.Fb2); colormap(ax12, gray); caxis([0 1]); xlabel(''); ylabel('');
ax12.YTick = []; ax12.XTick = [];

%% --- Link x-axes for all time-series plots
linkaxes([ax1, ax3, ax5, ax7], 'x') % link A, B, B-A, Da, Db
xlim(ax1, [0 data.t(end)])

linkaxes([ax6, ax8], 'y');
ax6.YLim = [0, ax6.YLim(2)*1.2];
end