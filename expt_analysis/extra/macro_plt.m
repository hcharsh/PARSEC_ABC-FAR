clear all; clc; close all; warning off; format shortG; % % housekeeping
%% load C_file
n_cluster_sync = 5;
index = 2;
var_t = '_v2';
if mod(index, 3) == 1
    tim_t = '_1hr';
elseif mod(index, 3) == 2
    tim_t = '_2hr';
else
    tim_t = '_3hr';
end
if index <= 3
    moi_t = '_moi1';
else
    moi_t = '_moi3';
end
system_name = ['C', num2str(n_cluster_sync), var_t, moi_t, tim_t];
expt_folder = ['../ED_', system_name];
res_folder = ['../RES_', system_name]; mkdir(expt_folder);
info_fit_folder = [res_folder, '/info_fit'];

%%
% delete(gcp('nocreate'));
% parpool(8);

% DC = SSD; SC1 = W1SD; SC2 = W2SD; RD = SRD; TD = TUD;
prefix_list = {'SSD', 'W1SD', 'W2SD', 'SRD', 'TUD'};

n_expt_vec  = [20; 20; 20; 20; 4];%%%%%%%%%%%%
n_expt = 20;
for data_index = 1:n_expt
    for prefix_ind = 1:4
        clear pf FAR_file;
        pf = prefix_list{1, prefix_ind}; 
        FAR_file = [info_fit_folder, '/full_', pf, num2str(data_index), '.mat'];
        load(FAR_file, 'info');
        plot_dyn_HCV(info);
    end
end

clear pf n_expt;
pf_ind = 5; pf = prefix_list{1, pf_ind}; n_expt = n_expt_vec(pf_ind, 1);
for data_index = 1:n_expt
    clear system_id FAR_file;
    system_id = [pf, num2str(data_index)];
    FAR_file = [info_fit_folder, '/full_', system_id, '.mat'];
    load(FAR_file, 'info');
    plot_dyn_HCV(info);
end

