clear all;
clc;
close all;
warning off;
format shortG; % % housekeeping

load('../ground_truth_GRN.mat', 'prm_log_GT');
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


%% f1
f1 = figure('Units', 'normalized', 'Position',[fx0 fy0 fx1 + 0.1 fy1]);
ax1 = axes('Parent',f1); hold on;

b = bar(grid_clr, 'barwidth', 1);
b.FaceColor = 0.9 * [1, 1, 1];
b.EdgeColor = 'none';

p1 = plot([1:40], errPRM_SSD(1:40, 1), '.k', 'markersize', 30, 'Linewidth', lw - 0.5);
p2 = plot([1:40], errPRM_W2SD, 'sk', 'markersize', 10, 'Linewidth', lw + 1 - 0.5);
p3 = plot([1:40], errPRM_W1SD, 'vk', 'markersize', 10, 'Linewidth', lw - 0.5);

xlim([0.5, 40.5]);
ylim([0, 1.6]);
xlabel('Clustering#')
ylabel('Error in estimation')

set(ax1, 'TickLength', [0.0125 0.0125], 'TickDir', 'out'...
    ..., 'YTick', [0:1:x2 + 0*n_prm]+0.5, 'YTickLabel', {}...
    , 'Linewidth', lw...
    ..., 'XTick', x_axis, 'XTickLabel', x_axis_lbl...
    , 'Fontsize', fs...
    );
mkdir([res_folder, '/vis']);
print(f1, [res_folder, '/vis/cls3'],'-depsc') 
% print(f1, [res_folder, '/vis/cls3'],'-djpeg','-r960') 
pause(10);

clear f1 ax1; close all;

%% f2
fx1 = 0.35; fy1 = 0.5;
f2 = figure('Units', 'normalized', 'Position',[fx0 fy0 fx1 fy1]);
ax2 = axes('Parent',f2); hold on;

p4 = plot(srvERR, srvSSD, '-'...
    , srvERR, srvW2SD, '-'...
    , srvERR, srvW1SD, '-'...
    , srvERR, srvSRD, '-'...
    , 'Linewidth', lw);

% p5 = plot(errPRM_TUD(1, 1)*[1, 1], [0, 1], '--', 'color', 0.5*[1, 0, 0], 'Linewidth', lw);
% p6 = plot(errPRM_TUD(2, 1)*[1, 1], [0, 1], '--', 'color', 0.5*[0, 0.5, 1], 'Linewidth', lw);
% p7 = plot(errPRM_TUD(3, 1)*[1, 1], [0, 1], '-', 'color',  [0, 0, 0], 'Linewidth', lw);
% p8 = plot(errPRM_TUD(4, 1)*[1, 1], [0, 1], '--', 'color', 0.5*[1, 1, 0], 'Linewidth', lw);

ylim([0, 1]);
xlim([0, 1.6]);
ylabel('Freq. of better designs')
xlabel('Error in estimation')

set(ax2, 'TickLength', [0.0125 0.0125], 'TickDir', 'out'...
    , 'YTick', [0:0.2:1]...
    , 'Linewidth', lw...
    , 'XTick', [0:0.4:1.6]..., 'XTickLabel', x_axis_lbl...
    , 'Fontsize', fs...
    );

print(f2, [res_folder, '/vis/srv'],'-depsc') 
% print(f2, [res_folder, '/vis/srv'],'-djpeg','-r960') 
pause(10);

clear f2 ax2; close all;

save([res_folder, '/vis/s.mat']);


%% f3 (in higher version of MATLAB)
fx1 = 0.35; fy1 = 0.5;
f3 = figure('Units', 'normalized', 'Position',[fx0 fy0 fx1 fy1]);
ax3 = axes('Parent',f3); hold on;

swarmchart(1*ones(100, 1), errPRM_SRD, 's', 'filled', 'SizeData', 10);
swarmchart(2*ones(40, 1), errPRM_W2SD, '<', 'filled', 'SizeData', 10);
swarmchart(3*ones(40, 1), errPRM_W1SD, '>', 'filled', 'SizeData', 10);
swarmchart(4*ones(100, 1), errPRM_SSD, 'o', 'filled', 'SizeData', 10);

xlim([0.5, 4.5]);
ylim([1, 1.8]);
ylabel('Error in estimation')

set(ax3, 'TickLength', [0.0125 0.0125], 'TickDir', 'out'...
    , 'YTick', [0:0.2:1]...
    , 'Linewidth', lw...
    , 'XTick', [1, 2, 3], 'XTickLabel', {'SSD', 'W2SD', 'W1SD'}...
    , 'Fontsize', fs...
    );

print(f3, [res_folder, '/vis/swarm'],'-depsc') 
print(f3, [res_folder, '/vis/swarm'],'-djpeg','-r960') 



%% f4
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

ylim([0, 2]);
xlim([0, 2]);
ylabel('Error_{W1SD}')
xlabel('Error_{SSD}')

set(ax4, 'TickLength', [0.03 0.03], 'TickDir', 'out'...
    , 'YTick', [-1:0.5:1]...
    , 'Linewidth', lw...
    , 'XTick', [0:0.5:2]..., 'XTickLabel', x_axis_lbl...
    , 'Fontsize', fs...
    );

print(f4, [res_folder, '/vis/diff_grn_6'],'-depsc') 
% print(f4, [res_folder, '/vis/diff'],'-djpeg','-r960') 
pause(10);

clear f4 ax4; close all;

save([res_folder, '/vis/s.mat']);


