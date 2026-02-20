function [order, S] = sort_by_modularity(A, gamma)
n_iter = 5;
[B, ~] = modularity_w_sign(A, gamma);

%run multiple iterations to get consensus assignment
[S, ~] = genlouvain(B);
S = [S zeros(length(S), n_iter-1)];
for i = 2:n_iter
    [S(:,i), ~] = genlouvain(B);
end

C = get_consensus(S);
[B, ~] = modularity(C, gamma);
[S, ~] = genlouvain(B);

[~, order] = sort(S);
end