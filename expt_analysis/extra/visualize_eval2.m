clear all;
clc;
close all;
warning off;
format shortG; % % housekeeping

load('../../ground_truth_GRN.mat', 'prm_log_GT');
data0_file = '../ED_C2_3hr_v23/data0.mat';

%% load C_file
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

system_name = [num2str(system_ind),'_', num2str(tim_d), 'hr_', var_l];
expt_folder = ['../ED_C', system_name]; mkdir(expt_folder);
res_folder = ['../RES_C', system_name]; mkdir(expt_folder);
info_fit_folder = [res_folder, '/info_fit'];

clustering_folder = ['../clustering/DES_', num2str(n_cluster_sync)];
C_file = [clustering_folder, '/C', num2str(system_ind),'_', num2str(tim_d), 'hr_', var_l, '.mat'];

load(C_file, 'k_clstr')
prm_log_GT = round(prm_log_GT, 2);
expt_lbl{1, 1} = 'GT';

% DC = SSD; SC1 = W1SD; SC2 = W2SD; RD = SRD; TD = TUD;
prefix_list = {'SSD', 'W1SD', 'W2SD', 'SRD', 'TUD'};

%% load the data file
load([res_folder, '/summary.mat'], 'Errs', 'S1');
errPRM = Errs.errPRM_avg;
ind = 0;        errPRM_SSD  = errPRM(ind + 1:ind + 100, 1);
ind = 100;      errPRM_W1SD = errPRM(ind + 1:ind + 40, 1);
ind = 140;      errPRM_W2SD = errPRM(ind + 1:ind + 40, 1);
ind = 180;      errPRM_SRD  = errPRM(ind + 1:ind + 100, 1);
ind = 280;      errPRM_TUD  = errPRM(ind + 1:ind + 4, 1);

srvERR  = [S1.sort_errPRM_avg(1, 1); S1.sort_errPRM_avg];
srvSSD  = [0; S1.good_SSDs];
srvW1SD = [0; S1.good_W1SDs];
srvW2SD = [0; S1.good_W2SDs];
srvSRD  = [0; S1.good_SRDs];
srvTUD  = [0; S1.good_TUDs];

%% figure formatting
ms = 25; lw = 2;
fx0 = 0.1; fy0 = 0.1; fx1 = 0.5; fy1 = 0.5; % fx1 = 0.35;
fs = 28;
grid_clr = zeros(40, 1);
grid_clr(2 * [1:20], 1) = 2;


%% f4
% k_clstr.sample(:, iter) = idx;
% k_clstr.intraDist(iter, :) = round(sumd, 4);
ID = log10(k_clstr.sum_intraDist);
TD = log10(k_clstr.totalDist);


colors = [  0.00      0.00      0.00;
            0         0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840
];
col1 = colors(2, :);
fx1 = 0.4; fy1 = 0.55; ms = 20;
f4 = figure('Units', 'normalized', 'Position',[fx0 fy0 fx1 fy1]);
ax4 = axes('Parent',f4); hold on;

p4 = plot(errPRM_SSD(1:40, 1), errPRM_W1SD, '.'...
    , 'Linewidth', lw, 'MarkerFaceColor', col1, 'Markersize', ms, 'MarkerEdgeColor', col1);

p4 = plot(errPRM_SSD(1:40, 1), errPRM_W2SD - errPRM_W1SD, '.'...
    , 'Linewidth', lw, 'MarkerFaceColor', 'r', 'Markersize', ms, 'MarkerEdgeColor', 'r');

% p1 = plot(errPRM_SSD, TD, '.'...
%     , 'Linewidth', lw, 'MarkerFaceColor', 'k', 'Markersize', ms, 'MarkerEdgeColor', col1);

% p2 = plot(errPRM_SSD, TD - ID, '.'...
%     , 'Linewidth', lw, 'MarkerFaceColor', 'r', 'Markersize', ms, 'MarkerEdgeColor', 'r');

% ylim([0, 2]);
xlim([0, 2]);
ylabel('Error_{W1SD}')
xlabel('Error_{SSD}')

set(ax4, 'TickLength', [0.03 0.03], 'TickDir', 'out'...
    ..., 'YTick', [-1:0.5:1]...
    , 'Linewidth', lw...
    , 'XTick', [0:0.5:2]..., 'XTickLabel', x_axis_lbl...
    , 'Fontsize', fs...
    );

% print(f4, [res_folder, '/vis/corr_grn_6'],'-depsc') 
% % print(f4, [res_folder, '/vis/corr_grn_6'],'-djpeg','-r960') 
% pause(10);
% 
% clear f4 ax4; close all;
% 
% save([res_folder, '/vis/s.mat']);


