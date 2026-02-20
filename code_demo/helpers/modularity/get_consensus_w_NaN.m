function C = get_consensus_w_NaN(S)
    %calculate co-clustering of neurons across multiple module assignments
    [n_cells, n_clusterings] = size(S);
    
    C = zeros(n_cells, n_cells);
    counts = zeros(n_cells, n_cells);
    
    for i = 1:n_clusterings
        S_temp = S(:,i);
        valid = ~isnan(S_temp);

        same_cluster = (S_temp == S_temp');
        valid_pairs = valid * valid';
        C = C + (same_cluster & valid_pairs);

        counts = counts + valid_pairs;
    end
    C = C./counts;
end