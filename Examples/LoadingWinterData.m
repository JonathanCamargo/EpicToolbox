%% This script will show you how to load the winter data set which 
%includes Joint angle, torque, power and GRF's using the EpicToolbox functions
addpath(genpath('..'));

[fast_mean_values, fast_std_values]=LoadWinterData('fast');
[slow_mean_values, slow_std_values]=LoadWinterData('slow');
[natural_mean_values, natural_std_values]=LoadWinterData('natural');

%% Example of plotting generically
figure
plot(slow_mean_values.hip.percent_gc ,slow_mean_values.hip.torque)
hold on
plot(natural_mean_values.hip.percent_gc ,natural_mean_values.hip.torque)
plot(fast_mean_values.hip.percent_gc ,fast_mean_values.hip.torque)
legend('slow','natural','fast')

%% TODO Make a plot function that plots ALL Winter Data
