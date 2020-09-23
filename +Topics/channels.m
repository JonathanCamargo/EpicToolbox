function allchannels=channels(trial_data,topic,varargin)
% alltopics=channels(trial_data,topic,varargin)
% Get all the channel names that are present in a topic
%
%

p=inputParser();
p.parse(varargin{:});

topicfields=strsplit(topic,'.');
tbl=getfield(trial_data,topicfields{:});

if istable(tbl)        
    allchannels=tbl.Properties.VariableNames;
    if strcmp(allchannels{1},'Header')
        allchannels=allchannels(2:end);
    end
else
    allchannels={};
end


end



