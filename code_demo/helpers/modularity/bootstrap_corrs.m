function [A_n_boot, A_t_boot, n_boot_idx, t_boot_idx] = bootstrap_corrs(A_n, A_t)
% figure out number of naive and trained recordings
n_naive = size(A_n, 4);
n_trained = size(A_t, 4);

% get indices to bootstrap recordings
n_boot_idx = randi(n_naive, [n_naive, 1]);
t_boot_idx = randi(n_trained, [n_trained, 1]);

% output bootstrapped recordings
A_n_boot = A_n(:,:,:,n_boot_idx);
A_t_boot = A_t(:,:,:,t_boot_idx);
end