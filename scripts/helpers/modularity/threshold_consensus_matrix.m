function [C_thresh, C_pos] = threshold_consensus_matrix(S_multi, S_multi_null)
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

% returns
C_multi = get_consensus(S_multi);
C_multi_null = get_consensus(S_multi_null);

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