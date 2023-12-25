function plot_fitting(info)
warning off;
%% figure formatting
ms = 15; lw_ind = 0.05; cs = 10; lw_mean = 2; ms_ind = 2; lw_err = 1.5;
fx0 = 0.05; fy0 = 0.05; fx1 = 0.3; fy1 = 0.6;
fs = 32;

%% information
img_file_name = [info.system_id, '_sim'];

system_index    = info.system_ind;
obs             = info.obs;

load([info.info_fit_folder, '/', info.ABC_FAR_file, '.mat'], 'PRM_nest');
colors = [  0.00      0.00      0.00;
            0         0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840
];

col_A = colors(2, :);
col_B = colors(3, :);
col_C = colors(4, :);

if      system_index == 1
    yd = obs.y_act;
elseif  system_index == 2
    yd = obs.y_rep;
elseif  system_index == 3
    yd = obs.y_iffl;
end
t_fin = obs.t_fin; tspan = [min([0; t_fin]), max(t_fin)];
y0 = obs.y0_GT;

t_pred = [tspan(1, 1):1:tspan(1, 2)]';
%% simulation
[thres, n_prm, n_nest] = size(PRM_nest);
PRM_last = PRM_nest(:, :, n_nest);

f = figure('Units', 'normalized', 'Position', [fx0 fy0 fx1 fy1]);
ax = axes('Parent', f); hold(ax, 'on');

A_mean = zeros(size(t_pred));
B_mean = zeros(size(t_pred));
C_mean = zeros(size(t_pred));

for iter = 1:thres
    clear prm t_iter y_iter pred_Mprey pred_Mpredator;
    prm = PRM_last(iter, :)';
    if      system_index == 1
        [t_iter,y_iter] = ode23s(@(t_iter,y_iter) act3_model1(prm, t_iter, y_iter), tspan, y0);
    elseif  system_index == 2
        [t_iter,y_iter] = ode23s(@(t_iter,y_iter) rep3_model1(prm, t_iter, y_iter), tspan, y0);
    elseif  system_index == 3
        [t_iter,y_iter] = ode23s(@(t_iter,y_iter) IFFL3_model1(prm, t_iter, y_iter), tspan, y0);
    end
    pred    = interp1(t_iter, y_iter, t_pred);
    pred_MA = pred(:, 1);
    pred_MB = pred(:, 2);
    pred_MC = pred(:, 3);

%     plot1 = plot(t_pred, pred_MA, '-', ...
%         t_pred, pred_MB, '-', ...
%         t_pred, pred_MC, '-',...
%         'LineWidth', lw_ind, 'Markersize', ms_ind);
% 
%     set(plot1(1), 'Color', 0.9+0.01*col_A);
%     set(plot1(2), 'Color', 0.9+0.01*col_B);
%     set(plot1(2), 'Color', 0.9+0.01*col_C);

    A_mean = A_mean + pred_MA/thres;
    B_mean = B_mean + pred_MB/thres;
    C_mean = C_mean + pred_MC/thres;
    clear plot1;
end
disp([t_fin, yd]);
errorbar(t_fin, yd(:, 1), 0.5 * ones(size(t_fin)), 'o',...
    'Color', col_A, 'MarkerSize', ms, 'Linewidth', lw_err);
errorbar(t_fin, yd(:, 2), 0.5 * ones(size(t_fin)), 'o',...
    'Color', col_B, 'MarkerSize', ms, 'Linewidth', lw_err);
errorbar(t_fin, yd(:, 3), 0.5 * ones(size(t_fin)), 'o',...
    'Color', col_C, 'MarkerSize', ms, 'Linewidth', lw_err);

plot_mean = plot(t_pred, A_mean, '-',...
    t_pred, B_mean, '-',...
    t_pred, C_mean, '-',...
    'LineWidth', lw_mean);
set(plot_mean(1), 'Color', col_A);
set(plot_mean(2), 'Color', col_B);
set(plot_mean(3), 'Color', col_C);

set(ax, 'FontSize', fs, 'LineWidth', 1.5, 'TickLength',...
    [0.015 0.15], 'TickDir', 'both');
xlabel('Time (min.)'); ylabel('Molecules');

ylim([0, 15]);
xlim(tspan);

% legend(legend_names, 'Location', 'NorthWest');
% legend boxoff;
print(f, [info.mainfolder, '/', img_file_name] ,'-djpeg', '-r960');
print(f, [info.mainfolder, '/', img_file_name] ,'-depsc');
% savefig(f,[info.mainfolder, '/', img_file_name, '.fig']);
end