function fit_setup_file_UD(expt_folder, res_folder, pf, ed_index, system_ind)

addpath '../../functions_ABC_FAR';

%% options for the simulations
n_nest = 5; % 4;
acc_rate = 0.025; % 0.025;
n_bins = 30;
cut_off = 20*n_bins;
alpha = 0.25;
use_prev = 1;

% fixed acceptance rate (can be made into a vector)
info.far = acc_rate;
% number of samples being used to get the updated distribution
info.cut_off = cut_off;
% include the best parameter vectors selected in prev. step to update
% parameter distribution in the current step. Default is 1.
info.use_prev = use_prev;
% number of nests or iterations
info.n_nest = n_nest;
% max. sampling error without dummy unbiasing
info.alpha = alpha;
% number of itervals to discretize the each parameter range
info.n_bins = n_bins;

%% data, id and folders
load([expt_folder, '/', pf, '_ED', num2str(ed_index), '.mat'], ...
        'y0', 'tspan', 'Data_grn', 'prm_log_GT');
info.obs = Data_grn; % data is input for the following file
info.initial_condition = y0;
info.tspan = tspan;
info.system_ind = system_ind;

info.system_id = [pf, num2str(ed_index)];
info.error_calc_fn = 'error_grn'; % to be changed in 'fn_calc_error_UD'

mainfolder = res_folder;
info.mainfolder = mainfolder;
% folder name in which the information and fit result files are to be stored
info.info_fit_folder = [mainfolder, '/info_fit'];
mkdir(info.info_fit_folder);

% file name for the fit analysis
info.ABC_FAR_file           = ['full_', info.system_id];
info.ABC_FAR_results_file   = ['sh_', info.system_id];
% don't put .mat extn(s).

%% parameter ranges, prior guess and sampling distribution
% lower (lb) and upper (ub) bounds of each parameter.
% lb and ub are vectors (nx1) following the indexing of info_full.prm_name
% prm  1    02      3   4   5       6     7     8
lb = log10(0.3)*ones(6, 1); lb(1, 1) = -2; lb(2, 1) = -3;
ub =  log10(30)*ones(6, 1); ub(1, 1) =  0; ub(2, 1) = -1;

info.lb = lb;
info.ub = ub;
prm_file_name = {'delta', 'b_p', 'beta', 'K1', 'K2', 'K3'};
prm_disp_name = {'\delta', 'b_p', '\beta', 'K1', 'K2', 'K3'};

info.prm_file_name = prm_file_name;
info.prm_disp_name = prm_disp_name;

% unif_Dist = matrix with n_prm columns of uniform distributions
n_prm = size(lb, 1);
for ind_prm = 1:n_prm
    unif_Dist(:, ind_prm) = linspace(0, 1, n_bins + 1)'; % uniform distribution
end

% the initial guess (or prior distribution) and noise distribution to be
% added while sampling with range normalized between 0 and 1.
info.PriorDistName = 'Uniform prior';
info.PriorDist = unif_Dist;
% To input other distributions, input as a matrix with each columns
% specifying the distribution for each parameter.

info.sampling_noise_DistName = 'Uniform Noise';
info.sampling_noise_Dist = unif_Dist;

%% additional options
info.diary_reqd = 1;
info.work_progress_nest = 1;
info.work_progress_time = 0;

%% 
% devn_prefix = ['devn_', id];
% devn_folder = [mainfolder, '/fit_devn'];

%%
fn_ABC(info);

%% done
disp(['Results saved in ', info.info_fit_folder, '/', info.ABC_FAR_file, '.mat']);
% plot_fitting(info);

end