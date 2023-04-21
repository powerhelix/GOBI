clc;
clear;
close all;

%% parameters
time_interval = 1/60;
num_component = 7;
num_data = 100;
range_extention = 0.5;

%% Find the range of original time-series
% simulate in large time scale
initial = ones(1,num_component);
period = 100;
tspan = linspace(0,period, period/time_interval+1);

[t_ori, y_ori] = ode15s(@(t,y) cAMP(t,y), tspan, initial);

figure(1) % original time-series
plot(t_ori, y_ori(:,1), 'k')
hold on
plot(t_ori, y_ori(:,2), 'r')
hold on
plot(t_ori, y_ori(:,3), 'b')
hold on

% find period using peaks
[~,locs]=findpeaks(y_ori(:,1));
period = (locs(end) - locs(end-1)) * time_interval;
period = ceil(period);
period = 5;

% find range of time-series
st_period = locs(end-1);
ed_period = locs(end);
range = zeros(num_component,2);
for i = 1:num_component
    range(i,1) = min(y_ori(st_period:ed_period,i)) * range_extention;
    range(i,2) = max(y_ori(st_period:ed_period,i)) * (1+range_extention);
end

%% create time-series with various initial value
% create initials
initials  =  rand([num_data,num_component])*1;
for i = 1:num_component
    initials(:,i) = initials(:,i) * (range(i,2) - range(i,1)) + range(i,1);
end

% simulate time-series
y_total = {};
tspan = linspace(0,period, period/time_interval+1);
for i = 1:length(initials(:,1))
    [t1, y1] = ode15s(@(t,y) cAMP(t,y), tspan, initials(i,:));
    for j = 1:num_component
        y1(:,j) = y1(:,j) - min(y1(:,j));
        y1(:,j) = y1(:,j) / max(y1(:,j));
    end
    y_total{end+1} = y1;
end
t = t1;

figure(2) % various time-series
for i = 1:20
    y_tmp = cell2mat(y_total(i));
    plot(t/t(end), y_tmp(:,1), 'k')
    hold on
    plot(t/t(end), y_tmp(:,2), 'r')
    hold on
    plot(t/t(end), y_tmp(:,3), 'b')
    hold on
end
xlim([0,1])
xticks([0,1])
xticklabels({'0', 'period'})
yticklabels([])
xlabel('Time')
ylabel('Value of component')
set(gca,'fontsize',16)

% save data
filename = ['cAMP_timeseries'];
save(filename, 'y_total', 't', 'time_interval', 'period','num_component', 'num_data')
filename = ['cAMP_timeseries_fit_0'];
noise_percent = 0;
save(filename, 'y_total', 't', 'time_interval','noise_percent','num_component','num_data','period')