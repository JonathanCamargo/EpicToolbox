function [min_time,topic_name]= minTime(data,varargin)
% Get the minimum time found in the topics
%
%  [min_time,topic_name]=minTime(trial_data,OPTIONAL:SELECTED_TOPICS)
%     Finds the minTime of the topics in the trial_data (with OPTIONAL
%     selection of which topics to process)
%
%
% See also Topics

% Check if the data is a the topic or all the trial data

narginchk(1,2);

% Get message list
if nargin==2
    topics_list=varargin{1};
else
    topics_list=Topics.fields;
end


%Check the first message time from the topics and consider that the
    %time for shifting.
    fun=@(table_data)table_data.Header(1);
    first_times=Topics.processTopics(fun,data);
    % Get the initial time
    min_time=inf;
    for msg_idx=1:length(topics_list)
        try
            first_time=eval(sprintf('first_times.%s',topics_list{msg_idx}));
        catch
            continue
        end
        if first_time<min_time
            min_time=first_time;
            topic_name=topics_list{msg_idx};
        end
    end
      
end

