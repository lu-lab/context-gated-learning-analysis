function k = exp_conv_kernel(params, t)
% exp_conv_kernel: successive convolutions of exponentials
% params = [A, gamma1, gamma2, ...]
% t = time vector (must be uniform spacing)

% dt = timestep (needed for discrete convolution scaling)
dt = t(2) - t(1);

A = params(1);
gamma_values = params(2:end);
nConv = length(gamma_values);

% First exponential
k = zeros(size(t));
k(t >= 0) = exp(-gamma_values(1) * t(t >= 0));

% Normalize to unit area (optional, matches continuous form)
k = k / sum(k*dt);

% Successive convolutions
for m = 2:nConv
    exp_kernel = zeros(size(t));
    exp_kernel(t >= 0) = exp(-gamma_values(m) * t(t >= 0));
    exp_kernel = exp_kernel / sum(exp_kernel*dt); % normalize
    
    k = conv(k, exp_kernel, 'full') * dt;  % discrete convolution
    k = k(1:length(t));                    % truncate to length of t
end

% Apply amplitude
k = A * k;
end
