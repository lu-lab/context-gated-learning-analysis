function [S_multi, S_multi_null] = get_multislice_modularity_reindex(A, gamma, omega, n_iter)
% assigns neurons to modules based on multi-slice modularity objective
% function (see paper from Mucha et. al. Science 2006)
%
% results are variable from run-to-run, recommend doing 20-100 iterations,
% then finding consensus across runs after thresholding consensus by null
% control consensus values
%
% Inputs:
% A: neurons x neurons x time array of correlations between neurons
% gamma: structural resolution parameter, larger
% omega: temporal/slice coupling parameter
% n_iter: number of optimization runs to perform 
% 
% Outputs:
% S_multi: module assignments, (neurons x timepoints) X (optimization runs)
% S_multi_null: shuffle columns of S_multi to control for random chance of co-clustering between neurons

% convert input corr matrix array A (n x n x t) into 1D cell array
[n_cells, ~, n_windows] = size(A);
A_cell = squeeze(mat2cell(A, n_cells, n_cells, ones(n_windows,1)));

% calculate multi-slice modularity matrix, B and get module assignments
[B, ~] = multiaspect_w_sign(A_cell, gamma, omega, 'ot');
S_multi = zeros(size(B,1), n_iter);
S_multi_null = zeros(size(B,1), n_iter);

parfor i = 1:n_iter
    [temp, ~] = genlouvain(B);
    
    % reshape modules, re-index, and linearize again for storage
    temp = reshape(temp, [n_cells, n_windows]);
    temp = reindex_modules(temp);
    temp = temp(:);
    
    S_multi(:,i) = temp;
    S_multi_null(:,i) = temp(randperm(n_cells*n_windows),:);
end
end