%% SF_Study_Setup
% This script runs functions from the sf_post library on the data collected
% by the sensor fusion subteam during fall 2018. This is meant to serve as
% a framework for everyone to start developing their own scripts
%
% Author: Noel Csomay-Shanklin [noelcs@gatech.edu]
% Date of Last Edit: 3/6/19


%% Download all the subjects EMG and IMU for Treadmill
% Step 1:
%   Run the download.py script in @FIleManager. For documentation of how to
%   setup dropbox with the repo, please see the sf_post readme.
% Ex:
%   In C:\Users\Noel Csomay-Shahieghtnklin\src\sf_post\@FileManager
%   Run --> python download.py --token %DB_TOKEN% --local_path ./../../SF_Treadmill --params ab06 sf2018
% THEN:
%   take everything out of sf2018 and put it directly in RawMatlab
%   This is a bug-ish, that I will fix in a later release
% All sucessive work should use the local data

%% TODO:
% Use a different sensor to define gait

fm=FileManager;

window = 200;

%% Generate Independent Variables
% Generate Gait
fileList=fm.fileList('Sensor','fsr');
loadRunSave(@(s) generateGait(s),fm.modFileList(fileList,'Root','RawMatlab'),...
    'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','gait'),...
    'Save',true,'Parallelize',false);

% Generate Speed
fileList=fm.fileList('Ambulation','treadmill','Sensor','conditions');
loadRunSave(@(s) generateSpeed(s),fm.modFileList(fileList,'Root','RawMatlab'),...
    'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','speed'),...
    'Save',true,'Parallelize',false);

% Generate Stair Height
fileList=fm.fileList('Ambulation','stair','Sensor','conditions');
loadRunSave(@(s) generateStairHeight(s),fm.modFileList(fileList,'Root','RawMatlab'),...
    'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
    'Save',true,'Parallelize',false);

% Generate Ramp Incline
fileList=fm.fileList('Ambulation','ramp','Sensor','conditions');
loadRunSave(@(s) generateRampIncline(s),fm.modFileList(fileList,'Root','RawMatlab'),...
    'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
    'Save',true,'Parallelize',false);

%% Extract Features for inputs and outputs
% Extract Sensor Features (inputs)
% Treadmill
fileList=fm.fileList('Ambulation','treadmill','Sensor',{'gon', 'emg', 'imu'});
sensorExtractor = FeatureExtractor('window',window, 'slide', 50, 'MEAN',true,'TD',false,'AR',false,'AROrder',5,'EN',false);
ExtractFeatures = @(s) sensorExtractor.extractFeatures(s);
loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
    'OutputPath',fm.modFileList(fileList,'Root','Features'),...
    'Save',true,'Parallelize',false,'DataType','table');
% Ramp
fileList=fm.fileList('Ambulation','ramp','Sensor',{'gon', 'emg', 'imu'});
sensorExtractor = FeatureExtractor('window',window, 'slide', 50, 'MEAN',true,'TD',false,'AR',false,'AROrder',5,'EN',false);
ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, sensorExtractor);
loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
    'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
    'OutputPath',fm.modFileList(fileList,'Root','Features'),...
    'Save',true,'Parallelize',false,'DataType','table');
% Stair
fileList=fm.fileList('Ambulation','stair','Sensor',{'gon', 'emg', 'imu'});
sensorExtractor = FeatureExtractor('window',window, 'slide', 50, 'MEAN',true,'TD',false,'AR',false,'AROrder',5,'EN',false);
ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, sensorExtractor);
loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
    'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
    'OutputPath',fm.modFileList(fileList,'Root','Features'),...
    'Save',true,'Parallelize',false,'DataType','table');

% Extract Truth Features (outputs)
% Treadmill
fileList=fm.fileList('Ambulation','treadmill','Sensor',{'speed','gait'});
lastExtractor = FeatureExtractor('window',window, 'slide', 50, 'LAST', true);
ExtractFeatures = @(s) lastExtractor.extractFeatures(s);
loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
    'OutputPath',fm.modFileList(fileList,'Root','Features'),...
    'Save',true,'Parallelize',false,'DataType','table');
% Ramp
fileList=fm.fileList('Ambulation','ramp','Sensor',{'rampIncline','gait'});
lastExtractor = FeatureExtractor('window',window, 'slide', 50, 'LAST', true);
ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, lastExtractor);
loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
    'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
    'OutputPath',fm.modFileList(fileList,'Root','Features'),...
    'Save',true,'Parallelize',false,'DataType','table');
% Stair
fileList=fm.fileList('Ambulation','stair','Sensor',{'stairHeight','gait'});
lastExtractor = FeatureExtractor('window',window, 'slide', 50, 'LAST', true);
ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, lastExtractor);
loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
    'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
    'OutputPath',fm.modFileList(fileList,'Root','Features'),...
    'Save',true,'Parallelize',false,'DataType','table');

%% Consolidate the desired trials for sensors to use for feature selection and feature estimation
% Treadmill
% Inputs
fileList=fm.fileList('Root','Features','Ambulation','treadmill','Sensor',{'gon', 'emg', 'imu'});
FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
    'Direction','auto','OutputPath','Treadmill','OutputName','AB06_input','Save',true);
% Outputs
fileList=fm.fileList('Root','Features','Ambulation','treadmill','Sensor',{'speed','gait'});
FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
    'Direction','auto','OutputPath','Treadmill','OutputName','AB06_output','Save',true);

% Stair
% Inputs
fileList=fm.fileList('Root','Features','Ambulation','stair','Sensor',{'gon', 'emg', 'imu'});
FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
    'Direction','auto','OutputPath','Stair','OutputName','AB06_input','Save',true);
% Outputs
fileList=fm.fileList('Root','Features','Ambulation','stair','Sensor',{'stairHeight','gait'});
FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
    'Direction','auto','OutputPath','Stair','OutputName','AB06_output','Save',true);

% Ramp
% Inputs
fileList=fm.fileList('Root','Features','Ambulation','ramp','Sensor',{'gon', 'emg', 'imu'});
FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
    'Direction','auto','OutputPath','Ramp','OutputName','AB06_input','Save',true);
% Outputs
fileList=fm.fileList('Root','Features','Ambulation','ramp','Sensor',{'rampIncline','gait'});
FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
    'Direction','auto','OutputPath','Ramp','OutputName','AB06_output','Save',true);

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

function speed=generateSpeed(s)
speed.data=s.speed(:,2);
end

function stair=generateStairHeight(s)
stairData=repmat(s.stairHeight,[height(s.labels),1]);
stair.data=table(stairData,'VariableNames',{'stairHeight'});
stair.data.steadtyState = cellfun(@(t) ~contains(t,{'-' '_' 'idle'}), s.labels.Label);
end

function ramp=generateRampIncline(s)
rampData=repmat(s.rampIncline,[height(s.labels),1]);
ramp.data=table(rampData,'VariableNames',{'rampIncline'});
ramp.data.steadtyState = cellfun(@(t) ~contains(t,{'-' '_' 'idle'}), s.labels.Label);
end

function features=extractSteadyStateFeatures(f, s, sensorExtractor)
SteadyStateInd = s.data.steadtyState==1;
if isempty(find(SteadyStateInd,1))
    warning('There is no steady state data for a trial')
    features.data = table();
else
    features.data = sensorExtractor.extractFeatures(f.data(SteadyStateInd,:));
end
end
