clc;
clear;
close all;

addpath('../../GOBI')

%% import data
load('data_cardio.mat')

%% parameter from data
num_component = 5;
length_data = length(y_total);
thres_noise = 1e-9;

%% all the pairs of components for dim1
component = [2:num_component];
component_list_dim4_tmp = nchoosek(component, 4);
component_list_dim4 = [];
for i = 1:length(component_list_dim4_tmp(:,1))
    for j = 1
        if ismember(j, component_list_dim4_tmp(i,:))
            continue
        end
        component_list_dim4 = [component_list_dim4 ; [component_list_dim4_tmp(i,:), j]];
    end
end

num_pair = length(component_list_dim4(:,1));

%% for every data, calculate regulation detection score
disp('calculate regulation detection score...')
S_total_list = zeros(num_pair,16,length_data);
L_total_list = zeros(num_pair,16,length_data);
for i = 1:length_data
    y_target = cell2mat(y_total(i));
    t_target = t(1:length(y_target(:,1)));
    
    S_total =  zeros(num_pair,16);
    L_total =  zeros(num_pair,16);
    for j = 1:length(component_list_dim4(:,1))
        st1 = component_list_dim4(j,1);
        st2 = component_list_dim4(j,2);
        st3 = component_list_dim4(j,3);
        st4 = component_list_dim4(j,4);
        ed = component_list_dim4(j,5);
        [score_list, t_1, t_2] = RDS_ns_dim4(y_target(:,st1), y_target(:,st2), y_target(:,st3), y_target(:,st4), y_target(:,ed), t_target, time_interval);
        
        for k = 1:16
            score = reshape(score_list(:,:,k),[length(t),length(t)]);
            loca_plus = find(score > thres_noise);
            loca_minus = find(score < -thres_noise);
            if isempty(loca_plus) && isempty(loca_minus)
                s = 1;    
            else
                s = (sum(score(loca_plus)) + sum(score(loca_minus)))/ (abs(sum(score(loca_plus))) + abs(sum(score(loca_minus))));
            end
            l = (length(loca_minus) + length(loca_plus)) / (length(t_1)*length(t_2)/2);
            S_total(j,k) = s;
            L_total(j,k) = l;
        end
        
    end
    %save s,r,l at the list
    S_total_list(:,:,i) = S_total;
    L_total_list(:,:,i) = L_total;    
end

component_list = component_list_dim4;
num_data = length_data;
filename = 'RDS_dim4';
save(filename, 'S_total_list', 'L_total_list','component_list', 'num_component', 'num_pair', 'num_data')

