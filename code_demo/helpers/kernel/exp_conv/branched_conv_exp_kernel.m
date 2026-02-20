function k = branched_conv_exp_kernel(params, t, branch_sizes)
% branched_conv_exp_kernel
% params: flat parameter vector [A1 gamma11 gamma12 ... A2 gamma21 ...]
% branch_sizes: vector with number of params per branch (incl. amplitude)
% t: time vector

% dt: sampling step
dt = t(2) - t(1);
nBranches = length(branch_sizes);
k = zeros(size(t));

idx = 1;
for b = 1:nBranches
    nParams = branch_sizes(b);
    branch_params = params(idx : idx+nParams-1);
    idx = idx + nParams;

    % Extract amplitude and gammas
    A = branch_params(1);
    gammas = branch_params(2:end);

    % Build exponential chain
    branch_k = exp(-gammas(1)*t) .* (t>=0);
    for g = 2:length(gammas)
        exp_kernel = exp(-gammas(g)*t) .* (t>=0);
        branch_k = conv(branch_k, exp_kernel, 'full') * dt;
        branch_k = branch_k(1:length(t));
    end

    % Add branch contribution
    k = k + A * branch_k;
end
end