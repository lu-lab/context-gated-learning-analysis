function [B,twom] = modularity_w_sign(A,gamma)
%MODULARITY returns monolayer Newman-Girvan modularity matrix for network given by adjacency matrix A, matrix version
%
% Modified to account for signs of correlations 
%
% Works for directed and undirected networks
%
%   Input: A:  NxN adjacency matrices of a directed or undirected network
%          gamma: resolution parameter
%
%   Output: B: modularity matrix of the monolayer network with adjacency 
%           matrix A
%           twom: normalisation constant
%
%   Example of usage: [B,twom]=modularity(A,gamma);
%          [S,Q]= genlouvain(B);
%          Q=Q/twom;
%   Notes:
%     The matrix A is assumed to be square. This assumption is not checked
%     here.
%
%     This code assumes that the sparse quality/modularity matrix B will
%     fit in memory and proceeds to build that matrix.  For larger systems,
%     try MODULARITY_F for undirected networks and MODULARITYDIR_F for directed
%     networks.
%
%     This code serves as a template and can be modified for situations
%     with other wrinkles (e.g., different null models).
%
%     By using this code, the user implicitly acknowledges that the authors
%     accept no liability associated with that use.  (What are you doing
%     with it anyway that might cause there to be a potential liability?!?)
%
%   References:
%     Newman, Mark E. J. and Michelle Girvan. "Finding and Evaluating
%     Community Structure in Networks", Physical Review E 69, 026113 (2004).


if nargin<2||isempty(gamma)
	gamma=1;
end
A_pos = A.*(A >= 0);

k_pos=sum(A_pos,2);
d_pos=sum(A_pos,1);
twom_pos=sum(k_pos);

B_pos=full((A_pos+A_pos')/2-gamma/2*(k_pos*d_pos+d_pos'*k_pos')/twom_pos);

A_neg = -A.*(A <= 0);

k_neg=sum(A_neg,2);
d_neg=sum(A_neg,1);
twom_neg=sum(k_neg);

B_neg=full((A_neg+A_neg')/2 - gamma/2*(k_neg*d_neg+d_neg'*k_neg')/twom_neg);

if max(isnan(B_pos),[],'all')
    B = -B_neg;
    twom = twom_neg;
elseif max(isnan(B_neg),[],'all')
    B = B_pos;
    twom = twom_pos;
else
    B = B_pos - B_neg;
    twom = twom_pos + twom_neg;
end
