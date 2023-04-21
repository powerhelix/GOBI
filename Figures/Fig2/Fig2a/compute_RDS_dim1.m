clc;
clear;
close all;

addpath('../../GOBI') 
%% parameter
thres_noise = 0;

%% load data
filename = 'sample_timeseries';
load(filename)

%% create pair
component_list = [
    [1,2];
    [1,3];
    [2,3];
    [3,2]];

%% start parallel pool
parpool threads;
clear completedJobs;
dq = parallel.pool.DataQueue;
wb = waitbar(0,'Processing');
N = num_data;
Listener = afterEach(dq, @(varargin) waitbar((completedJobs/N),wb,sprintf('Completed: %d', completedJobs(1))));


%% calculate score
S_total = zeros(length(component_list(:,1)),2,num_data);
L_total = zeros(length(component_list(:,1)),2,num_data);

parfor i = 1:num_data
    send(dq, i)
    y_target = cell2mat(y_total(i));
    t_target = t;

    S_tmp = zeros(length(component_list(:,1)),2);
    L_tmp = zeros(length(component_list(:,1)),2);
    for j = 1:length(component_list(:,1))
        st = component_list(j,1);
        ed = component_list(j,2);

        [score_list, t_1, t_2] = RDS_dim1(y_target(:,st), y_target(:,ed), t_target, time_interval);
        for k = 1:2
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

filename = 'sample_RDS_dim1';
save(filename,'S_total','L_total','component_list','num_data')

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