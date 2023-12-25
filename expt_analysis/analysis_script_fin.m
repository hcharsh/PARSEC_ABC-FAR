clear all;
clc;
close all;
warning off;
format shortG; % % housekeeping

load('../ground_truth_GRN.mat', 'prm_log_GT');
data0_file = '../ED_C2_3hr_v23/data0.mat';

%% load C_file
n_cluster_sync = 6;
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
info_fit_folder = [res_folder, '/info_fit'];

%%
prm_log_GT = round(prm_log_GT, 2);
expt_lbl{1, 1} = 'GT';

prefix_list = {'SSD', 'W1SD', 'W2SD', 'SRD', 'TUD'};
n_expt_vec  = [100; 40; 40; 100; 4];%%%%%%%%%%%%
index = 0;
pf_mrkr = zeros(sum(n_expt_vec, 1), size(n_expt_vec, 1));
% i3 = 0;
% for i1 = 1:size(n_expt_vec, 1)
%     for i2 = 1:n_expt_vec(i1, 1)
%         i3 = i3 + 1;
%         pf_mrkr(i3, i1)  = 1;
%     end
% end

for prefix_ind = 1:4 % size(prefix_list, 2)
    clear prefix;
    pf = prefix_list{1, prefix_ind}; 
    n_expt = n_expt_vec(prefix_ind, 1);
    for data_index = 1:n_expt
        index = index + 1;
        pf_mrkr(index, prefix_ind)  = 1;
        FAR_file = [info_fit_folder, '/full_', pf, num2str(data_index), '.mat'];
        load(FAR_file, 'info', 'cmf_est', 'PRM_nest');
        obs = info.obs; cmf_est = round(cmf_est, 2); clear info;
        clear tom_expt;
        
        if isfield(obs, 'obs_A')
            tom_expt = obs.obs_A(:, 1);
        elseif isfield(obs, 'obs_B')
            tom_expt = obs.obs_B(:, 1);
        elseif isfield(obs, 'obs_C')
            tom_expt = obs.obs_C(:, 1);
        end
        measure_tim{index, 1} = tom_expt;
        
        blank{index, 1} = '';
        if (prefix_ind < 4)&&(data_index < 41)
            measure_tim2{data_index, prefix_ind} = tom_expt;
        end
        if (prefix_ind == 1)
            measure_tim_SSD{data_index, 1} = tom_expt;
        end
        if (prefix_ind == 4)
            measure_tim_SRD{data_index, 1} = tom_expt;
        end
        measurements(index, 1) = size(VAR_INT, 1) * size(tom_expt, 1);
        clear obs;
        n_nest = size(PRM_nest, 3); n_prm = size(PRM_nest, 2);
        lst = (n_nest - 1) * n_prm + [1 : n_prm];
        
        A_25(index, :)        = cmf_est(lst, 2)';
        A_median(index, :)    = cmf_est(lst, 3)';
        A_75(index, :)        = cmf_est(lst, 4)';
        A_diff(index, :)      = cmf_est(lst, 4)' - cmf_est(lst, 2)';
        clear cmf_est;

        Sep_expt_lbl{index, 1}    = [pf, ' #', num2str(data_index)];
        expt_lbl{index + 1, 1}    = [pf, ' #', num2str(data_index)];
        
        clear dyn_err prm_err sort_dyn_err sort_prm_err d50 p50 dyn_mean prm_mean;
        prm_err = fn_estm_error(PRM_nest);
        sort_prm_err = sort(prm_err);
        
        co = size(sort_prm_err, 1);
        p50 = mean(sort_prm_err([floor(co/2), 1 + floor(co/2)], 1));
        prm_mean = mean(sort_prm_err);
        prm_err0(index, :) = [sort_prm_err(floor(co/4), 1), p50, ...
            sort_prm_err(floor(3*co/4), 1), prm_mean];
        
    end
end

for prm_ind = 1:n_prm
    A_sep(:, prm_ind) = abs(A_median(:, prm_ind) - prm_log_GT(prm_ind, 1));
end

A_Sep_lbl = Sep_expt_lbl;

%% Time of measurements for all the designs
S_all_dsn_info.expt_ind = Sep_expt_lbl;
S_all_dsn_info.ToM      = measure_tim;
T_all_dsn_info          = struct2table(S_all_dsn_info);


S_cls_dsn_info.expt_ind = [1:n_expt_vec(2, 1)]';
S_cls_dsn_info.ToM_SSD  = measure_tim2(:, 1);
S_cls_dsn_info.ToM_W1SD = measure_tim2(:, 2);
S_cls_dsn_info.ToM_W2SD = measure_tim2(:, 3);
T_cls_dsn_info          = struct2table(S_cls_dsn_info);


