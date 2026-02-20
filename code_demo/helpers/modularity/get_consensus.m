function C = get_consensus(S)
    %calculate co-clustering of neurons across multiple module assignments
    [n_cells, n_clusterings] = size(S);
    C = zeros(n_cells, n_cells);
    for i = 1:n_clusterings
        C = C*(i-1) + (S(:,i) == S(:,i)');
        C = C./i;
        %C(:,:,i) = S(:,i) == S(:,i)';
    end
    %C = mean(C,3);
end