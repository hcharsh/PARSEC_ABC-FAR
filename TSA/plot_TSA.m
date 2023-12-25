clear all; clc; % close all; warning off; format shortG; % % housekeeping
system_ind = 2;
tim_d = 3;
TSA_file = ['TSA_', num2str(tim_d), 'hr.mat'];

%% figure formatting
fx0 = 0.05; fy0 = 0.1; fx1 = 0.8; fy1 = 0.7; lw = 1.5;
fs = 32;

%% load chosen parameter sets
load(TSA_file, 'Si_mat', 'Sti_mat', 'prm_name', 'MT'); %, 'tim_d', 'system_ind');
n_tim = size(MT, 1);
mat_Tm = Sti_mat';
n_Si  = size(mat_Tm, 1);
n_prm = size(mat_Tm, 2);
n_QI = 3;

folder_name = 'TSA_results'; mkdir(folder_name);
file_name = ['plot_TSA_', num2str(tim_d), 'hr'];


for ind = 1:n_tim
    nan_vec(ind, 1) = NaN;
end
Z = mat_Tm(1 : n_tim, 1:n_prm - 1);
disp(Z);
for ind_QI = 2:n_QI
    st = (ind_QI - 1) * n_tim + 1; fn = ind_QI * n_tim;
    Z = [Z, mat_Tm(st:fn, 1:n_prm - 1)];
end
Z = [Z, mat_Tm(st:fn, n_prm - 1)];

x1 = size(Z, 1); x2 = size(Z, 2);
% close all;
clear f ax s;
f = figure('Units', 'normalized', 'Position',[fx0 fy0 fx1 fy1]);
ax = axes('Parent',f);
s = surf([1:x1], [1:x2], Z');
xlim([0, 25])
ylim([1, x2])


s.EdgeColor = 'none';

colorbar;
set(ax, 'TickLength', [0.0125 0.0125], 'TickDir', 'out',...
    'YTick', [0:1:x2 + 0*n_prm]+0.5, 'YTickLabel', {}...
    , 'Linewidth', lw...
    , 'XTick', [1, 6:6:24], 'XTickLabel', {'3', '18', '36', '54', '72'}...
    , 'Fontsize', fs...
    );
    caxis(ax,[0, 1]);
view(ax,[0 90]);
grid off;

print(f, [folder_name, '\', file_name],'-depsc') 
print(f, [folder_name, '\', file_name],'-djpeg','-r960') 
save([folder_name, '\', file_name, '.mat']);