clc;
clear;
close all;

%% parameter
dimension = 2;
thres_L = 0.01;

%% load data
filename = 'sample_result_dim2';
load(filename)

num_pair = length(component_list(:,1));
num_type = 2^dimension;

%% tick
tick_total_x = {
    'A -> C & B -> C';
    'A -> C & B -| C';
    'A -| C & B -> C';
    'A -| C & B -| C';
    'A -> D & B -> D';
    'A -> D & B -| D';
    'A -| D & B -> D';
    'A -| D & B -| D';
    'A -> B & C -> B';
    'A -> B & C -| B';
    'A -| B & C -> B';
    'A -| B & C -| B';
    'A -> D & C -> D';
    'A -> D & C -| D';
    'A -| D & C -> D';
    'A -| D & C -| D';
    'A -> B & D -> B';
    'A -> B & D -| B';
    'A -| B & D -> B';
    'A -| B & D -| B';
    'A -> C & D -> C';
    'A -> C & D -| C';
    'A -| C & D -> C';
    'A -| C & D -| C';
    'B -> D & C -> D';
    'B -> D & C -| D';
    'B -| D & C -> D';
    'B -| D & C -| D';
    'B -> C & D -> C';
    'B -> C & D -| C';
    'B -| C & D -> C';
    'B -| C & D -| B';
    'C -> B & D -> B';
    'C -> B & D -| B';
    'C -| B & D -> B';
    'C -| B & D -| B';};

%% process
x = [1:num_pair * num_type];
S_plot = [];
for i = 1:num_pair
    for j = 1:num_type
        S_tmp = reshape(S_total(i,j,:),[num_data,1]);
        L_tmp = reshape(L_total(i,j,:),[num_data,1]);
        
        L_processed = L_threshold(L_tmp, thres_L);
        S_processed = S_tmp .* L_processed;
        S_processed(S_processed == 0) = NaN;
        S_plot = [S_plot , S_processed];
    end
end

%% plot
figure(1)
b = boxchart(S_plot);

b.BoxWidth = 0.5;
b.BoxFaceColor = [0,0,0];
b.LineWidth = 2;
b.BoxFaceAlpha = 0.1;
b.MarkerStyle = 'none';
yticks([-1,0,1])
xticklabels(tick_total_x)
xlabel('\sigma')
ylabel('S_{\sigma}')
set(gca, 'FontSize',14)


