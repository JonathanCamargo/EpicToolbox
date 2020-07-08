%% Example: Averaging Signal
clear
close all
clc
%% Basic data processing
    %this code should be used to run all basic functions prior to analyzing
    %data. 

addpath(genpath('/Users/sheamcmurtry/Dropbox (GaTech)/ROSBAG FILES/'))
addpath(genpath('~smcmurtry3/EpicToolbox'));
init();
%% test with new code segment and normalize
%load data
rosbag_path=('SAMPLE_DATA/5.mat');
experiment_data=load(rosbag_path);
experiment_data=timeshift(experiment_data,'auto',Topics.internal);
warning off;
%segment data into gait cycles
segmented=segment(experiment_data);
%filter data
mask=filtering(segmented);
filtered=segmented(~mask);
%normalize data to % gait cycle
normalized=normalize(filtered);
%interpolate data to 1000 data points 
interpolated=interpolate(normalized,0:0.001:1);
%basic stats
[meanvals,std_vals,maxvals,minvals]=average(interpolated);
%% Averaging Signal
[averaged, std_signal] = average(interpolated);
%% Average plotting 
% [averaged, std_signal] = average(interpolated);
% figure(1)
% plot(averaged{1}.knee.joint_state.Header, averaged{1}.knee.joint_state.Theta, 'r', 'LineWidth', 2);
% hold on
% plot(minus1std{1}.knee.joint_state.Header, minus1std{1}.knee.joint_state.Theta, 'k', 'LineWidth', 1);
% hold on
% plot(plus1std{1}.knee.joint_state.Header, plus1std{1}.knee.joint_state.Theta, 'k', 'LineWidth', 1);
% 
% figure(2)
% plot(averaged{1}.ankle.joint_state.Header, averaged{1}.ankle.joint_state.Theta, 'b', 'LineWidth', 2);
% hold on
% plot(minus1std{1}.ankle.joint_state.Header, minus1std{1}.ankle.joint_state.Theta, 'k', 'LineWidth', 1);
% hold on
% plot(plus1std{1}.ankle.joint_state.Header, plus1std{1}.ankle.joint_state.Theta, 'k', 'LineWidth', 1);

%error in plot "cell contents reference from a non-cell array object"