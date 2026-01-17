function S_bootConn = getBootstrapConsensus(S_boot)
% get dimensions and NaN out any zeros (missing neurons)
[nCells, nTimepoints, nBoots] = size(S_boot);
S_boot(S_boot == 0) = NaN;

% parameters for consensus clustering
gamma = 1;
n_iter = 20;

% initialize output array and loop through timepoints to find
% allegiance matrix across bootstraps for each timepoint
S_bootConn = zeros(nCells, nTimepoints);
for t = 1:nTimepoints
    % find allegiance matrix
    C = get_consensus_w_NaN(squeeze(S_boot(:,t,:)));
    
    % run consensus clustering
    S_bootConn(:, t) = get_modularity_consensus(C, gamma, n_iter);
end

S_bootConn = reindex_modules(S_bootConn);
end