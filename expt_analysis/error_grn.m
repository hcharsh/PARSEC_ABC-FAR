function WSSE = error_grn(prm, obs, y0, tspan, system_index)
    
%% simulation
    if      system_index == 1
        [t_iter,y_iter] = ode23s(@(t_iter,y_iter) act3_model1(prm, t_iter, y_iter), tspan, y0);
    elseif  system_index == 2
        [t_iter,y_iter] = ode23s(@(t_iter,y_iter) rep3_model1(prm, t_iter, y_iter), tspan, y0);
    elseif  system_index == 3
        [t_iter,y_iter] = ode23s(@(t_iter,y_iter) IFFL3_model1(prm, t_iter, y_iter), tspan, y0);
    end
    y_iter = y_iter + 1e-8;

%% error calculation
    WSSE = 0;
    if isfield(obs, 'obs_A')
        pred_A = log10(1e-8 + interp1(t_iter, y_iter(:, 1), obs.obs_A(:, 1)));
        dev_A = (pred_A - obs.obs_A(:, 2))./obs.obs_A(:, 3);
        WSSE = WSSE + sum(dev_A.^2);
    end
    
    if isfield(obs, 'obs_B')
        pred_B = log10(1e-8 + interp1(t_iter, y_iter(:, 2), obs.obs_B(:, 1)));
        dev_B = (pred_B - obs.obs_B(:, 2))./obs.obs_B(:, 3);
        WSSE = WSSE + sum(dev_B.^2);
    end
    
    if isfield(obs, 'obs_C')
        pred_C = log10(1e-8 + interp1(t_iter, y_iter(:, 3), obs.obs_C(:, 1)));
        dev_C = (pred_C - obs.obs_C(:, 2))./obs.obs_C(:, 3);
        WSSE = WSSE + sum(dev_C.^2);
    end
    
end