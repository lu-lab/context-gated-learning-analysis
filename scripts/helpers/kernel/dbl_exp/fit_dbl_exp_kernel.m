function [k_dbl_exp, params_fit] = fit_dbl_exp_kernel(x, y, kernel_length)
% Input: x (input signal), y (observed output)
% Time vector for kernel
t = 0:(kernel_length-1);

% Initial guess
params0 = [0.8, 10, 20];

% Bounds (to avoid negative time constants)
lb = [-Inf, 0.01, 0.01];
ub = [Inf, 100, 100];

% Fit
opts = optimoptions('lsqnonlin', 'MaxFunctionEvaluations', 1000);
params_fit = lsqnonlin(@(p) conv_model_error(p, x, y, t), params0, lb, ub, opts);

% Final kernel and prediction
k_dbl_exp = double_exp_kernel(params_fit, t);
k_dbl_exp = k_dbl_exp(:);
end