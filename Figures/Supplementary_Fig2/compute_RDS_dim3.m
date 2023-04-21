clc;
clear;
close all;
addpath('../GOBI') 

%% parameter
period = 2*pi;
num_component = 4;
thres_noise = 0;
dimension = 3;

%% create pair (cause1, cause2, cause3, target)
component_list = [
    [1,2,3,4];
    [1,2,4,3];
    [1,3,4,2]];

%% calculate score
filename = 'sample_timeseries';
load(filename)

%% calculate score
S_total = zeros(length(component_list(:,1)),2^dimension,num_data);
L_total = zeros(length(component_list(:,1)),2^dimension,num_data);

for i = 1:num_data
    
    y_target = cell2mat(y_total(i));
    t_target = t;

    S_tmp = zeros(length(component_list(:,1)),2^dimension);
    L_tmp = zeros(length(component_list(:,1)),2^dimension);
    
    for j = 1:length(component_list(:,1))
        st1 = component_list(j,1);
        st2 = component_list(j,2);
        st3 = component_list(j,3);
        ed = component_list(j,4);

        [score_list, t_1, t_2] = RDS_dim3(y_target(:,st1), y_target(:,st2), y_target(:,st3), y_target(:,ed), t_target, time_interval);
        for k = 1:8
            score = reshape(score_list(:,:,k),[length(t),length(t)]);
            loca_plus = find(score > thres_noise);
            loca_minus = find(score < -thres_noise);
            if isempty(loca_plus) && isempty(loca_minus)
                s = 1;   
            else
                s = (sum(score(loca_plus)) + sum(score(loca_minus)))/ (abs(sum(score(loca_plus))) + abs(sum(score(loca_minus))));
            end
            l = (length(loca_minus) + length(loca_plus)) / (length(t_1)*length(t_2)/2);
            S_tmp(j,k) = s;
            L_tmp(j,k) = l;
        end
    end
    S_total(:,:,i) = S_tmp;
    L_total(:,:,i) = L_tmp;
end
filename = 'sample_result_dim3';
save(filename,'S_total','L_total','component_list','dimension','num_component','period','num_data')
