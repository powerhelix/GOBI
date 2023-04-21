clc;
clear;
close all;

%% parameter
dimension = 2;
thres_L = 0.01;

%% load data
filename = 'sample_RDS_dim2';
load(filename)

num_pair = length(component_list(:,1));
num_type = 2^dimension;

%% tick
delta_index = [
    [2,3,4];
    [2,1,3];
    [2,2,4];
    [1,1,3];
    [1,1,2]];

tick_total_x = {
    'Z -| X & Y \Delta X';
    'Z \Delta X & Y -> X';
    'Z \Delta X & Y -| X';
    'Z \Delta Y & X -> Y';
    'Z -> Y & X \Delta Y'};

%% Compute regulation-delta function
x = [1:num_pair * num_type];
delta_plot = [];
for i = 1:length(delta_index(:,1))
    S_tmp_1 = reshape(S_total(delta_index(i,1),delta_index(i,2),:),[num_data,1]);
    L_tmp_1 = reshape(L_total(delta_index(i,1),delta_index(i,2),:),[num_data,1]);

    % ignore when the regulation-detection region < R^thres
    L_processed_1 = L_threshold(L_tmp_1, thres_L);
    
    S_processed_1 = S_tmp_1 .* L_processed_1;
    S_processed_1(S_processed_1 == 0) = NaN;
    
    S_tmp_2 = reshape(S_total(delta_index(i,1),delta_index(i,3),:),[num_data,1]);
    L_tmp_2 = reshape(L_total(delta_index(i,1),delta_index(i,3),:),[num_data,1]);

    L_processed_2 = L_threshold(L_tmp_2, thres_L);
    S_processed_2 = S_tmp_2 .* L_processed_2;
    S_processed_2(S_processed_2 == 0) = NaN;
    
    delta_plot = [delta_plot, S_processed_1 - S_processed_2];
end

%% plot regulation-delta function
figure(1)
b = boxchart(delta_plot);

b.BoxWidth = 0.5;
b.BoxFaceColor = [0,0,0];
b.LineWidth = 2;
b.BoxFaceAlpha = 0.1;
b.MarkerStyle = 'none';
yticks([-2,0,2])
xticklabels(tick_total_x)
xlabel('\sigma')
ylabel('\Delta')
set(gca, 'FontSize',14)





