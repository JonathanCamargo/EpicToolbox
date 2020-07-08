function allTrialsData=EpicToolbox(obj, fileList)
% For an list of files from sf_post combine all the sensors
% of the same trial into a mat file matching the structure for usage with
% EpicToolbox. Intended to retrieve data in small chunks without writing
% files.
%
% trialData=EpicToolbox(fileList)

%% Transform data for EpicToolbox

%% Combine data from different sensors into one struct

pathfields=obj.folderLevels;

sensorLevel='Sensor';
if ~ismember('Sensor',pathfields)
    sensorLevel='sensor';
    if ~ismember('sensor',pathfields)
        error('FileManager object must contain Sensor folderLevel in pathStructure');
    end
end

if isempty(fileList)
    warning('No files to create an EpicToolbox struct');
    allTrialsData={};
    return;
end

%Last field is always trialnames which we certainly need to group
% Also group Subject and Date fields if they exist.
% Sensor field should allways be present to be combined as topics in the
% trial.

lastfield=pathfields{end}; 

% tolook represents fields that I want to look for in order to group files
% that belong to the same trial and thus should be together.

% tolook={'Subject','Date','Ambulation'}; % To reduce the ouput to only
% certain fields.

tolook=setdiff(pathfields(1:end-1),sensorLevel); % To keep the output to all the fields (except sensor and last field)

trials=obj.getFields(fileList,lastfield);
sensors=obj.getFields(fileList,sensorLevel);
individualtrialstbl=cell2table(trials,'VariableNames',{lastfield});

for i=1:numel(tolook)
    fieldname=tolook{i};
    if any(contains(pathfields,fieldname))
        a=obj.getFields(fileList,fieldname);
        atbl=cell2table(a,'VariableNames',{fieldname});
        individualtrialstbl=horzcat(individualtrialstbl,atbl);
    end    
end

[unique_trials,uniqueTrialIdx,trialIdx]=unique(individualtrialstbl);

allTrialsData=cell(size(unique_trials,1),1);

%%
for i=1:numel(fileList)
    % Recover trialData stored in allTrialls cell
    trialData=allTrialsData{trialIdx(i)};
               
    %% Load data for each sensor into trialData struct        
    sensor=sensors{i};
    if ~exist(fileList{i},'file')
        continue;
    end
    a=load(fileList{i});
    if isfield(trialData,sensor)
        error('Trial already contains %s data\n @file:%s\n',sensor,fileList{i});
    end
    if ((numel(fieldnames(a))==1) && isfield(a,'data'))
        eval(sprintf('trialData.%s=a.data;',sensor));
    else
        eval(sprintf('trialData.%s=a;',sensor));
    end
    
    allTrialsData{trialIdx(i)}=trialData;
end
% After loading data fill out info into every trial to give user more info
% about each trial.
for i=1:height(unique_trials)    
    a=allTrialsData{i};    
    varnames=individualtrialstbl.Properties.VariableNames;
    for j=1:size(individualtrialstbl,2)
        a.info.(varnames{j})=unique_trials{i,j}{:};
    end
    allTrialsData{i}=a;
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  
  
