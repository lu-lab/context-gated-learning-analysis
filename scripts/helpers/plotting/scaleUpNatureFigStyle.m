function f = scaleUpNatureFigStyle(f, scaleFactor)
% scaleUpNatureFigStyle scales up fonts, line widths, and on-screen size 
% for more comfortable viewing without changing export dimensions.
%
%   f = scaleUpNatureFigStyle(f)
%   f = scaleUpNatureFigStyle(f, scaleFactor)
%
%   Inputs:
%       f           - figure handle
%       scaleFactor - scalar multiplier (default 1.5)
%
%   This multiplies:
%       - Font sizes (axes, legends, colorbars, text not tied to axes)
%       - Line widths
%       - On-screen figure size (Position(3:4))
%
%   Export settings (PaperUnits, PaperPosition, PaperSize) are unchanged.

    if nargin < 1 || ~ishandle(f) || ~strcmp(get(f,'Type'),'figure')
        error('Input must be a valid figure handle.');
    end
    if nargin < 2
        scaleFactor = 1.5;
    end

    % --- Scale figure position (on screen only) ---
    oldUnits = get(f,'Units');
    set(f,'Units','pixels'); % work in pixels for screen scaling
    pos = get(f,'Position');
    pos(3:4) = pos(3:4) * scaleFactor; % scale width & height
    set(f,'Position',pos);
    set(f,'Units',oldUnits); % restore units

    % --- Axes (includes tick labels, axis labels, titles) ---
    ax = findall(f, 'Type', 'axes');
    for i = 1:numel(ax)
        set(ax(i), 'FontSize', get(ax(i),'FontSize') * scaleFactor, ...
                   'LineWidth', get(ax(i),'LineWidth') * scaleFactor);
    end

    % --- Legends ---
    legObjs = findall(f, 'Type', 'legend');
    for i = 1:numel(legObjs)
        set(legObjs(i), 'FontSize', get(legObjs(i),'FontSize') * scaleFactor);
    end

    % --- Colorbars ---
    cbObjs = findall(f, 'Type', 'colorbar');
    for i = 1:numel(cbObjs)
        set(cbObjs(i), 'FontSize', get(cbObjs(i),'FontSize') * scaleFactor, ...
                       'LineWidth', get(cbObjs(i),'LineWidth') * scaleFactor);
    end

    % --- Free-floating text (not tied to axes, e.g. annotations) ---
    txtObjs = findall(f, 'Type', 'text');
    % remove text that belongs to axes (tick labels, titles, axis labels)
    txtObjs = setdiff(txtObjs, findall(ax, 'Type', 'text'));
    for i = 1:numel(txtObjs)
        set(txtObjs(i), 'FontSize', get(txtObjs(i),'FontSize') * scaleFactor);
    end

    % --- Lines ---
    lineObjs = findall(f, 'Type', 'line');
    for i = 1:numel(lineObjs)
        set(lineObjs(i), 'LineWidth', get(lineObjs(i),'LineWidth') * scaleFactor);
    end

    % --- Other plot types ---
    otherTypes = {'scatter','bar','histogram','stairs','errorbar'};
    for t = 1:numel(otherTypes)
        objs = findall(f, 'Type', otherTypes{t});
        for i = 1:numel(objs)
            if isprop(objs(i),'LineWidth')
                set(objs(i),'LineWidth', get(objs(i),'LineWidth') * scaleFactor);
            end
        end
    end
end
