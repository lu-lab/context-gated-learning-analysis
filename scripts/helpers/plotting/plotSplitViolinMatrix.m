function plotSplitViolinMatrix(A, B, colorA, colorB)
% PLOTSPLITVIOLINMATRIX Compare distributions across group pairs.
%
%   A, B : [groups x groups x trials] matrices
%   colorA, colorB : RGB triplets

    [groups, ~, observations] = size(A); %#ok<ASGLU>
    mask = triu(true(groups));
    [ii,jj] = find(mask);
    nPairs = numel(ii);

    hold on
    tickLabels = cell(1,nPairs);

    for k = 1:nPairs
        dataA = squeeze(A(ii(k),jj(k),:));
        dataB = squeeze(B(ii(k),jj(k),:));
        plotSplitViolin(dataA, dataB, colorA, colorB, k); % no label here
        tickLabels{k} = sprintf('%d-%d', ii(k), jj(k));
    end

    % Now set axis state once
    xlim([0 nPairs+1])
    set(gca,'XTick',1:nPairs,'XTickLabel',tickLabels)
    ylabel('Values')
    box on
end