%% load bootstrapped kernel fit results
path = "results/100225_kernelPlots";
resultsFile = "OP-PA_nBoot2000_kernelResults.mat"; % enter results file to plot kernels and input traces from
load(fullfile(path, resultsFile))

%% plot all kernels from results struct
inputID  = [keySensory, keyInter];   % cellstr or string vector of input IDs
outputID = [keyInter, keyMotor];  % cellstr or string vector of output IDs

% Colors for naive and trained
nColor = '888666';
tColor = '6b3e98';
% convert color to RGB if needed
if ischar(nColor)
    nColor = sscanf(nColor, '%2x%2x%2x', [1 3])/255;
end
if ischar(tColor)
    tColor = sscanf(tColor,'%2x%2x%2x', [1 3])/255;
end

% Create tiled layout
% create figure with desired physical size
figW = 150/25.4; % width in inches
figH = 130/25.4; % height in inches
f = figure('Units','inches','Position',[1 1 figW figH]);
tiledL = tiledlayout(numel(inputID), numel(outputID), 'TileSpacing','tight', 'Padding','compact');

% Time vector for kernel
kernelLength = size(results(1).kernels,1); % assumes all kernels same length
t = 1:kernelLength; t = (t - 1)/5;

for i = 1:numel(inputID)
    for j = 1:numel(outputID)
        
        % Skip diagonal
        if inputID(i) == outputID(j)
            nexttile;
            ax = gca; ax.XTick = [];
            if i == numel(inputID)
                xlabel(outputID(j));
                ax.XTick = [0 30];
            end
            if j == 1
                ylabel(inputID(i));
            else
                ax.YTick = [];
            end
            continue
        end
        
        % Find results entries for this input/output pair
        pairIdx = [results.inputID] == inputID(i) & [results.outputID] == outputID(j);
        
        % Separate naive vs trained
        idxN = pairIdx & [results.Training] == 'naive';
        idxT = pairIdx & [results.Training] == 'trained';
        
        nexttile;
        
        % Extract kernels
        kernelsN = results(find(idxN,1)).kernels;
        kernelsT = results(find(idxT,1)).kernels;

        % Normalize kernels to bounds of -1 + 1;
        bounds = prctile([mean(kernelsN, 2); mean(kernelsT, 2)], [0 100]);
        kernelsN = kernelsN/max(abs(bounds));
        kernelsT = kernelsT/max(abs(bounds));
        
        hold on
%         plot_traces_w_shaded_STdev(t, kernelsN, nColor);
%         plot_traces_w_shaded_STdev(t, kernelsT, tColor);
 
        plot_traces_w_shaded_SEM(t, kernelsN, nColor);
        plot_traces_w_shaded_SEM(t, kernelsT, tColor);

%         plot_traces_w_shaded_95CI(t, kernelsN, nColor);
%         plot_traces_w_shaded_95CI(t, kernelsT, tColor);
        hold off
        ax = gca; ax.XTick = []; 
        ax.XLim = [0 30];
        ax.YLim = [-1.5 1.5];
        
        % Minimal formatting
        if i == numel(inputID)
            xlabel(outputID(j));
            ax.XTick = [0 30];
        end
        if j == 1
            ylabel(inputID(i));
        else
            ax.YTick = [];
        end
        box on
    end
end

xlabel(tiledL, 'Output', 'FontSize', 6);
ylabel(tiledL, 'Input',  'FontSize', 6);

f = applyNatureFigStyleResize(f, figW, figH);
print(f, '-dpdf', '-painters', extractBefore(resultsFile, "kernelResults") + "kernelMatrixSEM.pdf")
% scale up for on-screen viewing after export
f = scaleUpNatureFigStyle(f, 2);

%% plot inputs for all sensory neurons
% Assume targetIDs1, targetIDs2, targetIDs3 are string vectors
idLists = {keySensory, keyInter, keyMotor};
nRows   = numel(idLists);
nCols   = max(cellfun(@numel, idLists));

% --- create top-level figure ---
f = figure;

% set colormap and trace colors
TraceCmap = getMatplotlibColormap('RdBu', 256);
TraceCmap = TraceCmap(end:-1:1,:);
nColor = nColor; % just cary forward previous colors
tColor = tColor; 

