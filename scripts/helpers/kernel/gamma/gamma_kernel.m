function k = gamma_kernel(params, t, n)
% params = [A, tau]
% n = shape parameter (fixed)
A = params(1);
tau = params(2);

t = max(t, 0);  % enforce causality
k = A * (t.^(n-1) .* exp(-t / tau)) / (tau^n * factorial(n-1));
end