function generateGaitSpecificFeatures(subject, window, location)
%% SF_Study_Setup
% This script runs functions from the sf_post library on the data collected
% by the sensor fusion subteam during fall 2018. This is meant to serve as
% a framework for everyone to start developing their own scripts
%
% Author: Noel Csomay-Shanklin [noelcs@gatech.edu]
% Date of Last Edit: 4/27/19


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

fm=FileManager('ShowRoot',true);

% window = 200;
% location = 50;
parallelize = true;

ambulatoryModes = {'treadmill' 'ramp' 'stair' 'levelground'};
inputs = {'gon', 'emg', 'imu'};
outputs = {'speed','rampIncline','stairHeight', 'angVel'};
independentVariables = {'gait', 'speed', 'angVel', 'stairHeight', 'rampIncline'};
independentVariablesAmbMode = {'*', 'treadmill', 'levelground', 'stair', 'ramp'};
independentVariablesSensor = {'gon','conditions','conditions','conditions','conditions'};

defaults = {'Save',true,'Parallelize',parallelize,'PassFileName',true};

%% Generate Independent Variables
for i = 1:length(independentVariables) 
disp([' Generating ' independentVariables{i}]);
fileList=fm.fileList('Ambulation',independentVariablesAmbMode{i},'Sensor',independentVariablesSensor{i},'Subject',subject);
loadRunSave(@(s, filename) eval(['generate' independentVariables{i} '(s, filename)']),fileList,'OutputPath',...
    fm.modFileList(fileList,'Sensor',independentVariables{i}),defaults{:}, 'OverwriteFiles',false);
end

defaults = [defaults 'DataType','table'];

%% Extract Features for inputs and outputs
% Extract Sensor Features (inputs)
emgExtractor = FeatureExtractor('type','GaitDependent','window',window, ...
    'TD',true,'EN',true, 'LAST', true, 'WT', true, 'AR',true,'AROrder',4);
emgExtractFunc = @(f, s) extractGaitSpecificFeatures(f, s, emgExtractor, location);
gon_imuExtractor = FeatureExtractor('type','GaitDependent','window',window, 'TD',true,'EN',true, 'LAST', true);
gon_imuExtractFunc = @(f, s) extractGaitSpecificFeatures(f, s, gon_imuExtractor, location);
outputExtractor = FeatureExtractor('type','GaitDependent','window',window, 'LAST', true);
outputExtractFunc = @(f, s) extractGaitSpecificFeatures(f, s, outputExtractor, location);

for i = 1:length(ambulatoryModes)
    
    disp([' Extracting ' ambulatoryModes{i} ' Features'])
    fileList=fm.fileList('Ambulation',ambulatoryModes{i},'Subject',subject,'Sensor','emg');
    featuresOutPath = fm.modFileList(fileList, 'Root','Features');
    simultaneousFiles = [fm.modFileList(fileList,'Sensor','gait'),...
        fm.modFileList(fileList,'Sensor',outputs{i})];
    loadRunSave(emgExtractFunc,fileList,'SimultaneousFiles',simultaneousFiles,'OutputPath',...
        fm.modFileList(featuresOutPath, 'Sensor','emg'),defaults{:},'OverwriteFiles',true);
    loadRunSave(gon_imuExtractFunc,fm.modFileList(fileList, 'Sensor',{'gon', 'imu'}),...
        'SimultaneousFiles',[simultaneousFiles;simultaneousFiles],'OutputPath',...
        fm.modFileList(featuresOutPath, 'Sensor',{'gon', 'imu'}),defaults{:},'OverwriteFiles',true);
    loadRunSave(outputExtractFunc,fm.modFileList(fileList, 'Sensor',{outputs{i},'gait'}),...
        'SimultaneousFiles',[simultaneousFiles;simultaneousFiles],'OutputPath',...
        fm.modFileList(featuresOutPath, 'Sensor',{outputs{i},'gait'}),defaults{:},'OverwriteFiles',true);
    emgExtractor.isReady = false;
    gon_imuExtractor.isReady = false;
    outputExtractor.isReady = false;
