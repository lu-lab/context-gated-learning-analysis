function f = applyNatureFigStyleResize(f, figWidth, figHeight)
% applyNatureFigStyle standardizes figure style for Nature-style figures.
%
%   Inputs:
%       f         - figure handle
%       figWidth  - width in inches (e.g., 3.5 for single column)
%       figHeight - height in inches
%
%   Fonts: 6 pt
%   Line widths: 0.5 pt
%
%   Use with:
%       f = figure;
%       plot(...);
%       applyNatureFigStyle(f, 3.5, 2.5);
%       print(f, '-dpdf', '-painters', 'myFig.pdf');

    if nargin < 1 || ~ishandle(f) || ~strcmp(get(f,'Type'),'figure')
        error('Input must be a valid figure handle.');
    end
    if nargin < 2
        figWidth = 3.5;  % inches (Nature single column)
        figHeight = 2.5;
    end

    % --- Set figure paper size ---
    set(f, 'Units', 'inches', 'Position', [1 1 figWidth figHeight], ...
           'PaperUnits', 'inches', 'PaperPosition', [0 0 figWidth figHeight], ...
           'PaperSize', [figWidth figHeight]);

    % --- Axes styling ---
    ax = findall(f, 'Type', 'axes');
    for i = 1:numel(ax)
        set(ax(i), 'FontSize', 5, ...
                   'LineWidth', 0.5, ...
                   'Box', 'on');
    end

    % --- Text objects (axis labels, titles, tiledlayout labels, legends, etc.)
    txtObjs = findall(f, 'Type', 'text');
    set(txtObjs, 'FontSize', 6);
    
    % --- Legends and colorbars (they use different containers)
    legObjs = findall(f, 'Type', 'legend');
    set(legObjs, 'FontSize', 6);
    
    cbObjs = findall(f, 'Type', 'colorbar');
    set(cbObjs, 'FontSize', 6, 'LineWidth', 0.5);

    % --- Line-like objects ---
    lineObjs = findall(f, 'Type', 'line');
    set(lineObjs, 'LineWidth', 1);

    % --- Other object types ---
    otherTypes = {'scatter','bar','histogram','stairs','errorbar'};
    for t = 1:numel(otherTypes)
        objs = findall(f, 'Type', otherTypes{t});
        for i = 1:numel(objs)
            if isprop(objs(i),'LineWidth')
                set(objs(i),'LineWidth',0.5);
            end
        end
    end
end