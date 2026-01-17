function k = double_exp_kernel(params, t)
% params = [A, tau_rise, tau_decay]
A = params(1);
tau_r = params(2);
tau_d = params(3);

t = max(t, 0);  % enforce causality
k = A * (exp(-t / tau_d) - exp(-t / tau_r));
end