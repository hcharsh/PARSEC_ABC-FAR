% % First order and total effect indices for a given
% % model computed with Extended Fourier Amplitude
% % Sensitivity Test (EFAST).
% % Andrea Saltelli, Stefano Tarantola and Karen Chan.
% % 1999. % "A quantitative model-independent method for global
% % sensitivity analysis of model output". % Technometrics 41:39-56
clear all;
close all;
warning off;
clc;

%% INPUT
NR = 5; %: no. of search curves - RESAMPLING

k = 6 + 1; % # of input factors (parameters varied) + dummy parameter
% # of inout factors same as number of free parameters

NS = 500; % # of samples per search curve

wantedN=NS*k*NR; % wanted no. of sample points

% OUTPUT
% SI[] : first order sensitivity indices
% STI[] : total effect sensitivity indices
% Other used variables/constants:
% OM[] : vector of k frequencies
% OMi : frequency for the group of interest
% OMCI[] : set of freq. used for the compl. group
% X[] : parameter combination rank matrix
% AC[],BC[]: fourier coefficients
% FI[] : random phase shift
% V : total output variance (for each curve)
% VI : partial var. of par. i (for each curve)
% VCI : part. var. of the compl. set of par...
% AV : total variance in the time domain
% AVI : partial variance of par. i
% AVCI : part. var. of the compl. set of par.
% Y[] : model output

MI = 4; %: maximum number of fourier coefficients
% that may be retained in calculating the partial
% variances without interferences between the
% assigned frequencies

%% PARAMETERS AND ODE SETTINGS (they are included in the following file)
Parameter_settings_EFAST;

% Computation of the frequency for the group
% of interest OMi and the # of sample points NS (here N=NS)
OMi = floor(((wantedN/NR)-1)/(2*MI)/k);
NS = 2*MI*OMi+1;
if(NS*NR < 65)
    fprintf(['Error: sample size must be >= ' ...
    '65 per factor.\n']);
    return;
end


%% Pre-allocation of the output matrix Y
%% Y will save only the points of interest specified in
%% the vector time_points
% Y(NS,length(1),length(y0),length(pmin),NR)=0;  % pre-allocation

% Loop over k parameters (input factors)
for i=1:k           % i=# of replications (or blocks)
    % Algorithm for selecting the set of frequencies.
    % OMci(i), i=1:k-1, contains the set of frequencies
    % to be used by the complementary group.
    OMci = SETFREQ(k,OMi/2/MI,i);   
    % Loop over the NR search curves.
    tic
    for L=1:NR
        disp([i L]);
        % Setting the vector of frequencies OM
        % for the k parameters
        cj = 1;
        for j=1:k
            if(j==i)
                % For the parameter (factor) of interest
                OM(i) = OMi;
            else
                % For the complementary group.
                OM(j) = OMci(cj);
                cj = cj+1;
            end
        end
        % Setting the relation between the scalar
        % variable S and the coordinates
        % {X(1),X(2),...X(k)} of each sample point.
        FI = rand(1,k)*2*pi; % random phase shift
        S_VEC = pi*(2*(1:NS)-NS-1)/NS;
        OM_VEC = OM(1:k);
        FI_MAT = FI(ones(NS,1),1:k)';
        ANGLE = OM_VEC'*S_VEC+FI_MAT;
        
        X(:,:,i,L) = 0.5+asin(sin(ANGLE'))/pi; % between 0 and 1
        
        % Transform distributions from standard
        % uniform to general.
        X(:,:,i,L) = parameterdist(X(:,:,i,L),pmax,pmin,0,1,NS,'unif'); %%this is what assigns 'our' values rather than 0:1 dist
        % Do the NS model evaluations.
        for run_num=1:NS
            % [i run_num L] % keeps track of [parameter run NR]
            % ODE solver call
            clear free_prm prm t y;
%             for index123 = 1:size(X, 2)
%                 prm(index123, 1) = X(run_num, index123, i, L);
%             end
            prm(:, 1) = X(run_num, :, i, L)';
            [t,y]=ode23s(@(t,y) rep3_model1(t, y, prm), tspan, y0);
            
            MY = interp1(t, y, MT);
            QT_interest = analyze_this(MY); % disp(QT_interest(1:4, 1)');

            % If the upper line doesn't work
            for QT_ind = 1:size(QT_interest, 1)
                Y(run_num, 1, QT_ind, i, L) = QT_interest(QT_ind,1);
            end
            
        end %run_num=1:NS
    end % L=1:NR
    toc
end % i=1:k
save(['TSA_', num2str(tim_d), 'hr.mat']);

[sy1, sy2, sy3, sy4, sy5] = size(Y);
% CALCULATE Si AND STi for each resample (1,2,...,NR) [ranges]
[Si,Sti,rangeSi,rangeSti] = efast_sd(Y,OMi,MI,1,1:sy3);
% save(['output', num2str(system_ind), '.mat']);
% 
% % clear all;
% 
% load(['output', num2str(system_ind), '.mat'], 'Si', 'Sti');
[s1, s2, s3] = size(Si);
for a = 1:s1
    for b = 1:s3
        Si_mat(a, b) = Si(a, 1, b)/sum(Si(:, 1, b));
        Sti_mat(a, b) = Sti(a, 1, b)/sum(Sti(:, 1, b));
    end
end

save(['TSA_', num2str(tim_d), 'hr.mat']);
