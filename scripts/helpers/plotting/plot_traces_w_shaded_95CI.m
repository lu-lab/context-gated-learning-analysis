function [avg_trace, shaded_area] = plot_traces_w_shaded_95CI(time, traces, trace_color)
% plot_traces_w_shaded_95CI
% Plots mean of multiple traces with a shaded region for 95% percentile bounds.
%
% Inputs:
%   time        - vector of timepoints (length N)
%   traces      - matrix of size N x nTrials
%   trace_color - RGB color vector (1x3)
%
% Outputs:
%   avg_trace   - handle to mean trace line
%   shaded_area - handle to shaded patch

    % Compute mean and 95% bounds across trials
    mean_trace = mean(traces, 2);
    bounds     = prctile(traces, [2.5 97.5], 2);  % 95% CI

    lower = bounds(:,1);
    upper = bounds(:,2);

    % Plot shaded area
    time = time(:);
    shaded_area = patch([time; flipud(time)], [upper; flipud(lower)], ...
                        trace_color, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on;

    % Plot mean trace
    avg_trace = plot(time, mean_trace, 'Color', trace_color, 'LineWidth', 1.5);
end