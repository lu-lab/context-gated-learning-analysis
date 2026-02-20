function err = conv_model_error(params, x, y, t)
    k = double_exp_kernel(params, t);
    y_hat = conv(x, k, 'full');  % Or 'full', depending on alignment

    % trim to valid indices before getting error
    N = length(y);
    y_hat = y_hat(1:N);
    y = y(1:N);

    % get error
    err = y_hat - y;
end