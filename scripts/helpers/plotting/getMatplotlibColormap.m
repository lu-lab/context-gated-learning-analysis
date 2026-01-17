function cmap = getMatplotlibColormap(name, nColors)
    % getMatplotlibColormap Return an [nColors x 3] RGB colormap
    %    name: string, e.g. "RdBu", "viridis", "plasma"
    %    nColors: number of points (default 256)
    
    if nargin < 2, nColors = 256; end
    
    switch lower(name)
        case 'rdbu'
            % RdBu colormap control points from matplotlib (_RdBu_data)
            baseRGB = [ ...
                0.40392156862745099   0.00000000000000000   0.12156862745098039;  % dark red
                0.69803921568627447   0.09411764705882353   0.16862745098039217;
                0.83921568627450982   0.37647058823529411   0.30196078431372547;
                0.95686274509803926   0.64705882352941180   0.50980392156862742;
                0.99215686274509807   0.85882352941176465   0.78039215686274510;
                0.96862745098039216   0.96862745098039216   0.96862745098039216;  % near white midpoint
                0.81960784313725488   0.89803921568627454   0.94117647058823528;
                0.57254901960784310   0.77254901960784317   0.87058823529411766;
                0.26274509803921570   0.57647058823529407   0.76470588235294112;
                0.12941176470588237   0.40000000000000000   0.67450980392156867;
                0.01960784313725490   0.18823529411764706   0.38039215686274508]; % dark blue
        otherwise
            error('Colormap "%s" not implemented yet.', name);
    end
    
    % interpolate to requested size
    x = linspace(1, size(baseRGB,1), nColors);
    xi = 1:size(baseRGB,1);
    cmap = interp1(xi, baseRGB, x, 'linear');
end