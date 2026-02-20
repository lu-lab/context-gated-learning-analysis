function [S_conn, Q_conn, S_raw, Q_raw] = get_modularity_consensus(A, gamma, n_iter)
% returns consensus module assignment across n_iter optimization runs of
% community detection on input matrix A, with resolution parameter gamma
%
%   INPUTS:
%       A       : [nodes x nodes], input correlation matrix
%       gamma   : resolution parameter, controls average module size
%       n_iter  : number of optimization runs before finding consensus
%
%   OUTPUTS:
%       S_conn  : [nodes x 1], consensus module assignment
%       Q_conn  : modularity of A, based on S_conn
%       S_raw   : [nodes x n_iter], raw module assignments of individual optimization runs
%       Q_raw   : [n_iter x 1], modularity of individual optimization runs

% calculate modularity matrix
[B, twom] = modularity_w_sign(A,gamma);

% initialize variables for consensus clustering
S_temp = zeros(size(B,1), n_iter);
Q_temp = zeros(n_iter,1);
C = zeros([size(B), n_iter]);

% selectively use parfor if needed
if n_iter > 30
    parfor i = 1:n_iter
        % run louvain optimization (single run)
        [S_temp(:,i), Q_temp(i)] = genlouvain(B);
        Q_temp(i) = Q_temp(i)/twom;
        C(:,:,i) = S_temp(:,i) == S_temp(:,i)';
    end
else
    for i = 1:n_iter
        % run louvain optimization (single run)
        [S_temp(:,i), Q_temp(i)] = genlouvain(B);
        Q_temp(i) = Q_temp(i)/twom;
        C(:,:,i) = S_temp(:,i) == S_temp(:,i)';
    end
end

% save iteration outputs
S_raw = S_temp;
Q_raw = Q_temp;

% run louvain clustering on consensus matrix
C = mean(C,3);
[B, ~] = modularity_w_sign(C,gamma);
[S_conn, ~] = genlouvain(B);

% get modularity associated with consensus clustering solution
[B, twom] = modularity_w_sign(A,gamma);
Q_conn = sum(sum(B.*(S_conn == S_conn')))./twom;
end