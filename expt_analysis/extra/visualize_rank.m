clear all;
clc;
close all;
warning off;
format shortG; % % housekeeping

%% data
system_name = [num2str(2),'_', num2str(3), 'hr_', 'v23'];
res_folder = ['../RES_C', system_name];
load([res_folder, '\summary.mat'], 'errPRM_avg', 'n_expt_vec');
EP = errPRM_avg([1:140, 181:280], 1);
ESD([1:240], 1) = 0; ESD([1:100], 1) = 1;
EWD([1:240], 1) = 0; EWD([101:140], 1) = 1;
ERD([1:240], 1) = 0; ERD([141:240], 1) = 1;

[EPs, rank] = sort(EP);
rESD = ESD(rank, 1);
rEWD = EWD(rank, 1);
rERD = ERD(rank, 1);







%% figure formatting
ms = 25; lw = 2;
fx0 = 0.1; fy0 = 0.1; fx1 = 0.8; fy1 = 0.2; % fx1 = 0.35;
fs = 28;
grid_clr = zeros(40, 1);
grid_clr(2 * [1:20], 1) = 2;
colors = [  0.00      0.00      0.00;
            0         0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840
];

%% f
f1 = figure('Units', 'normalized', 'Position',[fx0 fy0 fx1 fy1]);
ax1 = axes('Parent', f1);
bar(rESD, 1, 'b');
set(ax1, 'TickLength', [0.03 0.03], 'TickDir', 'out'...
    , 'Linewidth', lw...
    , 'XTick', [10, 50, 100, 150, 200, 240]...
    , 'Fontsize', fs...
    );
print(f1, [res_folder, '/vis/ranking_ESD'],'-depsc')

f2 = figure('Units', 'normalized', 'Position',[fx0 fy0 fx1 fy1]);
ax2 = axes('Parent', f2);
bar(rEWD, 1, 'y');
set(ax2, 'TickLength', [0.03 0.03], 'TickDir', 'out'...
    , 'Linewidth', lw...
    , 'XTick', [10, 50, 100, 150, 200, 240]...
    , 'Fontsize', fs...
    );
print(f2, [res_folder, '/vis/ranking_EWD'],'-depsc') 

f3 = figure('Units', 'normalized', 'Position',[fx0 fy0 fx1 fy1]);
ax3 = axes('Parent', f3);
bar(rERD, 1, 'r');
set(ax3, 'TickLength', [0.03 0.03], 'TickDir', 'out'...
    , 'Linewidth', lw...
    , 'XTick', [10, 50, 100, 150, 200, 240]...
    , 'Fontsize', fs...
    );
print(f3, [res_folder, '/vis/ranking_ERD'],'-depsc') 

% xlim([0, 240]);
% ylabel('Error_{W1SD}')
% xlabel('Error_{SSD}')
% 
% set(ax1, 'TickLength', [0.03 0.03], 'TickDir', 'out'...
%     ..., 'YTick', [-1:0.5:1]...
%     , 'Linewidth', lw...
%     , 'XTick', [0:0.5:2]..., 'XTickLabel', x_axis_lbl...
%     , 'Fontsize', fs...
%     );
% 
% print(f1, [res_folder, '/vis/ranking'],'-depsc') 
% % print(f1, [res_folder, '/vis/corr_grn_6'],'-djpeg','-r960') 
% % save([res_folder, '/vis/s.mat']);
% 
