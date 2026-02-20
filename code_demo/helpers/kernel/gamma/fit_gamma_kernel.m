function [k_gamma, params_fit] = fit_gamma_kernel(x, y, kernel_length, n)
% x: input signal
% y: observed output
% kernel_length: number of time points in kernel
% n: gamma shape parameter (fixed)

t = 0:(kernel_length-1);

% Initial guess for [A, tau]
params0 = [0.8, 10];

% Bounds to keep tau positive
lb = [-Inf, 0.01];
ub = [Inf, 1000];

opts = optimoptions('lsqnonlin', 'MaxFunctionEvaluations', 1000);

params_fit = lsqnonlin(@(p) conv_model_error_gamma(p, x, y, t, n), ...
                        params0, lb, ub, opts);

% Compute final kernel
k_gamma = gamma_kernel(params_fit, t, n);
k_gamma = k_gamma(:);
end