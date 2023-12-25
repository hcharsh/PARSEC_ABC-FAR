% clear all; clc; close all; warning off; format shortG; % % housekeeping
% n_cluster = 5; n_iter = 5; n_samples = 2;
% dummy_thres = 0.75;
% n_cluster = 5;

function clustering_sync(n_cluster, n_iter, TSA_file, cluster_file, dummy_thres, VAR_INT)
    %% load chosen parameter sets
    load(TSA_file, 'Si_mat', 'Sti_mat', 'prm_name', 'MT', 'y0');
    mat_Tm = Sti_mat';
    n_Si  = size(mat_Tm, 1);
    n_prm = size(mat_Tm, 2);
    n_tim = size(MT, 1);
    n_QI  = n_Si/n_tim;
    
    dm_thres = size(VAR_INT, 2) * dummy_thres / n_prm;

    %% speecific measurements & synchronous - filt_Z (the matrix and label)

    fin_ind = 0;
    nt_ind = 0;

    for t_ind = 1:n_tim
        clear dummy_sum temp;
        dummy_sum = 0;
        temp = [];
        for index = 1:size(VAR_INT, 2)
            ind_QI = VAR_INT(1, index);
            the_index = (ind_QI - 1) * n_tim + t_ind;
            dummy_sum = dummy_sum + mat_Tm(the_index, n_prm);
            temp = [temp, mat_Tm(the_index, 1 : n_prm - 1)];
        end

        if dummy_sum > dm_thres
            nt_ind = nt_ind + 1;
        else
            fin_ind = fin_ind + 1;
            filt_Z(fin_ind, :) = temp;
            filt_Z_lbl{1, fin_ind} = [num2str(t_ind), 'th time pt'];
            filt_TIM(fin_ind, 1) = MT(t_ind, 1);
        end
    end
%     disp([nt_ind, n_tim]);
%     disp(filt_Z);
    %% k_means
    z_prm_mat = zscore(filt_Z);
    k_clstr.measurement_lbl = filt_Z_lbl';
    clear index; index = 0;
    for iter = 1:n_iter
        clear idx centroids sumd DIST;
        [idx, centroids, sumd, DIST] = kmeans(z_prm_mat, n_cluster);
%         disp(idx);
%         disp(centroids);
%         disp(sumd);
%         disp(DIST);
        k_clstr.sample(:, iter) = idx;
        k_clstr.intraDist(iter, :) = round(sumd, 4);
        k_clstr.sum_intraDist(iter, :) = round(sum(sumd), 4);
        k_clstr.totalDist(iter, :) = sum(sum(DIST));
        k_clstr.clstr_lbl{iter, 1} = ['Cluster #', num2str(iter)];
    end
    k1.label = k_clstr.measurement_lbl;
    k1.sample = k_clstr.sample;
    
    k2.lbl = k_clstr.clstr_lbl;
    k2.intraDist = k_clstr.intraDist;
    k2.sum_intraDist = k_clstr.sum_intraDist;
    k2.totalDist = k_clstr.totalDist;
    
    
%     k_clstr_Table  = struct2table(k_clstr);
    k1_Table  = struct2table(k1);
    k2_Table  = struct2table(k2);

    xl_file = [cluster_file, '.xlsx'];
    warning('off','MATLAB:xlswrite:AddSheet'); %optional
    writetable(k1_Table, xl_file, 'Sheet', 1);
    writetable(k2_Table, xl_file, 'Sheet', 2);
    clear k1 k2 k1_Table k2_Table;
    save([cluster_file, '.mat'])
end