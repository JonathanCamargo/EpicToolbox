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
%power analyisis 
power=Power_anaylsis(interpolated);
%%
 %h=plot_kinematics(interpolated,varargin)