function [k_gamma, params_fit, n_best] = fit_gamma_kernel_grid(x, y, kernel_length, n_vals)
% x: input signal
% y: observed output
% kernel_length: number of time points in kernel
% n_vals: vector of candidate n values (e.g., 2:6)
%
% Output:
% k_gamma: fitted kernel
% params_fit: [A, tau] for best n
% n_best: n that produced lowest error

t = 0:(kernel_length-1);

best_err = Inf;
params_fit = [];
n_best = [];

for n = n_vals
    % Initial guess for [A, tau]
    params0 = [0.8, 10];

    % Bounds
    lb = [-Inf, 0.01];
    ub = [Inf, 1000];

    opts = optimoptions('lsqnonlin', 'MaxFunctionEvaluations', 1000);

    % Fit A and tau for this n
    try
        p_fit = lsqnonlin(@(p) conv_model_error_gamma(p, x, y, t, n), ...
                          params0, lb, ub, opts);
    catch
        continue; % skip if optimization fails
    end

    % Compute error (sum of squared residuals)
    k_temp = gamma_kernel(p_fit, t, n);
    y_hat = conv(x, k_temp, 'full');
    y_hat = y_hat(length(t):length(y));
    err = sum((y_hat - y(length(t):end)).^2);

    % Update best fit if error is lower
    if err < best_err
        best_err = err;
        params_fit = p_fit;
        n_best = n;
    end
end

% Final kernel
k_gamma = gamma_kernel(params_fit, t, n_best);
k_gamma = k_gamma(:);

end