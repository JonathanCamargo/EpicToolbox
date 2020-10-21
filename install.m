!synclient HorizEdgeScroll=0 HorizTwoFingerScroll=0
clc; clear; close all;

fprintf('Installing EPICTOOLBOX...\n');

%% Add the paths as needed
addpath(genpath('lib'));
addpath(genpath('Normalization'));
addpath(genpath('Devices'));
addpath(genpath('Filtering'));
addpath(genpath('Resampling'));
addpath(genpath('Segmentation'));
addpath(genpath('Averaging'));
addpath('MachineLearning');
addpath(genpath('Power'));
addpath(genpath('extlib'));
addpath(genpath('sfpost'));
addpath(genpath('WinterReferenceData'));
addpath('.');
savepath();
fprintf('Scripts added to path...\n');
fprintf('Path saved\n');
