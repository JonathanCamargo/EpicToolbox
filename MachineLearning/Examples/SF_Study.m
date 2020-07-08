%% SF_Predict
% This script runs functions from the sf_post library on the data collected
% by the sensor fusion subteam during fall 2018. This is meant to serve as
% a framework for everyone to start developing their own scripts
%
% Author: Noel Csomay-Shanklin [noelcs@gatech.edu]
% Date of Last Edit: 2/1/19

%% Download all the subjects EMG and IMU for Treadmill
% Step 1: 
%   Run the download.py script in @FIleManager. For documentation of how to
%   setup dropbox with the repo, please see the sf_post readme.
% Ex:
%   In C:\Users\Noel Csomay-Shanklin\src\sf_post\@FileManager
%   Run --> python download.py --token %DB_TOKEN% --local_path ./../../SF_Treadmill --params ab06 sf2018
% THEN: 
%   take everything out of sf2018 and put it directly in RawMatlab
%   This is a bug-ish, that I will fix in a later release
% All sucessive work should use the local data

fm = FileManager();

%% Generate other dependent variables (gait phase and phasor gait phase)
fileList=fm.fileList('Root','RawMatlab','Sensor','fsr');

createGait = @(s) generateGait(s); % defined at end of file
createGaitxAndy = @(s) generateGaitxAndy(s); % defined at end of file

src=fileList;
dest_gait=fileList;
dest_gait_x_and_y=fileList;

for in=1:numel(fileList)
    src{in}=fullfile('RawMatlab',fileList{in});
    dest_gait{in}=fullfile('RawMatlab',strrep(fileList{in},'fsr','gait'));
    dest_gait_x_and_y{in}=fullfile('RawMatlab',strrep(fileList{in},'fsr','gait_x_and_y'));
end

% We can do multiple files using loadRunSave
% In order to speed things up, we will run these in parallel. If you get an
% error, set Parallelize to false
loadRunSave(createGait,src,'OutputPath',dest_gait,'Save',true,'Parallelize',true);
loadRunSave(createGaitxAndy,src,'OutputPath',dest_gait_x_and_y,'Save',true,'Parallelize',true);

%% Extract Features for Sensors (inputs)
fileList=fm.fileList('Root','RawMatlab','Sensor',{'gon', 'emg', 'imu'});

sensorExtractor = FeatureExtractor('window',200, 'slide', 50, 'MEAN',true,'AR',false,'AROrder',5,'EN',false);
% ExtractFeatures = @(s) sensorExtractor.extractFeatures(s);

src=fileList;
dest=fileList;

for in=1:numel(fileList)
    src{in}=fullfile('RawMatlab',fileList{in});
    dest{in}=fullfile('Features',fileList{in});
end

loadRunSave(ExtractFeatures,src,'OutputPath',dest,'Save',true,'Parallelize',true,'DataType','table');

%% The following part is ambulation mode specific
% This example uses treadmill

%% Extract "features" for time series truth values (outputs)
fileList=fm.fileList('Root','RawMatlab','Ambulation','treadmill','Sensor',{'speed','gait','conditions','gait_x_and_y'});

% The last flag only takes the last value of the "sensor" in the window. We
% do not want to extract any features on the output
lastExtractor = FeatureExtractor('window',200, 'slide', 50, 'LAST', true);
ExtractFeatures = @(s) lastExtractor.extractFeatures(s);

src=fileList;
dest=fileList;

for in=1:numel(fileList)
    src{in}=fullfile('RawMatlab',fileList{in});
    dest{in}=fullfile('Features',fileList{in});
end

loadRunSave(ExtractFeatures,src,'OutputPath',dest,'Save',true,'Parallelize',true,'DataType','table');

%% Consolidate the desired trials for sensors to use for feature selection and feature estimation
fileList=fm.fileList('Root','Features','Ambulation','treadmill','Sensor',{'gon', 'emg', 'imu'});
dest = 'Treadmill';
filename = 'AB06_input';

src=fileList;

for in=1:numel(fileList)
    src{in}=fullfile('Features',fileList{in});
end

fm.combine(src,'Direction','auto','OutputPath',dest,'OutputName',filename,'Save',true);

%% Consolidate the desired trials for truth values, but separately
fileList=fm.fileList('Root','Features','Ambulation','treadmill','Sensor',{'conditions','gait','gait_x_and_y'});
dest = 'Treadmill';
filename = 'AB06_output';

src=fileList;

for in=1:numel(fileList)
    src{in}=fullfile('Features',fileList{in});
end

fm.combine(src,'Direction','auto','OutputPath',dest,'OutputName',filename,'Save',true);

%% Select Features
% selector = FeatureSelector('forwardFeatureSelection');
% 
% input = 'Combined/AB06_input.mat';
% output = 'Combined/AB06_output.mat';
% 
% input = load(input);
% input=input.alldata;
% output=load(output);
% output=output.alldata;
% output.gait = round(output.gait); % Need to bucket continuous values to get good finite difference
% 
% % You choose the desired outputs by passing in only certain outputs
% 
% dest = 'Combined';
% 
% selector.select(input,output,'OutputPath',dest,'OutputName','heuristicInfo');


%% Estimate Features
displayInfo=true;
% load('Combined/heuristicInfo.mat');
% [~,indeces]=sort(selectionInfo.gait{1,:});
% make featureList be only the features that you want the algorithm to use.
% This means that you should sort the list and select the ones you want in
% the script.
% featureList = selectionInfo.gait(:,indeces(1:20)); % select best 20 features

input = 'Treadmill/AB06_input.mat';
output = 'Treadmill/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'Speed'};    

outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

names = fieldnames(in);

% The following line should be replaced by loading the desired features as
% selected by a feature selection algorithm liek forward feature selection
% feats = randperm(size(input.alldata,2),2);
feats = 1:10;

featureList = names(feats)

estimator=ContinuousParameterEstimator('FeatureList',featureList,...
    'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[]});

estimator.estimate(in, o, displayInfo);
%%
estimator.combineFolds;
% estimator.outputs.combined_net = estimator.filter(estimator.outputs.combined_net,'MA',{50});
estimator.outputs.combined_net = estimator.filter(estimator.outputs.combined_net, 'kalman', {{0, 0.003}});
% estimator.outputs.combined_net = atan2(estimator.outputs.combined_net(:,2),estimator.outputs.combined_net(:,1));
estimator.plotNet;

%% %%%%%% Helper function
function gait=generateGait(s)
mask = s.data.heel_Pressed>0.5;
peaks=filter([1 -1],1,mask);
f=[0 find(peaks>0.5)' length(s.data.heel_Pressed)];
gait.data = [];
for i = 2:length(f)
    gait.data=[gait.data linspace(0,100,(f(i)-f(i-1)))];
end
gait.data=table(gait.data','VariableNames',{'gait'});
end

function gait=generateGaitxAndy(s)
mask = s.data.heel_Pressed>0.5;
peaks=filter([1 -1],1,mask);
f=[0 find(peaks>0.5)' length(s.data.heel_Pressed)];
gait.data = [];
for i = 2:length(f)
    gait.data=[gait.data; [cos(linspace(0,2*pi,(f(i)-f(i-1))))' sin(linspace(0,2*pi,(f(i)-f(i-1))))']];
end
gait.data=array2table(gait.data,'VariableNames',{'gait_x', 'gait_y'});
end