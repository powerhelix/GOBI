clc;
clear;
close all;
addpath('../GOBI') 

%% parameters

dimension = 1;
thres_noise = 1e-5;
num_data = 1;

%% import parameters
%load(['timeseries_self_pos_',num2str(num_data)])
load(['timeseries_',num2str(num_data)])
%% Create pairs of component for one dimensional regulation
component = [1:num_component];
component_list_dim1_tmp = nchoosek(component, 2);
component_list_dim1 = [];
for i = 1:length(component_list_dim1_tmp(:,1))
    component_list_dim1 = [component_list_dim1 ; [component_list_dim1_tmp(i,1), component_list_dim1_tmp(i,2)]];
    component_list_dim1 = [component_list_dim1 ; [component_list_dim1_tmp(i,2), component_list_dim1_tmp(i,1)]];
end
num_pair = length(component_list_dim1(:,1));
num_type = 2^dimension;

%% Calculate regulation-detection-score (S) & size of the regulation-detection region (L)
S_total = zeros(length(component_list_dim1(:,1)),2^dimension,num_data);
L_total = zeros(length(component_list_dim1(:,1)),2^dimension,num_data);

for j = 1:length(y_total)

    y_target = cell2mat(y_total(j));
    S = zeros(num_pair,num_type);
    L = zeros(num_pair,num_type);

    for i = 1:num_pair
        % calculate regulation detection function
        st = component_list_dim1(i,1);
        ed = component_list_dim1(i,2);
        [score_list, t_1, t_2] = RDS_ns_dim1(y_target(:,st), y_target(:,ed), t, time_interval);

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
filename = ['RDS_self_pos_dim1_',num2str(num_data)];
save(filename, 'S_total', 'L_total','component_list_dim1','num_data','num_type','num_pair','dimension')

