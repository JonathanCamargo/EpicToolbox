%% SF_Study_Setup
% This script runs functions from the sf_post library on the data collected
% by the sensor fusion subteam during fall 2018. This is meant to serve as
% a framework for everyone to start developing their own scripts
%
% Author: Noel Csomay-Shanklin [noelcs@gatech.edu]
% Date of Last Edit: 3/21/19


%% Download all the subjects EMG and IMU for Treadmill
% Step 1:
%   Run the download.py script in @FileManager. For documentation of how to
%   setup dropbox with the repo, please see the sf_post readme.
% Ex:
%   In C:\Users\Noel Csomay-Shanklin\src\sf_post\@FileManager
%   Run --> python download.py --token %DB_TOKEN% --local_path ./../../SF_Treadmill --params ab06 sf2018
% THEN:
%   take everything out of sf2018 and put it directly in RawMatlab
%   This is a bug-ish, that I will fix in a later release
% All sucessive work should use the local data

%% TODO:
% Use a different sensor to define gait
% run ab25

fm=FileManager;

window = 200;
slide = 50; % One for each percent of the gait cycle
parallelize = false;

subjects = arrayfun(@(s) {['ab' sprintf('%02i',s)]},[6]);

for i = 1:length(subjects)
    
    %% Generate Independent Variables
    % Generate Gait
    fileList=fm.fileList('Sensor','gon','Subject',subjects{i});
    loadRunSave(@(s) generateGait(s),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','gait'),...
        'Save',true,'Parallelize',parallelize);
    
    % Generate Speed
    fileList=fm.fileList('Ambulation','treadmill','Subject',subjects{i},'Sensor','conditions');
    loadRunSave(@(s, filename) generateSpeed(s, filename),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','speed'),...
        'Save',true,'Parallelize',parallelize,'PassFileName',true);
    
    % Generate Levelground Ang vel
    fileList=fm.fileList('Ambulation','levelground','Subject',subjects{i},'Sensor','conditions');
    loadRunSave(@(s, filename) generateLevelgroundAngVel(s, filename),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','angVel'),...
        'Save',true,'Parallelize',parallelize,'PassFileName',true);
    
    % Generate Stair Height
    fileList=fm.fileList('Ambulation','stair','Subject',subjects{i},'Sensor','conditions');
    loadRunSave(@(s, filename) generateStairHeight(s, filename),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
        'Save',true,'Parallelize',parallelize,'PassFileName',true);
    
    % Generate Ramp Incline
    fileList=fm.fileList('Ambulation','ramp','Subject',subjects{i},'Sensor','conditions');
    loadRunSave(@(s, filename) generateRampIncline(s, filename),fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
        'Save',true,'Parallelize',parallelize,'PassFileName',true);
    
    %% Extract Features for inputs and outputs
    % Extract Sensor Features (inputs)
    
    emgExtractor = FeatureExtractor('window',window, 'slide', slide, 'TD',true,'EN',false, 'LAST', true, 'WT', false, 'AR',true,'AROrder',4);
    gon_imuExtractor = FeatureExtractor('window',window, 'slide', slide, 'TD',true,'EN',false, 'LAST', true);
    
    outputExtractor = FeatureExtractor('window',window, 'slide', slide, 'LAST', true);
    
    % Treadmill
    % emg
    fileList=fm.fileList('Ambulation','treadmill','Subject',subjects{i},'Sensor','emg');
    ExtractFeatures = @(s) emgExtractor.extractFeatures(s);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % gon_imu
    fileList=fm.fileList('Ambulation','treadmill','Subject',subjects{i},'Sensor',{'gon', 'imu'});
    ExtractFeatures = @(s) gon_imuExtractor.extractFeatures(s);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');

    % Levelground
    % emg
    %%
    fileList=fm.fileList('Ambulation','levelground','Subject',subjects{i},'Sensor','emg');
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, emgExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','angVel'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % gon_imu
    fileList=fm.fileList('Ambulation','levelground','Subject',subjects{i},'Sensor',{'gon', 'imu'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, gon_imuExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','angVel'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    % Ramp
    % emg
    %%
    fileList=fm.fileList('Ambulation','ramp','Subject',subjects{i},'Sensor','emg');
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, emgExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % gon_imu
    fileList=fm.fileList('Ambulation','ramp','Subject',subjects{i},'Sensor',{'gon', 'imu'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, gon_imuExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    % Stair
    % eng
    fileList=fm.fileList('Ambulation','stair','Subject',subjects{i},'Sensor','emg');
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, emgExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    % gon_imu
    fileList=fm.fileList('Ambulation','stair','Subject',subjects{i},'Sensor',{'gon', 'imu'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, gon_imuExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    %% Extract Truth Features (outputs)
    % Treadmill
    fileList=fm.fileList('Ambulation','treadmill','Subject',subjects{i},'Sensor',{'speed','gait'});
    ExtractFeatures = @(s) outputExtractor.extractFeatures(s);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    % Levelground
    fileList=fm.fileList('Ambulation','levelground','Subject',subjects{i},'Sensor',{'angVel','gait'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, outputExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','angVel'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    % Ramp
    fileList=fm.fileList('Ambulation','ramp','Subject',subjects{i},'Sensor',{'rampIncline','gait'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, outputExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','rampIncline'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    % Stair
    fileList=fm.fileList('Ambulation','stair','Subject',subjects{i},'Sensor',{'stairHeight','gait'});
    ExtractFeatures = @(f, s) extractSteadyStateFeatures(f, s, outputExtractor);
    loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
        'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','stairHeight'),...
        'OutputPath',fm.modFileList(fileList,'Root','Features'),...
        'Save',true,'Parallelize',parallelize,'DataType','table');
    
    %% Consolidate the desired trials for sensors to use for feature selection and feature estimation
    
    % Treadmill
    % Inputs
    fileList=fm.fileList('Root','Features','Subject',subjects{i},'Ambulation','treadmill','Sensor',{'gon', 'emg', 'imu'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Treadmill','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subjects{i} '_input'],'Save',true);
    % Outputs
    fileList=fm.fileList('Root','Features','Subject',subjects{i},'Ambulation','treadmill','Sensor',{'speed','gait'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Treadmill','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subjects{i} '_output'],'Save',true);
    
    % Levelground
    % Inputs
    fileList=fm.fileList('Root','Features','Subject',subjects{i},'Ambulation','levelground','Sensor',{'gon', 'emg', 'imu'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Levelground','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subjects{i} '_input'],'Save',true);
    % Outputs
    fileList=fm.fileList('Root','Features','Subject',subjects{i},'Ambulation','levelground','Sensor',{'angVel','gait'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Levelground','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subjects{i} '_output'],'Save',true);
    
    % Stair
    % Inputs
    fileList=fm.fileList('Root','Features','Subject',subjects{i},'Ambulation','stair','Sensor',{'gon', 'emg', 'imu'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Stair','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subjects{i} '_input'],'Save',true);
    % Outputs
    fileList=fm.fileList('Root','Features','Subject',subjects{i},'Ambulation','stair','Sensor',{'stairHeight','gait'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Stair','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subjects{i} '_output'],'Save',true);
    
    % Ramp
    % Inputs
    fileList=fm.fileList('Root','Features','Subject',subjects{i},'Ambulation','ramp','Sensor',{'gon', 'emg', 'imu'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Ramp','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subjects{i} '_input'],'Save',true);
    % Outputs
    fileList=fm.fileList('Root','Features','Subject',subjects{i},'Ambulation','ramp','Sensor',{'rampIncline','gait'});
    FileManager.combine(fm.modFileList(fileList,'Root','Features'),...
        'Direction','auto','OutputPath','Ramp','OutputName',[num2str(window) '_windowSize_' num2str(slide) '_slide_' subjects{i} '_output'],'Save',true);
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
hip = s.data.hip_sagittal;
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

function speed=generateSpeed(s, filename)
speed.data=s.speed(:,2);
end

function levelground=generateLevelgroundAngVel(s, filename)
levelground.data=table(s.angular.Angular_vel,'VariableNames',{'Angular_vel'});
levelground.data.notIdle = cellfun(@(t) ~contains(t,{'idle'}), s.labels.Label);
levelground.data.steadyState = levelground.data.notIdle & cellfun(@(t) ~contains(t,{'-'}), s.labels.Label);
levelground.data.steadyState = cellfun(@(t) ~contains(t,{'-'}), s.labels.Label);
levelground.data.labels = s.labels.Label;

[~, ~, ext] = fileparts(filename);
levelground.data.trial = zeros(size(s.labels.Label))...
    + str2num(filename(end - length(ext) - 1: end - length(ext)));
end

function stair=generateStairHeight(s, filename)
first_descent = find(cellfun(@(s) contains(s,'descent'),s.labels.Label),1);
if isempty(first_descent)
    stairData=NaN([height(s.labels),1]);
else
    stairData=repmat(s.stairHeight,[first_descent,1]);
stairData=[stairData; -repmat(s.stairHeight,[height(s.labels)-first_descent,1])];
end
stair.data=table(stairData,'VariableNames',{'stairHeight'});
stair.data.notIdle = cellfun(@(t) ~contains(t,{'idle'}), s.labels.Label);
stair.data.steadyState = stair.data.notIdle & cellfun(@(t) ~contains(t,{'-'}), s.labels.Label);
stair.data.steadyState = cellfun(@(t) ~contains(t,{'-'}), s.labels.Label);
stair.data.labels = s.labels.Label;

[~, ~, ext] = fileparts(filename);
stair.data.trial = zeros(size(s.labels.Label))...
    + str2num(filename(end - length(ext) - 1: end - length(ext)));
end

function ramp=generateRampIncline(s, filename)
first_descent = find(cellfun(@(s) contains(s,'descent'),s.labels.Label),1);
if isempty(first_descent)
    rampData = NaN([height(s.labels),1]);
else
    rampData=repmat(s.rampIncline,[first_descent,1]);
    rampData=[rampData; -repmat(s.rampIncline,[height(s.labels)-first_descent,1])];
end
ramp.data=table(rampData,'VariableNames',{'rampIncline'});
ramp.data.notIdle = cellfun(@(t) ~contains(t,{'idle'}), s.labels.Label);
ramp.data.steadyState = ramp.data.notIdle & cellfun(@(t) ~contains(t,{'-'}), s.labels.Label);
ramp.data.labels = s.labels.Label;

[~, ~, ext] = fileparts(filename);
ramp.data.trial = zeros(size(s.labels.Label))...
    + str2num(filename(end - length(ext) - 1: end - length(ext)));
end

function features=extractSteadyStateFeatures(f, s, sensorExtractor)
notIdleInd = s.data.notIdle==1;
if isempty(find(notIdleInd,1))
    warning('Data for a trial is all idle')
    features.data = table();
else
    not_labels = cellfun(@(s) ~strcmp(s, 'labels'), f.data.Properties.VariableNames);
    features.data = sensorExtractor.extractFeatures(f.data(notIdleInd,not_labels));
    if ~all(not_labels)
        temp_labels = sensorExtractor.extractFeatures(f.data(notIdleInd,~not_labels));
        features.data = [features.data, temp_labels];
    end
end
end
