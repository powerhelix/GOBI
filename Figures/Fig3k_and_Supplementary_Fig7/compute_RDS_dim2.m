clc;
clear;
close all;
addpath('../GOBI') 

%% start parallel pool
parpool threads;
clear completedJobs;
dq = parallel.pool.DataQueue;
wb = waitbar(0,'Processing');
N = 10*10*100*7*5;
Listener = afterEach(dq, @(varargin) waitbar((completedJobs/N),wb,sprintf('Completed: %d', completedJobs(1))));

%% parameters

trial_list = [0:9];
noise_list = [2:2:20];
dimension = 2;
thres_noise = 1e-7;
%system_list = {'cAMP','Fr','Gb','GW','KF'};
%noise_type_list = {'additive','blue','brown','pink','purple','dynamical','multiplicative'};

%noise_type_list = {'additive','blue','brown','pink','purple','dynamical','multiplicative'};
noise_type_list = {'additive','blue','pink','multiplicative'};
%noise_type_list = {'additive'};

system_list = {'cAMP'};


for noise_type_idx = 1:length(noise_type_list)
    noise_type = char(noise_type_list(noise_type_idx));
    disp(noise_type)
    for system_idx = 1:length(system_list)
        system = char(system_list(system_idx));
        disp(system)
        for trial = trial_list
            %% import parameters
            load(['./Data_original/',system, '_timeseries_Trial1'])

            %% Create pairs of component for one dimensional regulation
            component = [1:num_component];
            component_list_dim2_tmp = nchoosek(component, 3);
            component_list_dim2 = [];
            for i = 1:length(component_list_dim2_tmp(:,1))
                component_list_dim2 = [component_list_dim2 ; [component_list_dim2_tmp(i,1), component_list_dim2_tmp(i,2), component_list_dim2_tmp(i,3)]];
                component_list_dim2 = [component_list_dim2 ; [component_list_dim2_tmp(i,3), component_list_dim2_tmp(i,1), component_list_dim2_tmp(i,2)]];
                component_list_dim2 = [component_list_dim2 ; [component_list_dim2_tmp(i,2), component_list_dim2_tmp(i,3), component_list_dim2_tmp(i,1)]];
            end
            num_pair = length(component_list_dim2(:,1));
            num_type = 2^dimension;

            %% Start inference framework
            for noise_percent = noise_list
                %disp(noise_percent)

                %% load data
                filename = ['./Data_',noise_type,'_fit/',system,'_timeseries_fit_',num2str(noise_percent),'_Trial',num2str(trial)];
                load(filename)

                %% Calculate regulation-detection-score (S) & size of the regulation-detection region (L)
                S_total = zeros(length(component_list_dim2(:,1)),2^dimension,num_data);
                L_total = zeros(length(component_list_dim2(:,1)),2^dimension,num_data);

                parfor j = 1:length(y_total)
                    send(dq, j)

                    y_target = cell2mat(y_total(j));
                    S = zeros(num_pair,num_type);
                    L = zeros(num_pair,num_type);

                    for i = 1:num_pair
                        % calculate regulation detection function
                        st1 = component_list_dim2(i,1);
                        st2 = component_list_dim2(i,2);
                        ed = component_list_dim2(i,3);
                        [score_list, t_1, t_2] = RDS_ns_dim2(y_target(:,st1), y_target(:,st2), y_target(:,ed), t, time_interval);

                        % calculate S & R
                        s_tmp = zeros(1,num_type);
                        l_tmp = zeros(1,num_type);
                        for k = 1:num_type
                            score = reshape(score_list(:,:,k),[length(t),length(t)]);
                            loca_plus = find(score > thres_noise);
                            loca_minus = find(score < -thres_noise);
                            if isempty(loca_plus) && isempty(loca_minus)
                                s = 1;
                            else
                                s = (sum(score(loca_plus)) + sum(score(loca_minus)))/ (abs(sum(score(loca_plus))) + abs(sum(score(loca_minus))));
                            end

                            l = (length(loca_minus) + length(loca_plus)) / (length(t_1)*length(t_2)/2);

                            s_tmp(k) = s;
                            l_tmp(k) = l;
                        end

                        % save as list
                        S(i,:) = s_tmp;
                        L(i,:) = l_tmp;
                    end

                    S_total(:,:,j) = S;
                    L_total(:,:,j) = L;
                end

                %% Save results
                filename = ['./RDS_dim2_',noise_type,'/',system,'_results_dim2_',num2str(noise_percent),'_Trial',num2str(trial)];
                save(filename, 'S_total', 'L_total','component_list_dim2','num_data','num_type','num_pair','dimension')
            end
        end
    end
end
%% end parallel pool
delete(gcp('nocreate'))

%% function for parallel pool
function j = completedJobs(varargin)
    persistent n
    if isempty(n)
        n = 0;
    end
    if numel(varargin) ~=0
    else
        n = n+1;
    end
    j=n;
end