%%
scoring.expt_ind    = A_Sep_lbl;


%% all 'median and quartile'-based calculations
S_median.expt_ind   = expt_lbl;
S_25_75.expt_ind    = Sep_expt_lbl;
S_dev.expt_ind      = A_Sep_lbl;

prm_ind = 1;
S_median.delta_q50     = [prm_log_GT(prm_ind, 1); A_median(:, prm_ind)];
S_25_75.delta_ci       = A_diff(:, prm_ind);
S_dev.delta_dev_q50    = A_sep(:, prm_ind);

prm_ind = 2;
S_median.base_prd_q50     = [prm_log_GT(prm_ind, 1); A_median(:, prm_ind)];
S_25_75.base_prd_ci       = A_diff(:, prm_ind);
S_dev.base_prd_dev_q50    = A_sep(:, prm_ind);

prm_ind = 3;
S_median.beta_q50    = [prm_log_GT(prm_ind, 1); A_median(:, prm_ind)];
S_25_75.beta_ci      = A_diff(:, prm_ind);
S_dev.beta_dev_q50   = A_sep(:, prm_ind);

prm_ind = 4;
S_median.k12_q50     = [prm_log_GT(prm_ind, 1); A_median(:, prm_ind)];
S_25_75.k12_ci       = A_diff(:, prm_ind);
S_dev.k12_dev_q50    = A_sep(:, prm_ind);

prm_ind = 5;
S_median.k23_q50     = [prm_log_GT(prm_ind, 1); A_median(:, prm_ind)];
S_25_75.k23_ci       = A_diff(:, prm_ind);
S_dev.k23_dev_q50    = A_sep(:, prm_ind);

prm_ind = 6;
S_median.k31_q50     = [prm_log_GT(prm_ind, 1); A_median(:, prm_ind)];
S_25_75.k31_ci       = A_diff(:, prm_ind);
S_dev.k31_dev_q50    = A_sep(:, prm_ind);

T_median    = struct2table(S_median);
T_25_75     = struct2table(S_25_75);
T_dev       = struct2table(S_dev);


%% error in parameter estimation and dynamics prediction

Errs.expt_ind      = A_Sep_lbl;

Errs.errPRM        = blank;

Errs.errPRM_q25    = round(prm_err0(:, 1), 2);
Errs.errPRM_q50    = round(prm_err0(:, 2), 2);
Errs.errPRM_q75    = round(prm_err0(:, 3), 2);
Errs.errPRM_avg    = round(prm_err0(:, 4), 2);

T_Errs = struct2table(Errs);


%%
errPRM_avg          = round(prm_err0(:, 4), 2);
[vecs1, inds1]      = sort(errPRM_avg);
S1_srt              = pf_mrkr(inds1, :);
cS1_srt(1, :)       = S1_srt(1, :);
for nr = 2:size(S1_srt, 1)
    cS1_srt(nr, :)   = cS1_srt(nr - 1, :) + S1_srt(nr, :);
end

S1.sort_expt_ind    = A_Sep_lbl(inds1, 1);
S1.sort_errPRM_avg  = vecs1;

S1.good_SSDs        = cS1_srt(:, 1)/n_expt_vec(1, 1);
S1.good_W1SDs       = cS1_srt(:, 2)/n_expt_vec(2, 1);
S1.good_W2SDs       = cS1_srt(:, 3)/n_expt_vec(3, 1);
S1.good_SRDs        = cS1_srt(:, 4)/n_expt_vec(4, 1);
S1.good_TUDs        = cS1_srt(:, 5)/n_expt_vec(5, 1);


T1 = struct2table(S1);

%%
T_score     = struct2table(scoring);

excel_file = [res_folder, '/summary.xlsx'];
warning('off','MATLAB:xlswrite:AddSheet'); %optional
writetable(T_all_dsn_info, excel_file, 'Sheet', 1); %, 'All Designs');
writetable(T_cls_dsn_info, excel_file, 'Sheet', 2); %, 'Cluster-driven Designs');

writetable(T_median, excel_file, 'Sheet', 3); %, 'Median estimate');
writetable(T_25_75, excel_file, 'Sheet', 4); %, '{q75}-{q25}');
writetable(T_dev, excel_file, 'Sheet', 5); %, '|Median - GT|');

writetable(T_Errs, excel_file, 'Sheet', 6); %, 'Error in Estimate & Prediction');
writetable(T1, excel_file, 'Sheet', 7); %, 'Error in Estimate');

save([res_folder, '/summary.mat'])








