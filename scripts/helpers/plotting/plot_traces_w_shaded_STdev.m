function [avg_trace, shaded_area] = plot_traces_w_shaded_STdev(time, traces, trace_color)
% plot_traces_w_shaded_STdev
% Plots mean of multiple traces with a shaded region for standard deviation.
%
% Inputs:
%   time        - vector of timepoints (length N)
%   traces      - matrix of size N x nTrials
%   trace_color - RGB color vector (1x3)
%
% Outputs:
%   avg_trace   - handle to mean trace line
%   shaded_area - handle to shaded patch

    % Compute mean and SEM along trials
    mean_trace = mean(traces, 2);
    stdev_trace  = std(traces, 0, 2);

    % Upper and lower bounds
    upper = mean_trace + stdev_trace;
    lower = mean_trace - stdev_trace;

    % Plot shaded area
    time = time(:); % ensure time is specified as column vec
    shaded_area = patch([time; flipud(time)], [upper; flipud(lower)], ...
                        trace_color, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on;

    % Plot mean trace
    avg_trace = plot(time, mean_trace, 'Color', trace_color, 'LineWidth', 1.5);
end