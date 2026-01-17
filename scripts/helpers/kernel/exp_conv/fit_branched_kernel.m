function [k_fit, params_fit] = fit_branched_kernel(x, y, kernel_length, branch_sizes, params0)

nParamsTotal = sum(branch_sizes);
if length(params0) ~= nParamsTotal
    error('Length of params0 does not match branch_sizes.');
end

% Fit a branched exponential convolution kernel
t = 0:(kernel_length-1);

% Initialize bounds
lb = [];
ub = [];
for b = 1:length(branch_sizes)
    nParams = branch_sizes(b);
    
    % constrain decay constants to be non-negative
    lb = [lb -Inf zeros(1,nParams-1)];
    ub = [ub  Inf   Inf(1,nParams-1)];
end

opts = optimoptions('lsqnonlin','MaxFunctionEvaluations',2000);
params_fit = lsqnonlin(@(p) branched_conv_error(p,x,y,t,branch_sizes), ...
                       params0, lb, ub, opts);

% Output final kernel
k_fit = branched_conv_exp_kernel(params_fit, t, branch_sizes);
k_fit = k_fit(:);
end