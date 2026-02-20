function S_rep_new = reindex_modules(S_rep_old)
% function re-indexes input module assignments (neurons x timepoints) to
% minimize mismatches in module indices across timepoints

% initialize new module assignments, and get column from first
S_rep_new = nan(size(S_rep_old));
S_rep_new(:,1) = S_rep_old(:,1);

% loop across timepoints
for t = 2:size(S_rep_old,2)
    S_prev = S_rep_new(:,t-1);
    S_curr = S_rep_old(:,t);
    
    % get possible labels and binarize module assignments
    possible_labels = unique([S_curr; S_prev])';
    S_prev = S_prev == possible_labels;
    S_curr = S_curr == possible_labels;
    
    % find mismatches between previous and current module assignments
    overlap = S_prev'*S_curr;
    sizes = [sum(S_prev)', sum(S_curr)'];
    mismatches = (sizes(:,1)+sizes(:,2)')-overlap-overlap;

    % run linear assignment to minimize mismatches
    M = matchpairs(mismatches, sum(sizes(:,1)));

    % based on linear assignment, reassign labels for current timepoint
    new_labels = S_rep_old(:,t) == possible_labels(M(:,2)); % find binary indices of previous labels
    new_labels = new_labels.*possible_labels(M(:,1)); % assign new labels to corresponding indices
    new_labels = max(new_labels,[],2); 
    
    % store new module labels
    S_rep_new(:,t) = new_labels; 
end

% clean up module indices to assign lowest possible indices
S_rep_new = S_rep_new(:);
unique_inds = unique(S_rep_new)';
S_rep_new = S_rep_new == unique_inds;
S_rep_new = S_rep_new.*(1:length(unique_inds));
S_rep_new = max(S_rep_new,[], 2);
S_rep_new = reshape(S_rep_new,[],size(S_rep_old,2));
end