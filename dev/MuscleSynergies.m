% Example: Download data from the database, extract features, and estimate
% independent variables using neural networks

%% Download all the subjects EMG and IMU for Treadmill
fm = FileManager();

% See help fm.fileList for all param options to pass in
params.subject={'*'};
params.sensor={'EMG','conditions'};
params.ambulation={'SimultaneousMotions'};
fm.download(params);
% Download will create a new folder RawMatlab containing all the mat files
% in our structure.
% All sucessive work should use the local data and not the database data

%% Turn discrete condition data into "time series" data
% This part of the code is replicating individual independent variables to
% match the size of theactual data

fileList=fm.fileList('Root','RawMatlab','Sensor','conditions');
sensor = 'EMG'; % Sample sensor which has the defined file strucutre and file length
% can be any sensor that matches these criteria

% Since fileList is relative to Root we need to prepend RawMatlab folder to
% get the path from pwd.
% This takes the file list from EMG and puts condition information into it
sensorList=fileList;
% Since fileList is relative to Root we need to prepend RawMatlab folder to
% get the path from pwd.
% This takes the file list from EMG and puts condition information into it
for i=1:length(fileList)
    fileList{i}=fullfile('RawMatlab',fileList{i});
    sensorList{i} = strrep(fileList{i},'conditions',sensor);
    conditions = load(fileList{i});
    conditions = conditions.conditions;
    conditionNames = fields(conditions);
    for j=1:length(fields(conditions))
        destPath = strrep(fileList{i},'conditions',conditionNames{j});
        if ~isa(conditions.(conditionNames{j}), 'table')
            replicateValues(codeToUnlabel({conditions.(conditionNames{j})}),sensorList{i},'Name',conditionNames{j},'OutputPath',destPath,'Save',true);
        else
            tmp.data = conditions.(conditionNames{j});
            tmp.data.Properties.VariableNames = lower(tmp.data.Properties.VariableNames);
            if ~exist(fileparts(destPath),'dir')
                mkdir(fileparts(destPath));
            end
            save(destPath,'-struct','tmp');
        end
    end
end

%% Extract Features for Sensors

% Get the files paths corresponding to all sensors for all subjects in
% RawMatlab
fileList=fm.fileList('Root','RawMatlab','Sensor',{'EMG'});
sensorExtractor = FeatureExtractor('window',200, 'slide', 50, 'TD',true,'AR',false,'AROrder',5,'EN',false);
ExtractFeatures = @(s) sensorExtractor.extractFeatures(s);

src=fileList;
dest=fileList;

for i=1:numel(fileList)
    src{i}=fullfile('RawMatlab',fileList{i});
    dest{i}=fullfile('Features',fileList{i});
end

loadRunSave(ExtractFeatures,src,'OutputPath',dest,'Save',true);

%% Extract "features" for time series truth values
fileList=fm.fileList('Root','RawMatlab','Sensor',{'movement'});
lastExtractor = FeatureExtractor('window',200, 'slide', 50, 'LAST', true);
ExtractFeatures = @(s) lastExtractor.extractFeatures(s);

src=fileList;
dest=fileList;

for i=1:numel(fileList)
    src{i}=fullfile('RawMatlab',fileList{i});
    dest{i}=fullfile('Features',fileList{i});
end

loadRunSave(ExtractFeatures,src,'OutputPath',dest,'Save',true);

%% Consolidate the desired trials for sensors to use for feature selection and feature estimation
fileList=fm.fileList('Root','Features','Sensor',{'EMG'});
dest = 'Combined';

src=fileList;

for i=1:numel(fileList)
    src{i}=fullfile('Features',fileList{i});
end

fm.combine(src,'Direction','auto','OutputPath',dest,'OutputName','AB03_input','Save',true);

%% Consolidate the desired trials for truth values, but separately
fileList=fm.fileList('Root','Features','Sensor',{'movement'});
dest = 'Combined';

src=fileList;

for i=1:numel(fileList)
    src{i}=fullfile('Features',fileList{i});
end

fm.combine(src,'Direction','auto','OutputPath',dest,'OutputName','AB03_output','Save',true);

%% Select Features
selector = FeatureSelector('heuristic');

input = 'Combined/AB03_input.mat';
output = 'Combined/AB03_output.mat';

input = load(input);
input=input.alldata;
output=load(output);
output=output.alldata; 
% You choose the desired outputs by passing in only certain outputs

dest = 'Combined';

selector.select(input,output,'OutputPath',dest,'OutputName','heuristicInfo');


%% Estimate Features
displayInfo=true;
load('Combined/heuristicInfo.mat');
[~,indeces]=sort(selectionInfo.movement{1,:});
% make featureList be only the features that you want the algorithm to use.
% This means that you should sort the list and select the ones you want in
% the script.
featureList = selectionInfo.movement(:,indeces(1:20)); % select best 20 features

input = 'Combined/AB03_input.mat';
output = 'Combined/AB03_output.mat';

input = load(input);
input=input.alldata;
output=load(output);
output=output.alldata; 

estimator=ContinuousParameterEstimator('FeatureList',featureList,...
    'HiddenNodes',20,'Folds',10);

estimator.estimate(input, output, displayInfo);
estimator.filter('MA',{50});
estimator.plotNet;


%% %%%%%% Helper function
function gait=generateGait(s)
    peaks=filter([1 -1],1,s.data.Heel);
    f=[0 find(peaks>0.5)' length(s.data.Heel)];
    gait.data = [];
    for i = 2:length(f)
        gait.data=[gait.data linspace(0,100,(f(i)-f(i-1)))];
    end
    gait.data=table(gait.data','VariableNames',{'gait'});
end

function gait=generateGaitxAndy(s)
    peaks=filter([1 -1],1,s.data.Heel);
    f=[0 find(peaks>0.5)' length(s.data.Heel)];
    gait.data = [];
    for i = 2:length(f)
        gait.data=[gait.data; [cos(linspace(0,2*pi,(f(i)-f(i-1))))' sin(linspace(0,2*pi,(f(i)-f(i-1))))']];
    end
    gait.data=array2table(gait.data,'VariableNames',{'gait_x', 'gait_y'});
end
