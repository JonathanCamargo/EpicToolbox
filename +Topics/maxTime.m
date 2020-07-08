function [max_time,topic_name]= maxTime(data,varargin)
% Get the maximum time found in the topic
%
%  [max_time,topic_name]=maxtime(trial_data,OPTIONAL:SELECTED_TOPICS)
%     Finds the maxtime of the topics in the trial_data (with OPTIONAL
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
    topics_list=Topics.defaults.fields;
end


%Check the first message time from the topics and consider that the
    %time for shifting.
    fun=@(table_data)table_data.Header(end);
    last_times=Topics.processTopics(fun,data);
    % Get the initial time
    max_time=-inf;
    for msg_idx=1:length(topics_list)
        try
            last_time=eval(sprintf('last_times.%s',topics_list{msg_idx}));
        catch
            continue
        end
        if last_time>max_time
            max_time=last_time;
            topic_name=topics_list{msg_idx};
        end
    end

end
