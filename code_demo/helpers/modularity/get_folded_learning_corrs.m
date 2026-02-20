function [A, t_end, folded_IDs, naive_idx] = get_folded_learning_corrs(full_data, target_prom, target_stim, window_length, slide)
%% cut down to just single promoter + stimulus
% use inputs instead of 
% target_prom = "acr-5p";
% target_stim = "OP-PA";

target_data = full_data(string(full_data{:,"promoter"}) == target_prom,:);
target_data = target_data(string(target_data{:,"stimulus"}) == target_stim,:);

target_data = sortrows(target_data, 'training_status', 'ascend');
target_data = sortrows(target_data, 'ID', 'ascend');

%% separate out individual recordings (filename + plane number)
% Get list of recordings by concatenating metadata columns
metaCols = ["FilePath","filenames","plane"];      % columns to join
recording_list = join(string(target_data{:, metaCols}), '', 2);

% get lists of unique IDs and recordings
unique_IDs = unique(string(target_data.ID));
unique_recs = unique(recording_list);

% store recordings as neurons x time x recording array w/ NaN rows for unobserved neurons
recordings = NaN(length(unique_IDs), 451, length(unique_recs));

for i_rec = 1:length(unique_recs)
    % tabulate data from current recording
    inds = recording_list == unique_recs(i_rec);
    rec_data = target_data(inds,:);

    % add NaN rows
    [ID_idx, rec_idx] = find(unique_IDs == string(rec_data{:,"ID"})');
    recordings(ID_idx, :, i_rec) = rec_data{rec_idx, 9:end};
end

%% figure out which IDs are redundant after folding
folded_IDs = foldIDs(unique_IDs);
G = folded_IDs == unique(folded_IDs'); % maps unfolded rows to folded columns

%% for each recording, get sliding window correlation matrices
% use input values instead of declaring here
%window_length = 100;
%slide = 10;
t_end = window_length:slide:451;

% store sw correlations as neurons x neurons x window x recording array
n_neurons = length(unique_IDs);
folded_IDs = unique(folded_IDs');
n_folded_neurons = length(folded_IDs);
n_windows = length(t_end);
n_recs = length(unique_recs);
sw_corrs_indiv = NaN(n_neurons, n_neurons, n_windows, n_recs);
sw_corrs_folded = NaN(n_folded_neurons, n_folded_neurons, n_windows, n_recs);

for i_rec = 1:n_recs
    % pull current recording from bigger array
    curr_rec = recordings(:,:,i_rec);

    % find location of valid, non-NaN entries in correlation matrix
    valid = ~isnan(curr_rec(:,1));
    valid = valid*valid';
    
    % count correlations summed when folding (for averaging across folded
    % neurons while omitting NaN values)
    count_corrs = G'*valid*G;

    for i_window = 1:n_windows
        timepoints = (1:window_length)+t_end(i_window)-window_length;
        
        % get and save unfolded correlations
        A = corr(curr_rec(:, timepoints)','rows','pairwise');
        sw_corrs_indiv(:,:, i_window, i_rec)  = A;
        
        % fold correlations, averaging folded rows, but omitting NaN values
        A(~valid) = 0;
        sum_corrs = G'*A*G;
        sw_corrs_folded(:,:, i_window, i_rec) = sum_corrs./count_corrs;
    end
end

%% rename A to save as output
A = sw_corrs_folded;

%% output training status of recordings
[~, idx_meta, ~] = unique(recording_list);
naive_idx = string(target_data{idx_meta,"training_status"}) == "naive";

end

