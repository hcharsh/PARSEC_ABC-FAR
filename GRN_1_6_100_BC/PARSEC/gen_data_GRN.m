% clear all; close all; clc; warning off;
function gen_data_GRN()
n_cluster_sync = 6;

%% load C_file
tim_d = 3;
var_set = 3;

if var_set == 1
    VAR_INT = [1]; var_l = 'v1';
elseif var_set == 2
    VAR_INT = [1, 2]; var_l = 'v12';
elseif var_set == 3
    VAR_INT = [2, 3]; var_l = 'v23';
elseif var_set == 4
    VAR_INT = [1, 2, 3]; var_l = 'v123';
end

foldername = ['DES_', num2str(n_cluster_sync)];
system_name = [num2str(tim_d), 'hr_', var_l];
C_file = [foldername, '/C_', system_name];
expt_folder = ['../ED_C_', system_name]; mkdir(expt_folder);
D_file = [foldername, '/D_', system_name, '.mat'];

load([C_file, '.mat'], 'MT', 'y0');

%% simulation
load('../ground_truth_GRN.mat', 't_end', 'prm_log_GT');
tspan = [0:1:t_end];
[t,y]=ode23s(@(t,y) rep3_model1(t, y, prm_log_GT), tspan, y0);

y = max(y, 0) + 1e-8;
A_m = y(:, 1);
B_m = y(:, 2);
C_m = y(:, 3);
STD_VEC = ones(size(tspan'));

A_mat = [tspan', log10(A_m), STD_VEC];
B_mat = [tspan', log10(B_m), STD_VEC];
C_mat = [tspan', log10(C_m), STD_VEC];


%% options
load(D_file, 'TIM_SSD', 'TIM_W1SD', 'TIM_W2SD', 'TIM_SRD');
TIM_TUD1 = [6:6:36]';
TIM_TUD2 = [12:12:72]';
TIM_TUD3 = [2, 4, 8, 16, 32, 72]';
TIM_TUD4 = [6, 18, 54, 72]';
TIM_TUD0 = [1:1:72]';
%% Designs
for prefix_ind = 1:4
    clear pf TIM_MAT;
    if prefix_ind == 1
        TM_MAT = TIM_SSD; pf = 'SSD';
    elseif prefix_ind == 2
        TM_MAT = TIM_W1SD; pf = 'W1SD';
    elseif prefix_ind == 3
        TM_MAT = TIM_W2SD; pf = 'W2SD';
    elseif prefix_ind == 4
        TM_MAT = TIM_SRD; pf = 'SRD';
    end
    n_ED = size(TM_MAT, 2);

    for ED_ind = 1:n_ED
        clear Data_grn t_indices;
        t_fin = sort(TM_MAT(:, ED_ind));
        Data_grn.t_fin = t_fin;
        t_indices = t_fin' + 1; disp(t_indices - 1);
        
        for var_ind = 1:size(VAR_INT, 2)
            if VAR_INT(1, var_ind) == 1
                Data_grn.obs_A  = A_mat(t_indices, :);
            elseif VAR_INT(1, var_ind) == 2
                Data_grn.obs_B  = B_mat(t_indices, :);
            elseif VAR_INT(1, var_ind) == 3
                Data_grn.obs_C  = C_mat(t_indices, :);
            end
        end
        save([expt_folder, '/', pf, '_ED', num2str(ED_ind), '.mat'], ...
            'y0', 'tspan', 'Data_grn', 'prm_log_GT');
    end

end

%% Designs
clear pf; pf = 'TUD';
for index = 1:4
    clear TIM_MAT Data_grn t_indices;
    if index == 1
        TM_MAT = TIM_TUD1; 
    elseif index == 2
        TM_MAT = TIM_TUD2;
    elseif index == 3
        TM_MAT = TIM_TUD3;
    elseif index == 4
        TM_MAT = TIM_TUD4;
    end
    n_ED = size(TM_MAT, 2); t_fin = sort(TM_MAT);
    Data_grn.t_fin = t_fin;
    t_indices = t_fin' + 1; disp(t_indices - 1);
    for var_ind = 1:size(VAR_INT, 2)
        if VAR_INT(1, var_ind) == 1
            Data_grn.obs_A  = A_mat(t_indices, :);
        elseif VAR_INT(1, var_ind) == 2
            Data_grn.obs_B  = B_mat(t_indices, :);
        elseif VAR_INT(1, var_ind) == 3
            Data_grn.obs_C  = C_mat(t_indices, :);
        end
    end
    save([expt_folder, '/', pf, '_ED', num2str(index), '.mat'], ...
        'y0', 'tspan', 'Data_grn', 'prm_log_GT');
end

%% Designs

clear pf; pf = 'data0';
clear TIM_MAT Data_grn t_indices;
TM_MAT = TIM_TUD0;
t_fin = sort(TM_MAT);
Data_grn.t_fin = t_fin;
t_indices = t_fin' + 1; disp(t_indices - 1);
Data_grn.A  = A_mat(t_indices, :);
Data_grn.B  = B_mat(t_indices, :);
Data_grn.C  = C_mat(t_indices, :);
save([expt_folder, '/', pf, '.mat'], ...
    'y0', 'tspan', 'Data_grn', 'prm_log_GT');

end