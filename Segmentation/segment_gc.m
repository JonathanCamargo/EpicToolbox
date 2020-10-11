function segments=segment_gc(trial_data,varargin)
%Segment the trial data by gait cycle by using the information
% contained in the gc topic. gc must be a triangle wave that 
% hold the RGait channel describing 0-100% gc values.
% Parameters: 
%    'GCtopic'  Topic containing gait cycle in 0-100%
%    'GCchannel' name of the channel int the GCTopic
% Always use

p=inputParser;

p.addParameter('GCtopic','gc',@ischar);
p.addParameter('GCchannel','gait',@ischar);
p.parse(varargin{:});

gcchannel=p.Results.GCchannel;
gctopic=p.Results.GCtopic;

% Get the gc peaks: 
intervals=gc2intervals(trial_data.(gctopic).Header,trial_data.(gctopic).(gcchannel));

% Get all the all the topics in the trial
headerTopics=Topics.topics(trial_data,'Header',true);
allTopics=Topics.topics(trial_data,'Header',false);
segments=Topics.segment(trial_data,intervals,headerTopics);

%% Using info.Trial to modify names for the trials when exists
if ismember('info.Trial',allTopics)    
    segmentNames=compose([strrep(trial_data.info.Trial,'.mat','') '_%02d'],1:numel(segments));
    addStartAndEndTimes=true;
elseif ismember('info.File',allTopics)    
    segmentNames=compose([strrep(trial_data.info.File,'.mat','') '_%02d'],1:numel(segments));
    addStartAndEndTimes=true;
else
    addStartAndEndTimes=false;
end

if addStartAndEndTimes
    for i=1:numel(segments)
       segments{i}.info.Trial=segmentNames{i};
       segments{i}.conditions.startTime=intervals{i}(1);
       segments{i}.conditions.endTime=intervals{i}(2);
    end
end
end


function intervals=gc2intervals(header,gc)
    [~,idx]=findpeaks(-gc);
    intervals=[find(gc>0,1)-1 idx' 1+length(gc)-find(flipud(gc)>0,1)]';
    if ( intervals(1)==0)
        intervals=intervals(2:end);
    end
    intervals=header(intervals);
    intervals=[intervals(1:end-1) intervals(2:end)];
    intervals=mat2cell(intervals,ones(size(intervals,1),1),2);
end

