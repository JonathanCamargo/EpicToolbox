function [traindata,testdata]=GetData(input,x_options,y_options,varargin)
% GetData retrieves a table of training and a table of testing data from
% Input can be either a FileManager instance or a cell array with trials
% from EpicToolbox.
% 
% [traindata,testdata]=GetData(input,x_options,y_options,varargin) 
%
% 'Mode'   (RandomHold) % Randomize the trials and hold a subset for test
%          (Ordered)    % Keep the same order of the input
% 'Hold'   (5)      % %of How many trials to reserve from the total
% 'Combine' (true)  % return the data as a single table or as a cell array by trials
%  
% Returns traindata, testdata and info of the source of data

p=inputParser();
params={'Mode','Hold','Combine'};
defaults={'RandomHold',0,true};
for i=1:numel(params)
    p.addParameter(params{i},defaults{i});
end
p.addParameter('FileManagerOpts',{}); %Aditional options for file manager to limit the scope of files
p.parse(varargin{:});

FileManagerOpts=p.Results.FileManagerOpts;

Mode=p.Results.Mode;
Hold=p.Results.Hold;

isCombining=p.Results.Combine;

if isa(input,'FileManager')
    f=input;
end


% Get all the input (x) sensors
xsensors=fieldnames(x_options); 
if size(xsensors,1)~=1
    xsensors=xsensors';
end

% Get all the output (y) sensors
ysensors=fieldnames(y_options);
if size(ysensors,1)~=1
    ysensors=ysensors';
end


if isa(input,'FileManager') 
    % Get the list of files and construct a set of trials
    allFiles=f.fileList('Sensor',[xsensors,ysensors],FileManagerOpts{:});
    allTrials=f.EpicToolbox(allFiles);
else
    allTrials=input;
end

% Only keep the channels that we need
for i=1:numel(allTrials)
    for sensorIdx=1:numel(xsensors)
        sensor=xsensors{sensorIdx};
        sensorData=allTrials{i}.(sensor);
        %newNames=join([repmat({sensor},size(sensorData,2),1),sensorData.Properties.VariableNames'],'_');
        %sensorData.Properties.VariableNames=newNames;
        %cols=colIdx(sensorData,x_options.(sensor));
        %allTrials{i}.(sensor)= sensorData(:,cols);
        
        % Now use topics select
        a.data=sensorData;
        a=Topics.select(a,'data','Channels',{x_options.(sensor)});
        allTrials{i}.(sensor)=a.data;
        
    end
    for sensorIdx=1:numel(ysensors)
        sensor=ysensors{sensorIdx};
        sensorData=allTrials{i}.(sensor);
        
        %Now use topics select
        a.data=sensorData;
        a=Topics.select(a,'data','Channels',{y_options.(sensor)});
        allTrials{i}.(sensor)=a.data;
        
    end
end




% Random Hold method: 
% Select a random Hold% of trials and discard
if strcmp(Mode,'RandomHold')
    indices=randperm(numel(allTrials));
elseif strcmp(Mode,'Ordered')
    indices=1:numel(allTrials);
end

N=floor(Hold*numel(indices)/100);
testIndices=indices(1:N);
trainIndices=indices(N+1:end);

trainTrials=allTrials(trainIndices);
testTrials=allTrials(testIndices);

xTrainTrials=cell(numel(trainTrials),1);
yTrainTrials=cell(numel(trainTrials),1);
xTestTrials=cell(numel(testTrials),1);
yTestTrials=cell(numel(testTrials),1);
info.train=cell(numel(trainTrials),1);
info.test=cell(numel(testTrials),1);

% Retrieve all the tables 
for i=1:numel(trainTrials)
    xTrainTrials{i}=Topics.consolidate(trainTrials{i},xsensors,'Prepend',true);
    yTrainTrials{i}=Topics.consolidate(trainTrials{i},ysensors,'Prepend',true);
    info.train{i}=trainTrials{i}.info;
end
for i=1:numel(testTrials)
    xTestTrials{i}=Topics.consolidate(testTrials{i},xsensors,'Prepend',true);
    yTestTrials{i}=Topics.consolidate(testTrials{i},ysensors,'Prepend',true);
    info.test{i}=testTrials{i}.info;
end

if isCombining
    % Combine trainTrials and testTrials in a table
    traindata=struct('X',vertcat(xTrainTrials{:}),'Y',vertcat(yTrainTrials{:}));
    testdata=struct('X',vertcat(xTestTrials{:}),'Y',vertcat(yTestTrials{:}));
else
    traindata=struct('X',xTrainTrials,'Y',yTrainTrials,'info',info.train);
    testdata=struct('X',xTestTrials,'Y',yTestTrials,'info',info.test);
end

end

%% %%%%%%%%%%%%%% HELPER FUNCTIONS %%%%%%%%%%%%
function out=colIdx(tabledata,channels)
% Find the indices of columns in a table based on their name.
% use '*' as a keyword to get all the columns
    columns=tabledata.Properties.VariableNames;
    if ismember({'*'},channels)    
        out=1:width(tabledata);    
    else
        [~,out]=ismember(channels,columns);
        out=out(out~=0);
    end
end