% Each metaTile is 3 "sub-tiles" tall, so total rows = nRows*3
metaLayout = tiledlayout(nRows*3, nCols, 'TileSpacing','tight','Padding','compact');
title(metaLayout, targetStim + " heatmaps by ID group", 'FontSize', 6);

t = (1:451)/5; % shared time vector

% Helper function to convert metaTile row/col to linear tile indices for subplots
getTileIdx = @(r_meta, c_meta, subRow) (r_meta-1)*3*nCols + (subRow-1)*nCols + c_meta;

% Loop over metaRows
for r = 1:nRows
    thisList = idLists{r};
    
    for c = 1:nCols
        if c > numel(thisList)
            % skip empty metaTiles
            continue
        end
        
        thisID = thisList(c);
        
        % --- subset targetData for this input ID ---
        idx_in = strcmp(targetData.NeuronID, thisID);
        X_trials   = targetData{idx_in, end-450:end};
        X_training = string(targetData.Training(idx_in));
        
        X_naive   = X_trials(X_training == "naive",:);
        X_trained = X_trials(X_training == "trained",:);
        
        clims = prctile([X_naive(:); X_trained(:)], [2.5 97.5]);
        clims = [-1 1]*max(abs(clims));

        % --- top row: mean ± SEM ---
        ax1 = nexttile(metaLayout, getTileIdx(r,c,1)); hold(ax1,'on');
        [~, nSEM] = plot_traces_w_shaded_SEM(t, X_naive',   nColor);
        [~, tSEM] = plot_traces_w_shaded_SEM(t, X_trained', tColor);
        
        %legend(ax1,[nSEM, tSEM], {'Naive','Trained'},'Location','best');
        ax1.Title.String = {thisID + ...
            " (n " + num2str(height(X_naive)) + ", t " + num2str(height(X_trained)) + ")"};
        xlim(ax1,[0 90]);
        hold(ax1,'off');
        
        % --- middle row: naive heatmap ---
        ax2 = nexttile(metaLayout, getTileIdx(r,c,2));
        [~,sortIdxN] = sort(mean(X_naive(:,151:300),2,'omitnan'));
        imagesc(ax2, t, 1:length(sortIdxN), X_naive(sortIdxN,:), clims);
        colormap(ax2,TraceCmap); %colorbar(ax2);
        
        % --- bottom row: trained heatmap ---
        ax3 = nexttile(metaLayout, getTileIdx(r,c,3));
        [~,sortIdxT] = sort(mean(X_trained(:,151:300),2,'omitnan'));
        imagesc(ax3, t, 1:length(sortIdxT), X_trained(sortIdxT,:), clims);
        colormap(ax3,TraceCmap); %colorbar(ax3);
        %xlabel(ax3,'Time (samples)'); 
        
        % formatting
        ax1.XTick = []; ax2.XTick = []; ax3.XTick = [];
        ax1.XLim = [0 90]; ax2.XLim = [0 90]; ax3.XLim = [0 90];
        % ax1.YTick = []; 
        ax2.YTick = []; ax3.YTick = [];
        if c == 1
            ylabel(ax1,'dR/Ro');
            ylabel(ax2,'Naive');
            ylabel(ax3,'Trained');
        end
        if r < nRows
            if c > numel(idLists{r+1}), ax3.XTick = 0:30:90; end
        else
            ax3.XTick = 0:30:90;
        end
    end
end

f = applyNatureFigStyleResize(f, 150/25.4, 150/25.4);
print(f, '-dpdf', '-painters', extractBefore(resultsFile, "kernelResults") + "InputTraces.pdf")
% scale up for on-screen viewing after export
f = scaleUpNatureFigStyle(f, 2);

%% plot figure to get legend
% figure
% [~, nSEM] = plot_traces_w_shaded_SEM(t, X_naive',   nColor);
% hold on
% [~, tSEM] = plot_traces_w_shaded_SEM(t, X_trained', tColor);
% legend([nSEM, tSEM], {'Naive','Trained'},'Location','best');
% f = gcf;
% f = applyNatureFigStyleResize(f, 150/25.4, 150/25.4);