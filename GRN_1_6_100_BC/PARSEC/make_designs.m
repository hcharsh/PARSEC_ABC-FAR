clear all; clc; close all; warning off; format shortG; % % housekeeping
n_expt = 100;
n_cluster_sync = 6;

tim_d = 3;
var_set = 3;
TSA_file = ['../TSA/TSA_', num2str(tim_d), 'hr.mat'];

if var_set == 1
    VAR_INT = [1]; var_l = 'v1';
elseif var_set == 2
    VAR_INT = [1, 2]; var_l = 'v12';
elseif var_set == 3
    VAR_INT = [2, 3]; var_l = 'v23';
elseif var_set == 4
    VAR_INT = [1, 2, 3]; var_l = 'v123';
end

foldername = ['DES_', num2str(n_cluster_sync)]; mkdir(foldername);
C_file = [foldername, '/C_', num2str(tim_d), 'hr_', var_l];
D_file = [foldername, '/D_', num2str(tim_d), 'hr_', var_l '.mat'];
dummy_thres = 0.75;

%% clustering
if ~exist([C_file, '.mat'], 'file')
     clustering_sync(n_cluster_sync, n_expt, TSA_file, C_file, dummy_thres, VAR_INT);
end
load([C_file, '.mat'],...
    'k_clstr', 'filt_Z_lbl', 'VAR_INT', 'MT', 'filt_TIM');

%% selecting one candidates from each clusters
for expt_ind = 1:n_expt
    clear bag;
    bag = k_clstr.sample(:, expt_ind);
    for cl_ind = 1:n_cluster_sync % max(bag)
        clear int_vec size_vec;
        int_vec = find(bag==cl_ind);
        size_vec = size(int_vec, 1);
        clear rand_val rand_ind select_measure_ind;
        rand_val = rand;
        rand_ind = floor(rand_val * size_vec) + 1;
        select_measure_ind = int_vec(rand_ind, 1);
        SSD_ind(cl_ind, expt_ind) = select_measure_ind;
        SSD_CH(cl_ind, expt_ind) = bag(select_measure_ind, 1);
        TIM_SSD(cl_ind, expt_ind) = filt_TIM(select_measure_ind, 1);
    end
end
VAR_SSD = VAR_INT;

%% selecting multiple candidates from a few clusters
for expt_ind = 1:n_expt
    clear bag size_cl sort_sc sort_ind;
    bag = k_clstr.sample(:, expt_ind);
    for cl_ind = 1:n_cluster_sync % max(bag)
        clear int_vec;
        int_vec = find(bag==cl_ind);
        size_cl(cl_ind, 1) = size(int_vec, 1);
    end
    [sort_sc, sort_ind] = sort(size_cl);
    fill_m = 0; cl_ind = 1;
    while 1
        nm_m = sort_sc(n_cluster_sync + 1 - cl_ind, 1);
        cl_m = sort_ind(n_cluster_sync + 1 - cl_ind, 1);
        int_vec = find(bag==cl_m);
        if nm_m < (n_cluster_sync - fill_m)
            TIM_W1SD(fill_m + 1 : fill_m + nm_m, expt_ind) = MT(int_vec', 1);
            fill_m = fill_m + nm_m;
        else
            clear temp_perm;
            temp_perm = int_vec(randperm(nm_m), 1);
            TIM_W1SD(fill_m + 1 : n_cluster_sync, expt_ind) = ...
                MT(temp_perm(1 : n_cluster_sync - fill_m, 1)', 1);
            CLS_W1SD(fill_m + 1 : n_cluster_sync, expt_ind) = ...
                cl_m;
            fill_m = n_cluster_sync;
        end

        if (fill_m >= n_cluster_sync)
            break;
        end
        if cl_ind >= n_cluster_sync
            break;
        end
        cl_ind = cl_ind + 1;
    end
end
VAR_W1SD = VAR_INT;

%% not the worst
a = 0.3; % bigger this better it is
for expt_ind = 1:n_expt
    clear bag size_cl sort_sc sort_ind;
    bag = k_clstr.sample(:, expt_ind);
    for cl_ind = 1:n_cluster_sync % max(bag)
        clear int_vec;
        int_vec = find(bag==cl_ind);
        size_cl(cl_ind, 1) = size(int_vec, 1);
    end
    [sort_sc, sort_ind] = sort(size_cl);
    tot_nm = size(MT, 1);
    tW2_nm = tot_nm * a + n_cluster_sync * (1 - a);
    small_set = []; cls_set = [];
    fill_m = 0; cl_ind = 1;
    while 1
        clear nm_m cl_m int_vec;
        nm_m = sort_sc(n_cluster_sync + 1 - cl_ind, 1);
        cl_m = sort_ind(n_cluster_sync + 1 - cl_ind, 1);
        int_vec = find(bag==cl_m);
        cls_vec = cl_m * ones(size(int_vec));
        fill_m = fill_m + nm_m;
        
        small_set   = [small_set; int_vec];
        cls_set     = [cls_set; int_vec];
        
        if (fill_m >= tW2_nm) && (cl_ind >= 2)
            break;
        end
        if cl_ind >= n_cluster_sync
            break;
        end
        cl_ind = cl_ind + 1;
    end
    nmc = size(small_set, 1); temp_perm = randperm(nmc);
    reqd_perm = temp_perm(1, 1:n_cluster_sync);
    temp_tim_ind = small_set(reqd_perm, 1)';
    
    TIM_W2SD(:, expt_ind) = MT(temp_tim_ind, 1);
    CLS_W2SD(:, expt_ind) = cls_set(reqd_perm, 1);
end
VAR_W2SD = VAR_INT;

%% Random Synchronous
nmc = size(MT, 1); % n_measurement_candidates
for expt_ind = 1:n_expt
    clear temp_perm;
    temp_perm = randperm(nmc)';
    for cl_ind = 1:n_cluster_sync % max(bag)
        clear temp_id var_id tim_id;
        tim_id = temp_perm(cl_ind, 1);
        TIM_SRD(cl_ind, expt_ind) = MT(tim_id, 1);
    end
end
VAR_SRD = VAR_INT;

clear rand_val rand_ind select_measure_ind...
    int_vec size_vec cl_ind expt_ind...
    temp_perm temp_id var_id tim_id;
save(D_file);