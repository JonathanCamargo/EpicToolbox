function generateFeatures(subject, window, slide)
%% SF_Study_Setup
% This script runs functions from the sf_post library on the data collected
% by the sensor fusion subteam during fall 2018. This is meant to serve as
% a framework for everyone to start developing their own scripts
%
% Author: Noel Csomay-Shanklin [noelcs@gatech.edu]
% Date of Last Edit: 3/21/19


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
% run ab25

fm=FileManager;

% window = 200;
% slide = 50; % One for each percent of the gait cycle
parallelize = true;
    
    %% Generate Independent Variables
    % Generate Gait
    fileList=fm.fileList('Sensor','gon','Subject',subject);
    loadRunSave(@(s) generateGait(s),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','gait'),...
        'Save',true,'Parallelize',parallelize);
    
    % Generate Speed
    fileList=fm.fileList('Ambulation','treadmill','Subject',subject,'Sensor','conditions');
    loadRunSave(@(s) generateSpeed(s),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','speed'),...
        'Save',true,'Parallelize',parallelize);
    
    % Generate Stair Height
    fileList=fm.fileList('Ambulation','stair','Subject',subject,'Sensor','conditions');
    loadRunSave(@(s) generateStairHeight(s),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
        'Save',true,'Parallelize',parallelize);
    
    % Generate Ramp Incline
    fileList=fm.fileList('Ambulation','ramp','Subject',subject,'Sensor','conditions');
    loadRunSave(@(s) generateRampIncline(s),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
        'Save',true,'Parallelize',parallelize);
    
    %% Extract Features for inputs and outputs
    % Extract Sensor Features (inputs)
    
    emgExtractor = FeatureExtractor('window',window, 'slide', slide, 'TD',true,'EN',true, 'LAST', true, 'WT', true, 'AR',true,'AROrder',4);
    gon_imuExtractor = FeatureExtractor('window',window, 'slide', slide, 'TD',true,'EN',true, 'LAST', true);
    
    outputExtractor = FeatureExtractor('window',window, 'slide', slide, 'LAST', true);
    outGaitExtractor = FeatureExtractor('type','GaitDependent','window',window, 'slide', slide, 'LAST', true);

    % Treadmill
    % emg
    fileList=fm.fileList('Ambulation','treadmill','Subject',subject,'Sensor','emg');
    ExtractFeatures = @(f, s) extractGaitSpecificFeatures(f, s, outGaitExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','gait'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    % Treadmill
    % emg
    fileList=fm.fileList('Ambulation','treadmill','Subject',subject,'Sensor','emg');
    ExtractFeatures = @(s) emgExtractor.extractFeatures(s);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % gon_imu
    fileList=fm.fileList('Ambulation','treadmill','Subject',subject,'Sensor',{'gon', 'imu'});
    ExtractFeatures = @(s) gon_imuExtractor.extractFeatures(s);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % Ramp
    % emg
    fileList=fm.fileList('Ambulation','ramp','Subject',subject,'Sensor','emg');
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, emgExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % gon_imu
    fileList=fm.fileList('Ambulation','ramp','Subject',subject,'Sensor',{'gon', 'imu'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, gon_imuExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % Stair
    % eng
    fileList=fm.fileList('Ambulation','stair','Subject',subject,'Sensor','emg');
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, emgExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % gon_imu
    fileList=fm.fileList('Ambulation','stair','Subject',subject,'Sensor',{'gon', 'imu'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, gon_imuExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    % Extract Truth Features (outputs)
    % Treadmill
    fileList=fm.fileList('Ambulation','treadmill','Subject',subject,'Sensor',{'speed','gait'});
    ExtractFeatures = @(s) outputExtractor.extractFeatures(s);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % Ramp
    fileList=fm.fileList('Ambulation','ramp','Subject',subject,'Sensor',{'rampIncline','gait'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, outputExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % Stair
    fileList=fm.fileList('Ambulation','stair','Subject',subject,'Sensor',{'stairHeight','gait'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, outputExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    %% Consolidate the desired trials for sensors to use for feature selection and feature estimation
    
    % Treadmill
    % Inputs
    fileList=fm.fileList('Root','Features','Subject',subject,'Ambulation','treadmill','Sensor',{'gon', 'emg', 'imu'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Treadmill','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subject '_input'],'Save',true);
    % Outputs
    fileList=fm.fileList('Root','Features','Subject',subject,'Ambulation','treadmill','Sensor',{'speed','gait'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Treadmill','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subject '_output_hip'],'Save',true);
    
    % Stair
    % Inputs
    fileList=fm.fileList('Root','Features','Subject',subject,'Ambulation','stair','Sensor',{'gon', 'emg', 'imu'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Stair','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subject '_input'],'Save',true);
    % Outputs
    fileList=fm.fileList('Root','Features','Subject',subject,'Ambulation','stair','Sensor',{'stairHeight','gait'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Stair','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subject '_output_hip'],'Save',true);
    
    % Ramp
    % Inputs
    fileList=fm.fileList('Root','Features','Subject',subject,'Ambulation','ramp','Sensor',{'gon', 'emg', 'imu'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Ramp','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subject '_input'],'Save',true);
    % Outputs
    fileList=fm.fileList('Root','Features','Subject',subject,'Ambulation','ramp','Sensor',{'rampIncline','gait'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Ramp','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subject '_output_hip'],'Save',true);
end
%% %%%%%% Helper function
% function gait=generateGait(s)
% mask = s.data.heel_Pressed>0.5;
% peaks=filter([1 -1],1,mask);
% f=[0 find(peaks>0.5)' length(s.data.heel_Pressed)];
% gait.data = [];
% for i = 2:length(f)
%     gait.data=[gait.data linspace(0,100,(f(i)-f(i-1)))];
% end
% gait.data=table(gait.data','VariableNames',{'gait'});
% end
function gait=generateGait(s)
hip = s.data.hip_sagital;
[~,p] = findpeaks(hip,'MinPeakProminence',.1,'MinPeakHeight',2);
f = [0 p' length(hip)];
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
first_descent = find(cellfun(@(s) contains(s,'descent'),s.labels.Label),1);
if isempty(first_descent)
    stairData=NaN([height(s.labels),1]);
else
    stairData=repmat(s.stairHeight,[first_descent,1]);
    stairData=[stairData; -repmat(s.stairHeight,[height(s.labels)-first_descent,1])];
end
stair.data=table(stairData,'VariableNames',{'stairHeight'});
stair.data.steadtyState = cellfun(@(t) ~contains(t,{'idle'}), s.labels.Label);
end

function ramp=generateRampIncline(s)
first_descent = find(cellfun(@(s) contains(s,'descent'),s.labels.Label),1);
if isempty(first_descent)
    rampData = NaN([height(s.labels),1]);
else
    rampData=repmat(s.rampIncline,[first_descent,1]);
    rampData=[rampData; -repmat(s.rampIncline,[height(s.labels)-first_descent,1])];
end
ramp.data=table(rampData,'VariableNames',{'rampIncline'});
ramp.data.steadtyState = cellfun(@(t) ~contains(t,{'idle'}), s.labels.Label);
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

function features=extractGaitSpecificFeatures(f, s, sensorExtractor)
gait = s.data.gait;
features.data = sensorExtractor.extractFeatures(f.data, 'gait', gait, 'location', 50);
end