end

%% Consolidate the desired trials for sensors to use for feature selection and feature estimation

inputName = [num2str(window) '_windowSize_' num2str(location) '_location_' subject '_input'];
outputName = [num2str(window) '_windowSize_' num2str(location) '_location_' subject '_output_hip'];

for i = 1:length(ambulatoryModes)
% Treadmill
disp([' Combining ' ambulatoryModes{i} ' Features'])
FileManager.combine(fm.fileList('Ambulation',ambulatoryModes{i},'Root','Features',...
    'Subject',subject,'Sensor',inputs),'Direction','auto','OutputPath',ambulatoryModes{i},...
    'OutputName',inputName,'Save',true);
FileManager.combine(fm.fileList('Ambulation',ambulatoryModes{i},'Root','Features',...
    'Subject',subject,'Sensor',{outputs{i},'gait'}),...
    'Direction','auto','OutputPath',ambulatoryModes{i},'OutputName',outputName,'Save',true);
end

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
function gait=generategait(s, ~)
hip = s.data.hip_sagittal;
[~,p] = findpeaks(hip,'MinPeakProminence',.1,'MinPeakHeight',1);
f = [0 p' length(hip)];
gait.data = [];
for i = 2:length(f)
    gait.data=[gait.data linspace(0,100,(f(i)-f(i-1)))];
end
gait.data=table(gait.data','VariableNames',{'gait'});
end

function speed=generatespeed(s, filename)
speed.data = table();
speed.data.speed=s.speed.Speed;
[~,trial] = fileparts(filename);
[~,trial] = strtok(trial,'_');
speed.data.trial=repmat(str2double(trial(end)), size(s.speed,1), 1);
speed.data.notIdle = true(size(speed.data.trial,1), 1);
speed.data.isGoodRos = s.isgoodROS;
end

function levelground=generateangVel(s, filename)
levelground.data=table(s.angular.Angular_vel,'VariableNames',{'Angular_vel'});
levelground.data.notIdle = cellfun(@(t) ~contains(t,{'idle'}), s.labels.Label);
levelground.data.steadyState = levelground.data.notIdle & cellfun(@(t) ~contains(t,{'-'}), s.labels.Label);
levelground.data.steadyState = cellfun(@(t) ~contains(t,{'-'}), s.labels.Label);
levelground.data.labels = s.labels.Label;
levelground.data.isGoodRos = s.isgoodROS;

[~, ~, ext] = fileparts(filename);
levelground.data.trial = zeros(size(s.labels.Label))...
    + str2num(filename(end - length(ext) - 1: end - length(ext)));
end

function stair=generatestairHeight(s, filename)
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
stair.data.isGoodRos = s.isgoodROS;

[~, ~, ext] = fileparts(filename);
stair.data.trial = zeros(size(s.labels.Label))...
    + str2num(filename(end - length(ext) - 1: end - length(ext)));
end

function ramp=generaterampIncline(s, filename)
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
ramp.data.isGoodRos = s.isgoodROS;

[~, ~, ext] = fileparts(filename);
ramp.data.trial = zeros(size(s.labels.Label))...
    + str2num(filename(end - length(ext) - 1: end - length(ext)));
end

function features=extractGaitSpecificFeatures(f, s, sensorExtractor, location)
gait = s(1).data.gait;
notIdleInd = s(2).data.notIdle == 1;
% isGoodRos = s(2).data.isGoodRos == 1;
goodData = notIdleInd;%& isGoodRos
if isempty(find(notIdleInd,1))
    warning('Data for a trial is all idle')
    features.data = table();
else 
    not_labels = cellfun(@(s) ~strcmp(s, 'labels'), f.data.Properties.VariableNames);
    features.data = sensorExtractor.extractFeatures(f.data(goodData,not_labels), 'gait', gait(goodData,:), 'location', location);
    if ~all(not_labels)
        temp_labels = sensorExtractor.extractFeatures(f.data(goodData,~not_labels), 'gait', gait(goodData,:), 'location', location);
        features.data = [features.data, temp_labels];
    end
end
end

%% Appendix
% fileList=fm.fileList('Ambulation','ramp','Subject',subject,'Sensor','emg');
% ExtractFeatures = @(f, s) extractGaitSpecificFeatures(f, s, outGaitExtractor);
% loadRunSave(ExtractFeatures,fm.modFileList(fileList,'Root','RawMatlab'),...
%     'SimultaneousFiles',fm.modFileList(fileList,'Root','RawMatlab','Sensor','gait'),...
%     'OutputPath',fm.modFileList(fileList,'Root','Features'),...
%     'Save',true,'Parallelize',parallelize,'DataType','table');

% function features=extractGaitSpecificFeatures(f, s, sensorExtractor, location)
% gait = s.data.gait;
% features.data = sensorExtractor.extractFeatures(f.data, 'gait', gait, 'location', location);
% end

% % Ramp
% disp(' Extracting Ramp Features')
% fileList=fm.fileList('Ambulation',ambulatoryModes{i},'Subject',subject,'Sensor','emg');
% featuresOutPath = fm.modFileList(fileList, 'Root','Features');
% simultaneousFiles = [fm.modFileList(fileList,'Sensor','gait'),...
%     fm.modFileList(fileList,'Sensor','rampIncline')];
% loadRunSave(emgExtractFunc,fileList,'SimultaneousFiles',simultaneousFiles,'OutputPath',...
%     fm.modFileList(featuresOutPath, 'Sensor','emg'),defaults{:},'OverwriteFiles',true);
% loadRunSave(gon_imuExtractFunc,fm.modFileList(fileList, 'Sensor',{'gon', 'imu'}),...
%     'SimultaneousFiles',[simultaneousFiles;simultaneousFiles],'OutputPath',...
%     fm.modFileList(featuresOutPath, 'Sensor',{'gon', 'imu'}),defaults{:},'OverwriteFiles',true);
% loadRunSave(outputExtractFunc,fm.modFileList(fileList, 'Sensor',{'rampIncline','gait'}),...
%     'SimultaneousFiles',[simultaneousFiles;simultaneousFiles],'OutputPath',...
%     fm.modFileList(featuresOutPath, 'Sensor',{'rampIncline','gait'}),defaults{:},'OverwriteFiles',true);
% 
% % Stair
% disp(' Extracting Stair Features')
% fileList=fm.fileList('Ambulation','stair','Subject',subject,'Sensor','emg');
% featuresOutPath = fm.modFileList(fileList, 'Root','Features');
% simultaneousFiles = [fm.modFileList(fileList,'Sensor','gait'),...
%     fm.modFileList(fileList,'Sensor','stairHeight')];
% loadRunSave(emgExtractFunc,fileList,'SimultaneousFiles',simultaneousFiles,'OutputPath',...
%     fm.modFileList(featuresOutPath, 'Sensor','emg'),defaults{:},'OverwriteFiles',true);
% loadRunSave(gon_imuExtractFunc,fm.modFileList(fileList, 'Sensor',{'gon', 'imu'}),...
%     'SimultaneousFiles',[simultaneousFiles;simultaneousFiles],'OutputPath',...
%     fm.modFileList(featuresOutPath, 'Sensor',{'gon', 'imu'}),defaults{:},'OverwriteFiles',true);
% loadRunSave(outputExtractFunc,fm.modFileList(fileList, 'Sensor',{'stairHeight','gait'}),...
%     'SimultaneousFiles',[simultaneousFiles;simultaneousFiles],'OutputPath',...
%     fm.modFileList(featuresOutPath, 'Sensor',{'stairHeight','gait'}),defaults{:},'OverwriteFiles',true);

% disp(' Generating Speed');
% fileList=fm.fileList('Ambulation','treadmill','Subject',subject,'Sensor','conditions');
% loadRunSave(@(s, filename) generateSpeed(s, filename),fileList,'OverwriteFiles',false,...
%     'OutputPath',fm.modFileList(fileList,'Sensor','speed'),defaults{:},'PassFileName',true);
% 
% disp(' Generating Angular Velocity');
% fileList=fm.fileList('Ambulation','levelground','Subject',subject,'Sensor','conditions');
% loadRunSave(@(s, filename) generateLevelgroundAngVel(s, filename),fileList,'OverwriteFiles',false,...
%     'OutputPath',fm.modFileList(fileList,'Sensor','angVel'),defaults{:},'PassFileName',true);
% 
% disp(' Generating Stair Height');
% fileList=fm.fileList('Ambulation','stair','Subject',subject,'Sensor','conditions');
% loadRunSave(@(s, filename) generateStairHeight(s, filename),fileList,'OverwriteFiles',false,...
%     'OutputPath',fm.modFileList(fileList,'Sensor','stairHeight'),defaults{:},'PassFileName',true);
% 
% disp(' Generating Ramp Incline');
% fileList=fm.fileList('Ambulation','ramp','Subject',subject,'Sensor','conditions');
% loadRunSave(@(s, filename) generateRampIncline(s, filename),fileList,'OverwriteFiles',false,...
%     'OutputPath',fm.modFileList(fileList,'Sensor','rampIncline'),defaults{:},'PassFileName',true);

% function gait=generateGaitxAndy(s)
% mask = s.data.heel_Pressed>0.5;
% peaks=filter([1 -1],1,mask);
% f=[0 find(peaks>0.5)' length(s.data.heel_Pressed)];
% gait.data = [];
% for i = 2:length(f)
%     gait.data=[gait.data; [cos(linspace(0,2*pi,(f(i)-f(i-1))))' sin(linspace(0,2*pi,(f(i)-f(i-1))))']];
% end
% gait.data=array2table(gait.data,'VariableNames',{'gait_x', 'gait_y'});
% end

% % Ramp
% disp(' Combining Ramp Features')
% fileList=fm.fileList('Ambulation','ramp','Root','Features','Subject',subject,'Sensor',inputs);
% 
% FileManager.combine(fm.modFileList(fileList,'Ambulation','ramp'),...
%     'Direction','auto','OutputPath','Ramp','OutputName',inputName,'Save',true);
% FileManager.combine(fm.modFileList(fileList,'Ambulation','ramp','Sensor',{'rampIncline','gait'}),...
%     'Direction','auto','OutputPath','Ramp','OutputName',outputName,'Save',true);
% 
% % Stair
% disp(' Combining Stair Features')
% fileList=fm.fileList('Ambulation','stair','Root','Features','Subject',subject,'Sensor',inputs);
% FileManager.combine(fm.modFileList(fileList,'Ambulation','stair'),...
%     'Direction','auto','OutputPath','Stair','OutputName',inputName,'Save',true);
% FileManager.combine(fm.modFileList(fileList,'Ambulation','stair','Sensor',{'stairHeight','gait'}),...
%     'Direction','auto','OutputPath','Stair','OutputName',outputName,'Save',true);

% 
% function features=extractSteadyStateFeatures(f, s, sensorExtractor)
% notIdleInd = s.data.notIdle==1;
% if isempty(find(notIdleInd,1))
%     warning('Data for a trial is all idle')
%     features.data = table();
% else
%     not_labels = cellfun(@(s) ~strcmp(s, 'labels'), f.data.Properties.VariableNames);
%     features.data = sensorExtractor.extractFeatures(f.data(notIdleInd,not_labels));
%     if ~all(not_labels)
%         temp_labels = sensorExtractor.extractFeatures(f.data(notIdleInd,~not_labels));
%         features.data = [features.data, temp_labels];
%     end
% end
% end