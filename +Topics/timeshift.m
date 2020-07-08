function timeshifted= timeshift(trial_data,time,varargin)
% Shift the time of the topics
%
%  timeshift(trial_data,time)
%     Shifts the header of the table
%  timeshift(trial_data,time,OPTIONAL:SELECTED_TOPICS)
%     Shifts the header of the topics in the trial_data (with OPTIONAL
%     selection of which topics to process)
%
%  Pass in 'auto' for time(input) when you want to automatically find the minimum
%  time compared to passing in manually
%
% See also Topics

% Check if the data is a the topic or all the trial data

% Get message list
if nargin==3
    topics_list=varargin{1};
else
    topics_list=Topics.topics(trial_data);
end

if iscell(trial_data) %it is not an individual trial but a cell array with trials. 
    %run the normalize function individually.
    trials_array=trial_data;
    fun=@(each_trial_data)Topics.timeshift(each_trial_data,time,varargin{:});
    timeshifted=cellfun(fun,trials_array,'Uni',0);
else
    

    % Check if time is auto
    if strcmp(time,'auto')
        % AUTOTIME is true;
        %Check the first message time from the topics and consider that the
        %time for shifting.
        fun=@(table_data)table_data.Header(1);
        first_times=Topics.processTopics(fun,trial_data,topics_list);
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
            end
        end
        min_time=-min_time;
    else
        % AUTOTIME is false;
        min_time=time;

    end
    fun=@(table_data)timeshift_table(table_data,min_time);
    timeshifted=Topics.processTopics(fun,trial_data,topics_list);

end
end

function shifted_table=timeshift_table(table_data,time)
    shifted_table=table_data;
    shifted_table.Header=(table_data.Header+time); 
end
