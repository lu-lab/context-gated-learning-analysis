function colorGradient = getOneColorGradient(baseColor, levels)
% GETONECOLORGRADIENT Generate a gradient from off white to baseColor.
%
% colorGradient = getOneColorGradient(baseColor, levels)
%   baseColor : [1x3] RGB triplet
%   levels    : number of gradient levels
%
% Returns [levels x 3] array of RGB values.

    % Ensure row vector
    baseColor = baseColor(:)';  
    
    % Fractional steps (skips pure white)
    frac = linspace(0,1,levels+1)';  
    frac = frac(2:end);
    
    % Interpolate from white toward baseColor
    colorGradient = [1 1 1] + frac .* (baseColor - 1);

end