%% PARAMETER INITIALIZATION
% set up max and mix matrices

%% parameter information
load('../../ground_truth_GRN.mat', 'prm_log_GT', 'ini_cond', 'tspan');
prm = prm_log_GT;

pmin = prm - log10(1.2);
pmax = prm + log10(1.2);

% PARAMETER BASELINE VALUES
disp(prm);
clear prm;

%% TIME SPAN OF THE SIMULATION
t_bgn = tspan(1, 1); t_end = tspan(end, 1);
clear tspan;
tim_d = 3;
tspan = [t_bgn : tim_d : t_end]; % time points of model calculation
MT = [tim_d : tim_d : t_end]'; % time points of QT calculation

% INITIAL CONDITION FOR THE ODE MODEL
y0 = ini_cond;

% Parameter Labels 
prm_name = {'\delta', 'b_p', '\beta', 'K1', 'K2', 'K3', 'DM'};
efast_var = prm_name;
% Variables Labels
y_var_label={'A', 'B', 'C'};
