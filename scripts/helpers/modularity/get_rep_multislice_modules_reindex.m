function S_rep = get_rep_multislice_modules_reindex(A, gamma, omega, n_raw_iter, n_rep_iter)

    %find raw multi-slice module assignments, and null control
    [S_multi, S_multi_null] = get_multislice_modularity_reindex(A, gamma, omega, n_raw_iter);
    
    %threshold consensus matrix, based on both significantly low and
    %signficantly high associations across optimization runs
    [C_thresh, ~] = threshold_consensus_matrix(S_multi, S_multi_null);

    % get representative module assignments based on thresholded consensus
    % in theory, just once should be enough but can run 10-20 times to
    % verify stability
    S_rep = zeros(size(S_multi,1), n_rep_iter);
    Q_rep = zeros(n_rep_iter,1);
    parfor k = 1:n_rep_iter
        [S_rep(:,k), Q_rep(k)] = get_modularity(C_thresh, gamma); 
    end

    % if repetitions are run, sort runs from highest to lowest modularity
    [~, order] = sort(Q_rep, 'descend');
    S_rep = S_rep(:,order);
end