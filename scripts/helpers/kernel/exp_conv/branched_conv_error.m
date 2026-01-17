function err = branched_conv_error(params, x, y, t, branch_sizes)
    k = branched_conv_exp_kernel(params, t, branch_sizes);
    y_hat = conv(x, k, 'full');
    y_hat = y_hat(1:length(y)); % trim to same length
    err = y_hat - y;
end