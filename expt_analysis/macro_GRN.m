clear all; clc; close all; warning off; format shortG; % % housekeeping
n_cluster_sync = 6;
system_ind = 2;
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

system_name = [num2str(tim_d), 'hr_', var_l];
expt_folder = ['../ED_C_', system_name]; mkdir(expt_folder);
res_folder = ['../RES_C_', system_name]; mkdir(expt_folder);

%%
% delete(gcp('nocreate'));
% parpool(8);

% DC = SSD; SC1 = W1SD; SC2 = W2SD; RD = SRD; TD = TUD;
prefix_list = {'SSD', 'W1SD', 'W2SD', 'SRD', 'TUD'};

n_expt_vec  = [100; 40; 40; 100; 4];%%%%%%%%%%%%
for prefix_ind = 1:4
    clear n_expt; n_expt = n_expt_vec(prefix_ind, 1);
    for data_index = 1:n_expt
        clear pf; pf = prefix_list{1, prefix_ind};
        fit_setup_file_UD(expt_folder, res_folder, pf, data_index, system_ind);
    end
end

    % clear pf n_expt;
    % pf_ind = 5; pf = prefix_list{1, pf_ind}; n_expt = n_expt_vec(pf_ind, 1);
    % for data_index = 1:n_expt
    %     fit_setup_file_UD(expt_folder, res_folder, pf, data_index, system_ind);
    % end
    % 
