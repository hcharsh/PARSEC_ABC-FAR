clear all; close all; clc; warning off;

%% TSA analysis
run('TSA\Model_efast.m');
run('TSA\plot_TSA.m');

%% Clustering and experiment design
run('PARSEC\make_designs.m');
run('PARSEC\gen_data_GRN.m');

%% model fitting and evaluation of the designs
run('expt_analysis\macro_GRN.m');
run('expt_analysis\analysis_script_fin.m');

% % post-evaluation
% run('expt_analysis\visualize_eval.m');
% % % mention the clustering rlz number as expt_ind, in the following file
% run('clustering/overlap_dyn_clustering.m');
