function out=cut(trial_data,initial_time,final_time,varargin)
% Cut cuts the data in a trial_data between header values initial_time and final_time
%
% cut(trial_data,initial_time,final_time,OPTIONAL::TOPICS)
% 
% You can use this function directly with a table by passing a table instead of a trial_data.
% See also Topics
%
%
%% Get message list

if nargin==4
    % List of messages to process:
    topics_list=varargin{1};
    if ischar(topics_list)
        topics_list={topics_list};
    end
elseif nargin==3
    topics_list=Topics.topics(trial_data);
else
    error('Wrong number of arguments please check documentation');
end

if istable(trial_data)
	out=cut_table(trial_data,initial_time,final_time);
else
	if iscell(trial_data) %it is not an individual trial but a cell array with trials. 
	    %run the cut function individually.
	    trials_array=trial_data;
	    fun=@(each_trial_data)Topics.cut(each_trial_data,initial_time,final_time,topics_list);
	    out=Topics.processTrials(fun,trials_array);
	else
	    fun=@(table_data)Topics.cut(table_data,initial_time,final_time);
	    out=Topics.processTopics(fun,trial_data,topics_list);
	end
end

end


function out=cut_table(table,initial_time,final_time)
%Extract a table by Header time interval
idx=(table.Header>=initial_time)&(table.Header<=final_time);
data=table;
out=data(idx,:);
if isempty(out)
    warning('Interval is empty');
end


end
