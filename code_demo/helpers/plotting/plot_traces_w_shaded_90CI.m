function [avg_trace, shaded_area] = plot_traces_w_shaded_90CI(time, traces, trace_color)
    %plots mean of traces vs. time with shaded region for st. deviation
    avg_trace = plot(time, mean(traces,2),Color=trace_color);
    bounds = prctile(traces, [5 95], 2);
    shaded_area = patch([time time(end:-1:1)], [bounds(:,1); bounds(end:-1:1,2)],trace_color);
    shaded_area.EdgeColor = 'none';
    shaded_area.FaceAlpha = 0.3;
end