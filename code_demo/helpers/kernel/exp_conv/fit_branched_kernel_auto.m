function [best_k, best_params, best_branch_sizes, fit_table] = ...
         fit_branched_kernel_auto(x, y, kernel_length, conv_range, max_branches, thresh)
% Fit branched exponential convolution kernel with automatic model selection
%
% Inputs:
%   x, y          : input and output signals
%   kernel_length : kernel support
%   conv_range    : vector of #convolutions per branch to test (e.g. 3:5)
%   max_branches  : maximum number of branches (e.g. 2)
%   thresh        : min variance explained improvement to accept complexity
%
% Outputs:
%   best_k           : fitted kernel
%   best_params      : parameters of best fit
%   best_branch_sizes: structure of #params per branch
%   fit_table        : record of tested models

t = 0:(kernel_length-1);

% Initialize storage
results = struct('branches',{},'branch_sizes',{},'params',{},'varExp',{});
best_varExp = -Inf;

% Start with single branch
prevBranchSizes = [];
prevParams = [];

for nBranches = 1:max_branches
    for nConv = conv_range
        branchSizes = [prevBranchSizes, nConv];
        param0 = [prevParams, [(-1)^(nBranches - 1)], 0.2:];
    end
end

while nBranches <= max_branches && improved
    improved = false; % reset
    
    % Test different convolution counts for this branch
    if nBranches == 1
        % first branch only
        branch_configs = num2cell(conv_range, 2);
    else
        % expand second (or later) branch
        branch_configs = cell(length(conv_range),1);
        for i = 1:length(conv_range)
            branch_configs{i} = [best_branch_sizes, conv_range(i)];
        end
    end
    
    for bc = 1:length(branch_configs)
        branch_sizes = branch_configs{bc};
        
        [k_fit, params_fit] = fit_branched_kernel(x, y, kernel_length, branch_sizes, params0);
        
        % Compute fit quality
        y_hat = conv(x, k_fit, 'full'); y_hat = y_hat(1:length(y));
        varExp = 1 - var(y - y_hat)/var(y);
        
        % Save result
        res.branches = nBranches;
        res.branch_sizes = branch_sizes;
        res.params = params_fit;
        res.varExp = varExp;
        results(end+1) = res; %#ok<AGROW>
        
        % Check improvement
        if varExp > best_varExp + thresh
            best_varExp = varExp;
            best_params = params_fit;
            best_k = k_fit;
            best_branch_sizes = branch_sizes;
            improved = true;
        end
    end
    
    % If improved, allow adding a new branch
    if improved
        nBranches = nBranches + 1;
    else
        break
    end
end

% Return a summary table for debugging/inspection
fit_table = struct2table(results);
end