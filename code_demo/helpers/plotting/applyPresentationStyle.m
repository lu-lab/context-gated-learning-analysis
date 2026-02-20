function f = applyPresentationStyle(f)
% applyPresentationStyle Applies a saved export style to the input figure
% and preserves original axes limits.
%
%   applyExportStyle(f) sets figure and axes properties according to
%   a saved export style (parsed manually from a .txt style file).
%
%   Input:
%       f - Handle to a MATLAB figure

    if nargin < 1 || ~ishandle(f) || ~strcmp(get(f, 'Type'), 'figure')
        error('Input must be a valid figure handle.');
    end

    % General figure settings
    set(f, 'Color', [1 1 1]);  % Background white
    set(f, 'RendererMode', 'auto');  % Renderer auto

    % Apply to all axes
    ax = findall(f, 'Type', 'axes');
    for i = 1:length(ax)
        % Store current limits
        xlim = get(ax(i), 'XLim');
        ylim = get(ax(i), 'YLim');
        if isprop(ax(i), 'ZLim')
            zlim = get(ax(i), 'ZLim');
        else
            zlim = [];
        end

        % Apply style settings
        set(ax(i), ...
            'FontSize', max(8, round(10 * 140 / 100)), ...
            'FontWeight', 'bold', ...
            'LineWidth', 2, ...
            'Box', 'on');

        % Restore limits
        set(ax(i), 'XLim', xlim, 'YLim', ylim);
        if ~isempty(zlim)
            set(ax(i), 'ZLim', zlim);
        end

        % Lock axis mode to prevent future changes
        set(ax(i), 'XLimMode', 'manual', ...
                   'YLimMode', 'manual');
        if ~isempty(zlim)
            set(ax(i), 'ZLimMode', 'manual');
        end
    end

    % Apply line width to line-like objects
    lineObjs = findall(f, 'Type', 'line');
    for i = 1:length(lineObjs)
        set(lineObjs(i), 'LineWidth', 2);
    end

    % Apply to other common plot types
    otherTypes = {'scatter', 'bar', 'histogram', 'stairs', 'errorbar'};
    for t = 1:length(otherTypes)
        objs = findall(f, 'Type', otherTypes{t});
        for i = 1:length(objs)
            if isprop(objs(i), 'LineWidth')
                set(objs(i), 'LineWidth', 2);
            end
        end
    end
end