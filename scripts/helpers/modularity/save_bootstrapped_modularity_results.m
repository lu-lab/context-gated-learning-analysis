function save_bootstrapped_modularity_results(full_data, target_prom, target_stim, window_length, slide, omega, n_boots)
output_name = join([target_prom, "_", target_stim, "_w", num2str(window_length), "_s", num2str(slide), "_o", num2str(omega), "_nb", num2str(n_boots), ".mat"],'');

    % get sliding window correlations
    [A, t_end, folded_IDs, naive_idx] = get_folded_learning_corrs(full_data, target_prom, target_stim, window_length, slide);
    
    % split naive and trained data
    A_n = A(:,:,:,naive_idx);
    A_t = A(:,:,:,~naive_idx);
    
    % generate bootstraps
    A_n_avg_boot = zeros([size(A_n,1:3) n_boots]);
    A_t_avg_boot = zeros([size(A_t,1:3) n_boots]);
    
    for i = 1:n_boots
        [A_n_boot, A_t_boot, n_boot_idx, t_boot_idx] = bootstrap_corrs(A_n, A_t);
        [A_n_avg_boot(:,:,:,i), A_t_avg_boot(:,:,:,i)] = get_pop_avg_corrs(A_n_boot, A_t_boot);
    end
    ts(1) = toc;
    
    % get multi-slice module assignments and modularity
    [n_cells, n_windows] = size(A, [1 3]);
    S_multi_n_boot = zeros(n_cells, n_windows, n_boots);
    S_multi_t_boot = zeros(n_cells, n_windows, n_boots);
    dropped_rows = zeros(n_cells,n_boots);
    
    for i = 1:n_boots
        % load in correlation matrices and zero out diagonal
        A_n_temp = A_n_avg_boot(:,:,:,i);
        A_t_temp = A_t_avg_boot(:,:,:,i);
        A_n_temp = A_n_temp - eye(size(A_n_temp,1));
        A_t_temp = A_t_temp - eye(size(A_t_temp,1));
        
        % figure out dropped rows and remove
        dropped_rows(:,i) = sum(isnan(A_n_avg_boot(:,:,1,i)), 2) == n_cells;
        A_n_temp = A_n_temp(~dropped_rows(:,i), ~dropped_rows(:,i), :);
        A_t_temp = A_t_temp(~dropped_rows(:,i), ~dropped_rows(:,i), :);
        n_undropped = sum(~dropped_rows(:,i));
    
        % replace NaN values with 0
        A_n_temp(isnan(A_n_temp)) = 0;
        A_t_temp(isnan(A_t_temp)) = 0;
    
        % run fisher r-to-z transformation
        Z_n = atanh(A_n_temp);
        Z_t = atanh(A_t_temp);
        
        gamma = 1;
        %omega = 1; % set omega (coupling paramter) as function input, rather than define here
        n_iter = 1000;
        [S_multi_n] = get_rep_multislice_modules_reindex(Z_n, gamma, omega, n_iter, 1);
        [S_multi_t] = get_rep_multislice_modules_reindex(Z_t, gamma, omega, n_iter, 1);
        
        % reshape and re-index modules
        S_multi_n = reshape(S_multi_n, [n_undropped, n_windows]);
        S_multi_n_boot(~dropped_rows(:,i),:,i) = reindex_modules(S_multi_n);
        S_multi_t = reshape(S_multi_t, [n_undropped, n_windows]);
        S_multi_t_boot(~dropped_rows(:,i),:,i) = reindex_modules(S_multi_t);
    end
    ts(2) = toc;
    
    % get modularity
    Q_ms_n_boot = zeros(n_windows, n_boots);
    Q_ms_t_boot = zeros(n_windows, n_boots);
    
    for i = 1:n_boots
        % get correlation matrices, remove dropped rows, and fill in NaN values
        A_n_temp = A_n_avg_boot(~dropped_rows(:,i),~dropped_rows(:,i),:,i);
        A_t_temp = A_t_avg_boot(~dropped_rows(:,i),~dropped_rows(:,i),:,i);
    
        A_n_temp(isnan(A_n_temp)) = 0;
        A_t_temp(isnan(A_t_temp)) = 0;
        
        A_n_temp = A_n_temp - eye(size(A_n_temp,1));
        A_t_temp = A_t_temp - eye(size(A_t_temp,1));
    
        % get bootstrapped module assignments
        S_multi_n_temp = S_multi_n_boot(~dropped_rows(:,i),:,i);
        S_multi_t_temp = S_multi_t_boot(~dropped_rows(:,i),:,i);
    
        % loop through windows and calculate modularity
        for t = 1:n_windows
            [B_n, twom_n] = modularity_w_sign(A_n_temp(:,:,t),gamma);
            Q_ms_n_boot(t,i) = sum(B_n.*(S_multi_n_temp(:,t) == S_multi_n_temp(:,t)'),'all')/twom_n;
    
            [B_t, twom_t] = modularity_w_sign(A_t_temp(:,:,t),gamma);
            Q_ms_t_boot(t,i) = sum(B_t.*(S_multi_t_temp(:,t) == S_multi_t_temp(:,t)'),'all')/twom_t;
        end
    end
    ts(3) = toc;
    
    % get flexibility
    flexibility_n_boot = NaN(n_cells, n_boots);
    flexibility_t_boot = NaN(n_cells, n_boots);
    
    for i = 1:n_boots
        % get bootstrapped module assignments
        S_multi_n_temp = S_multi_n_boot(~dropped_rows(:,i),:,i);
        S_multi_t_temp = S_multi_t_boot(~dropped_rows(:,i),:,i);
    
        % calculate flexibility
        flexibility_n_boot(~dropped_rows(:,i),i) = get_flexibility(S_multi_n_temp);
        flexibility_t_boot(~dropped_rows(:,i),i) = get_flexibility(S_multi_t_temp);
    end
    ts(4) = toc;
    
    % get consensus modules and recruitment/integration
    allegiance_n_boot = zeros(n_cells, n_cells, n_boots);
    allegiance_t_boot = zeros(n_cells, n_cells, n_boots);
    
    S_conn_n_boot = zeros(n_cells, n_boots);
    S_conn_t_boot = zeros(n_cells, n_boots);
    
    RI_mat_n_boot = cell(n_boots, 1);
    RI_mat_t_boot = cell(n_boots, 1);
    
    for i = 1:n_boots
        % get bootstrapped module assignments
        S_multi_n_temp = S_multi_n_boot(~dropped_rows(:,i),:,i);
        S_multi_t_temp = S_multi_t_boot(~dropped_rows(:,i),:,i);
    
        % get allegiance matrices
        allegiance_n_boot(~dropped_rows(:,i),~dropped_rows(:,i),i) = get_consensus(S_multi_n_temp);
        allegiance_t_boot(~dropped_rows(:,i),~dropped_rows(:,i),i) = get_consensus(S_multi_t_temp);
    
        % get allegiance modules
        [~, S_conn_n_boot(~dropped_rows(:,i),i)] = sort_by_modularity(allegiance_n_boot(~dropped_rows(:,i),~dropped_rows(:,i),i), 1);
        [~, S_conn_t_boot(~dropped_rows(:,i),i)] = sort_by_modularity(allegiance_t_boot(~dropped_rows(:,i),~dropped_rows(:,i),i), 1);
    
        % get recruitment/integration
        RI_mat_n_boot{i} = get_recruitment_and_integration(S_multi_n_temp, S_conn_n_boot(~dropped_rows(:,i),i));
        RI_mat_t_boot{i} = get_recruitment_and_integration(S_multi_t_temp, S_conn_t_boot(~dropped_rows(:,i),i));
    end
    ts(5) = toc;
    
    % save results
    
    results = {'folded_IDs', 't_end', 'dropped_rows'...
               'S_multi_n_boot', 'S_multi_t_boot', 'Q_ms_n_boot', 'Q_ms_t_boot', ...
               'flexibility_n_boot', 'flexibility_t_boot', ...
               'allegiance_n_boot', 'allegiance_t_boot', ...
               'S_conn_n_boot', 'S_conn_t_boot', ...
               'RI_mat_n_boot', 'RI_mat_t_boot'};
    save(output_name, results{:}, '-v7.3');
    ts(6) = toc;

end
% things to look at
% uncertainty in flexibility
% uncertainty in modularity
% allegiance matrix across bootstraps
% consensus module assignment across bootstraps
