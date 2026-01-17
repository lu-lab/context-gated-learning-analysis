function err = conv_model_error_gamma(params, x, y, t, n)
k = gamma_kernel(params, t, n);
y_hat = conv(x, k, 'full');

% trim to valid indices
N = length(y);
y_hat = y_hat(1:N);
y = y(1:N);

err = y_hat - y;
end