%% AUC heatmaps for Figure 1 (0–10 s window)
% Assumes your 'results' struct and the ID lists are available as in Figure 1:
%   - results(k).inputID   (string/char)
%   - results(k).outputID  (string/char)
%   - results(k).Training  ('naive' or 'trained')
%   - results(k).kernels   (time x bootstraps)
% And the groups:
%   keySensory, keyInter, keyMotor  (string/cellstr)
%
% If not already loaded:
path = "results/100225_kernelPlots";
resultsFile = "PA-buffer_nBoot2000_kernelResults.mat";
load(fullfile(path, resultsFile));

%% Parameters
Fs    = 5;                % Hz (as in your Figure 1 code)
dt    = 1/Fs;             % 0.2 s
tMax  = 30;               % seconds (AUC window 0–30 s)
winLo = 0; winHi = tMax;

% Define the matrix layout used in Figure 1
inputID  = [keyInter, keySensory]; %, keyInter];
outputID = [keyInter, keyMotor];

% Ensure string arrays for robust matching
inputID  = string(inputID);
outputID = string(outputID);

% Extract meta from results (as strings)
resIn   = string([results.inputID]);
resOut  = string([results.outputID]);
resCond = string({results.Training});

% Time vector from first entry (or infer length)
kernelLength = size(results(1).kernels, 1);
tFull = (0:kernelLength-1) * dt;

% Time mask for 0–10 s
tMask = (tFull >= winLo) & (tFull <= winHi);

% Preallocate AUC matrices
nIn  = numel(inputID);
nOut = numel(outputID);
AUC_naive   = NaN(nIn, nOut);
AUC_trained = NaN(nIn, nOut);

%% Compute AUC per pair (signed, trapezoidal integration on mean bootstrap kernel)
for i = 1:nIn
    for j = 1:nOut
        % (Optionally leave diagonal as NaN)
        if inputID(i) == outputID(j)
            continue
        end

        % Locate the naïve / trained entries for this pair
        idxN = (resIn == inputID(i)) & (resOut == outputID(j)) & (resCond == "naive");
        idxT = (resIn == inputID(i)) & (resOut == outputID(j)) & (resCond == "trained");

        % Extract kernels if present
        if any(idxN)
            KNaive = results(find(idxN,1)).kernels;        % time x bootstraps
            mNaive = mean(KNaive(tMask, :), 2, 'omitnan'); % mean over bootstraps
            AUC_naive(i, j) = trapz(tFull(tMask), mNaive); % signed area
        end
        if any(idxT)
            KTrain = results(find(idxT,1)).kernels;
            mTrain = mean(KTrain(tMask, :), 2, 'omitnan');
            AUC_trained(i, j) = trapz(tFull(tMask), mTrain);
        end
    end
end

%% Difference: trained - naive
% AUC_diff = AUC_trained - AUC_naive;
AUC_diff = 2 * (AUC_trained - AUC_naive)./(abs(AUC_trained) + abs(AUC_naive));

%% Plot three heatmaps (Naïve, Trained, Trained−Naïve)
figW = 180/25.4; figH = 70/25.4;  % ~180 mm x 70 mm
f = figure('Units','inches','Position',[1 1 figW figH]);
tiledL = tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

% Consistent limits for naïve/trained panels
allVals = [AUC_naive(:); AUC_trained(:)];
cl1 = [min(allVals,[],'omitnan'), max(allVals,[],'omitnan')];
if ~all(isfinite(cl1)) || diff(cl1)==0, cl1 = [-1, 1]; end

% Symmetric limits for difference panel
maxAbs = max(abs(AUC_diff(:)), [], 'omitnan');
if ~isfinite(maxAbs) || maxAbs==0, maxAbs = 1; end
cl2 = [-maxAbs, maxAbs];

% Helper to draw one heatmap with labels and NaN transparency
drawAUCmap = @(ax, M, climits, ttl) ...
    drawAUCHeatmap(ax, M, climits, ttl, inputID, outputID);

% ----- Diverging blue-white-red colormap centered on 0 -----
cmap = redbluecmap(256);

cl1= [-2 2];
% 1) Naïve
ax1 = nexttile(tiledL,1);
drawAUCmap(ax1, AUC_naive, cl1, 'AUC (Naïve, 0–10 s)');
colormap(ax1, cmap); caxis(ax1, cl1); colorbar(ax1);

% 2) Trained
ax2 = nexttile(tiledL,2);
drawAUCmap(ax2, AUC_trained, cl1, 'AUC (Trained, 0–10 s)');
colormap(ax2, cmap); caxis(ax2, cl1); colorbar(ax2);

cl2= [-1 1] * 2;
% 3) Trained – Naïve
ax3 = nexttile(tiledL,3);
drawAUCmap(ax3, AUC_diff, cl2, 'AUC Δ (Trained − Naïve, 0–10 s)');
colormap(ax3, cmap); caxis(ax3, cl2); colorbar(ax3);


%% ------------- Helpers -------------

function drawAUCHeatmap(ax, M, climits, ttl, rowIDs, colIDs)
    imagesc(ax, M, climits);
    set(ax, 'YDir', 'reverse');  % <-- flip y-axis visually
    % Mask NaNs so they show as background
    set(get(ax,'Children'), 'AlphaData', ~isnan(M));
    % Ticks/labels
    ax.XTick = 1:numel(colIDs); ax.YTick = 1:numel(rowIDs);
    ax.XTickLabel = colIDs; ax.YTickLabel = rowIDs;
    ax.XTickLabelRotation = 45;
    box(ax,'on'); title(ax, ttl, 'FontSize', 9);
end

function cmap = redbluecmap(n)
% Simple diverging red-blue colormap (symmetric)
    if nargin < 1 || isempty(n), n = 256; end
    r = [(0:n/2-1)/(n/2), ones(1,n/2)];
    g = [(0:n/2-1)/(n/2), (n/2-1:-1:0)/(n/2)];
    b = [ones(1,n/2), (n/2-1:-1:0)/(n/2)];
    cmap = [r(:), g(:), b(:)];
end

