function S_multi_boot_conn = getBootstrapConsensusMulti(S_multi_boot)
[n_cells, n_windows, n_boots] = size(S_multi_boot);

% if only one bootstrap is fed in, return input as "consensus"
if n_boots == 1
    S_multi_boot_conn = S_multi_boot;
    return
end

% reshape S_multi_boot
S_multi_boot = reshape(S_multi_boot, [], n_boots);

% replace remaining dropped entries with NaN and reshape
S_multi_boot(S_multi_boot == 0) = NaN;

% generate shuffled null controls for finding consensus
S_multi_boot_null = S_multi_boot;

for i = 1:n_boots
    % find non-NaN value locations
    valid_idx = ~isnan(S_multi_boot(:,i));
    
    % extract values, randomly permute, and write to array
    valid_values = S_multi_boot(valid_idx, i);
    S_multi_boot_null(valid_idx, i) = valid_values(randperm(length(valid_values)));
end

% find signed, thresholded consensus
C_multi_boot = get_consensus_w_NaN(S_multi_boot);
C_multi_boot_null = get_consensus_w_NaN(S_multi_boot_null);

[C_boot_thresh] = threshold_consensus_from_C(C_multi_boot, C_multi_boot_null);

% get consensus module assignment
n_iter = 20;
Q = zeros(n_iter,1);
S_multi_boot_conn = zeros(size(C_boot_thresh,1), n_iter);
for i = 1:n_iter
    [S_multi_boot_conn(:,i), Q(i)] = get_modularity(C_boot_thresh, 1);
end
[~, max_idx] = max(Q);
S_multi_boot_conn = S_multi_boot_conn(:, max_idx);
S_multi_boot_conn = reshape(S_multi_boot_conn, [n_cells, n_windows]);

end

function [C_thresh] = threshold_consensus_from_C(C_multi, C_multi_null)
% uses output of get multi-slice modularity (module assignments + null
% control across multiple optimization runs) to get thresholded consensus
% matrices (frequency of co-clustering across runs)
%
% threshold is based on co-clustering at significantly higher than chance
% levels (C_pos)
%
% C_thresh also accounts for co-clustering at significantly lower than
% chance levels
%
% both outputs should be square with size = (neurons x windows)

null_vals = squareform(C_multi_null - eye(size(C_multi_null) ) );
[lL, uL] = bounds(null_vals);

lL = min(lL, mean(null_vals)-3*std(null_vals));
uL = max(uL, mean(null_vals)+3*std(null_vals));

% threshold to find pairs with
C_pos = C_multi;
C_pos(C_multi < uL) = 0;
C_pos = sparse(C_pos);

C_neg = C_multi;
C_neg(C_multi > lL) = 1;
C_neg = 1 - C_neg;

C_thresh = C_pos - C_neg;
C_thresh = sparse(C_thresh);
end