function S_ind = get_reindexed_singleSliceModules(A, gamma, nIter)
% get_reindexed_singleSliceModules  
%   returns module assignments (S_ind) for input sliding window correlation
%   matrix A (dim = nodes x nodes x time), based on Louvain optimization
%   for individual windows (instead of multi-slice optimization)
%
%   INPUTS:
%       A       : [nodes x nodes x time] sliding window correlation matrix, or some other description of time-varying network structure
%       gamma   : [scalar] structural resolution parameter, controls average module size
%       nIter   : [scalar] number of GenLouvain optimization runs before finding consensus assignment across runs
%
%   OUTPUTS:
%       S_ind   : [nodes x time] reindexed single-slice module assignment

% loop through timepoints and get module assignments
[nNodes, ~, nTimepoints] = size(A);
S_ind = zeros(nNodes, nTimepoints);
for t = 1:nTimepoints
    % note, just run optimization on A, diagonal should be zeroed out in
    % higher-level wrapper script
    S_ind(:, t) = get_modularity_consensus(A(:,:,t), gamma, nIter);
end

% reindex module assignemnts across timepoints
S_ind = reindex_modules(S_ind);
end