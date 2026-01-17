function [k_best, params_best, branchSizes_best, rms_best, rms_err] = ...
    branched_kernel_model_selection(x, y, kernel_length, conv_range, max_branches, rms_tol, autoStop)
%BRANCHED_KERNEL_MODEL_SELECTION 
%   Iteratively fit branched exponential convolution kernels with
%   increasing complexity, stopping when additional parameters no longer
%   significantly improve RMS error.
%
% Inputs
%   x            - input signal
%   y            - observed output signal
%   kernel_length- length of kernel in samples
%   conv_range   - vector of possible convolution depths per branch (e.g., 2:5)
%   max_branches - maximum number of branches to try
%   rms_tol      - tolerance for relative RMS improvement (e.g., 0.01)
%
% Outputs
%   k_best           - best-fit kernel (discrete, length = kernel_length)
%   params_best      - fitted parameters for best model
%   branchSizes_best - structure of branches used in best model
%   rms_best         - RMS error of best fit

    % initialize function outputs
    k_best = [];
    params_best = [];
    branchSizes_best = [];
    rms_err = [];
    rms_best = Inf;

    % keep track of current best for parameter initialization
    params_prev = [];
    branchSizes_prev = [];
    model_idx = 0;

    % outer loop: number of branches
    for nBr = 1:max_branches

        % flag to check if we improved within this branch
        branch_improved = false;

        % inner loop: convolution depths
        for nConv = conv_range
            branchSizes = [branchSizes_prev, nConv + 1];

            % ---- initialize parameters ----
            A0     = (-1)^(nBr - 1);
            gamma0 = 0.2 + (1:nConv)*0.03 + (nBr - 1)*0.02;
            params0_currB = [A0 gamma0(:)'];
            params0 = [params_prev(:)' params0_currB];

            % ---- fit ----
            [k_fit, params_fit] = fit_branched_kernel(x, y, kernel_length, branchSizes, params0);
            model_idx = model_idx + 1;

            % ---- evaluate fit ----
            yhat = conv(x, k_fit, 'full');
            yhat = yhat(1:length(y)); % trim to observed length
            rms_err(model_idx) = sqrt(mean((yhat - y).^2));
            
            % ---- skip model selection check for first model----
            if model_idx == 1
                % save initial fit as new best
                rms_best = rms_err(model_idx);
                k_best = k_fit;
                params_best = params_fit;
                branchSizes_best = branchSizes;

                params_prev = params_fit;
                branchSizes_prev = branchSizes;
                continue
            end
            
            % ---- model selection check ----
            rel_improve = (rms_err(model_idx - 1) - rms_err(model_idx)) / rms_err(model_idx - 1);
            if rel_improve > rms_tol
                % keep new best
                rms_best = rms_err(model_idx);
                k_best = k_fit;
                params_best = params_fit;
                branchSizes_best = branchSizes;

                params_prev = params_fit;
                branchSizes_prev = branchSizes;

                branch_improved = true;
            else
                % stop increasing convolutions for this branch
                if autoStop
                    break;
                end
            end
        end
        
        % if no improvement at all from adding this branch → stop
        if autoStop && ~branch_improved
            break;
        end
    end
end
