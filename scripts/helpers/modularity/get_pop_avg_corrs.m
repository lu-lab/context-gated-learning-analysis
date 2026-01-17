function [A_n_avg, A_t_avg] = get_pop_avg_corrs(A_n, A_t)
% take average correlations
A_n_avg = mean(A_n,4,"omitnan");
A_t_avg = mean(A_t,4,"omitnan");

% count naive and trained observations for each pair of neurons
naive_counts = sum(~isnan(A_n(:,:,1,:)),4);
trained_counts = sum(~isnan(A_t(:,:,1,:)),4);

% threshold matrices by minimum number of observations
min_obs = 3;
connected = min(naive_counts >= min_obs, trained_counts >= min_obs);

% set pairs with counts below threshold to NaN
mask = ones(size(connected));
mask(~connected) = NaN;
A_n_avg = A_n_avg.*mask;
A_t_avg = A_t_avg.*mask;
end