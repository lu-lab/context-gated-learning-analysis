function RI_mat = get_recruitment_and_integration(S_multi, S_conn, mode)

n_conn_modules = max(S_conn);
if nargin < 3 || isempty(mode) || mode == "modules"
    % find consensus modules of input matrix
    C = get_consensus(S_multi);
elseif mode == "allegiance"
    C = S_multi;
else
    error("Mode argument must either be ""modules"" or ""allegiance""")
end

% loop across consensus modules to take block-wise average of consensus matrix
RI_mat = zeros(n_conn_modules);
for i = 1:n_conn_modules
    for j = i:n_conn_modules
        block_ij = C(S_conn == i, S_conn == j);
        if i == j
            % nan out lower half of matrix
            lower_idx = logical(tril(ones(size(block_ij))));
            block_ij(lower_idx) = NaN;
            RI_mat(i,j) = mean(block_ij(:), 'omitnan');
        else
            RI_mat(i,j) = mean(block_ij(:), 'omitnan');
        end
        RI_mat(j,i) = RI_mat(i,j);
    end
end
end