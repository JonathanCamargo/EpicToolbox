addpath(genpath('/Users/sheamcmurtry/Dropbox (GaTech)/ROSBAG FILES/'))
addpath(genpath('~smcmurtry3/EpicToolbox'));
%% test with new code segment and normalize
rosbag_path=('SAMPLE_DATA/5.mat');
experiment_data=load(rosbag_path);
experiment_data=timeshift(experiment_data,'auto',Topics.internal);
warning off;
segmented=segment(experiment_data);
mask=filtering(segmented);
filtered=segmented(~mask);
normalized=normalize(filtered);
interpolated=interpolate(normalized,0:0.001:1);
[meanvals,std_vals,maxvals,minvals]=average(interpolated);
warning on;


%% Example : Plots
% Plot kinematics
Topics.plot(normalized{1},'kinematics');
