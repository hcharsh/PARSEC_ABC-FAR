% %% housekeeping
% clear all;
% clc;
% close all;
% warning off;
% format shortG;
% data0_file = '../ED_C5_v2_moi1_2hr/data0.mat';

function [prm_err] = fn_estm_error(PRM_nest)

load('../ground_truth_GRN.mat', 'prm_log_GT');

free_log_GT = prm_log_GT(1:6, 1);
cut_off     = size(PRM_nest, 1);
n_nest      = size(PRM_nest, 3);
PARAMETER = PRM_nest(:, :, n_nest);
clear PRM_nest;
% info0.obs = Data_grn;
% info0.initial_condition = y0;
% info0.tspan = tspan;
% info0.work_progress_nest = 0;

for prm_ind = 1:cut_off
    clear prm dev sq_dev rssq;
    prm = PARAMETER(prm_ind, :)';
    dev = abs(prm - free_log_GT);
    sq_dev = dev.^2; ssq = sum(sq_dev);
    rssq = sqrt(ssq);
    prm_err(prm_ind, 1) = rssq;
end

end