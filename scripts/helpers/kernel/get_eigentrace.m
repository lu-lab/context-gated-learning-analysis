function [eigtrace, PCs, varExp]  = get_eigentrace(pop_traces)
    [PCs, score, latent] = pca(pop_traces, 'Centered',false);
    % trim to first 5 PCs
    PCs = PCs(:, 1:5);

    % calculate variance explained and eigentrace
    varExp = cumsum(latent)/sum(latent);
    eigtrace = PCs(:, 1)*median(score(:,1), 'omitnan');
end