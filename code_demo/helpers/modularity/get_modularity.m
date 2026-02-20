function [S, Q] = get_modularity(A, gamma)
% basic modularity calculation, no iteration
% assumes A is symmetric (undirected) matrix

% calculate modularity matrix, B
[B, twom] = modularity_w_sign(A,gamma);

% run louvain optimization (single run)
[S, Q] = genlouvain(B);
Q = Q/twom;
end