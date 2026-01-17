function plotSplitViolin(dataA, dataB, colorA, colorB, xpos, labelStr, maxWidth)
% PLOTSPLITVIOLIN Plot a split violin comparison of two distributions.
%
% plotSplitViolin(dataA, dataB, colorA, colorB, xpos, labelStr, maxWidth)
%   dataA, dataB : numeric vectors (can contain NaN)
%   colorA, colorB : RGB triplets
%   xpos : x-position to place violin
%   labelStr : optional label for x-axis tick
%   maxWidth : optional max half-width of violin (default 0.4)

    if nargin < 7 || isempty(maxWidth)
        maxWidth = 0.4;
    end

    % Ensure column vectors and drop NaNs
    validPairs = ~isnan(dataA) & ~isnan(dataB);
    dataA = dataA(:); dataA = dataA(validPairs);
    dataB = dataB(:); dataB = dataB(validPairs);

    hold on

    % Early exit
    if isempty(dataA) && isempty(dataB)
        return
    end

    % Common evaluation grid
    allData = [dataA; dataB];
    y = linspace(min(allData), max(allData), 200);

    % Compute densities if nonempty
    fA = [];
    fB = [];
    if ~isempty(dataA)
        fA = computeDensity(dataA, y);
    end
    if ~isempty(dataB)
        fB = computeDensity(dataB, y);
    end

    % Joint normalization
    fAll = [fA(:); fB(:)];
    scale = maxWidth / max([fAll; eps]);
    if ~isempty(fA), fA = fA * scale; end
    if ~isempty(fB), fB = fB * scale; end

    % Plot halves if present
    if ~isempty(fA)
        plotHalfViolin(dataA, fA, y, colorA, xpos, 'left');
    end
    if ~isempty(fB)
        plotHalfViolin(dataB, fB, y, colorB, xpos, 'right');
    end

    % Optional x-axis label
    if nargin > 5 && ~isempty(labelStr)
        set(gca,'XTick',xpos,'XTickLabel',{labelStr})
    end

    %%% --- Add comparison metric above the violin ---
    if ~isempty(dataA) && ~isempty(dataB)
        p_val = mean(dataA > dataB);
        p_val = min(p_val, 1 - p_val);
        yl = ylim;
        
        % Extend y-limits upward to make space for text
        % ylim([yl(1), yl(2) + 0.1 * range(yl)]);
        
        y_text = yl(2) + 0.05 * range(yl);
        text(xpos, y_text, sprintf('%.3f', p_val), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','bottom', ...
            'Rotation', 45, ...
            'FontSize',9);
    end
end

% ---------------- Helper functions ----------------

function f = computeDensity(data, y)
% COMPUTEDENSITY Compute kernel density and clip to observed data range
    f = ksdensity(data, y);
    f(y < min(data) | y > max(data)) = 0;
end

function plotHalfViolin(data, f, y, color, xpos, side)
% PLOTHALFVIOLIN Draw a single half of a split violin with median
    switch side
        case 'left'
            fill([xpos - f, xpos, xpos], [y, max(y), min(y)], ...
                color, 'FaceAlpha',0.5,'EdgeColor','none');
            med = nanmedian(data);
            line([xpos - max(f), xpos], [med, med], 'Color', color, 'LineWidth',1.2);
        case 'right'
            fill([xpos + f, xpos, xpos], [y, max(y), min(y)], ...
                color, 'FaceAlpha',0.5,'EdgeColor','none');
            med = nanmedian(data);
            line([xpos, xpos + max(f)], [med, med], 'Color', color, 'LineWidth',1.2);
    end
end
