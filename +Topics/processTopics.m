function processed_trial_data=processTopics(fun,trial_data,varargin)
% Process all the topics in Topics class with the function fun
%
% processed_trial_data=processTopics(fun,trial,{'knee.joint_state','knee.joint_state'});
% Where fun is a function handle to any function supported. i.e. fun is a 
% function trial_data=my_fun(topic_table);
%
% Regular usage:
% trial_data is a data structure containing all the topics
%
% Advanced usage:
% trial_data could be: a cell array containing trial data structures
% in that case I recommend using the extra optional parameter 'Parallel',
% true.
%

%% Validate arguments
try
    functions(fun);
catch
    error('Wrong function, Please check the help for processTopics');
end
% Get message list
isParallel=false;
if nargin==2
    topics_list=Topics.topics(trial_data);
elseif nargin>=3
    topics_list=varargin{1};
    if ischar(topics_list)
        topics_list={topics_list};
    end
end
if nargin==5
    isParallel=varargin{3};
else
    
end

%% Process topics
% Check if trial_data is a cell array this will call processTrials and
% recursively processTopics inside each trial. If it is not a cell array
% this will execute processTopics normally.
if iscell(trial_data)
    %This seems convoluted, but sometimes we want to use processTopics to
    %affect all the topics on all trials in the same way. (e.g. normalize)
    trial_array=trial_data;
    ProcessOneTrialfun=@(any_trial_data)Topics.processTopics(fun,any_trial_data,topics_list);
        
    
    % Single core
    if ~isParallel
        processed_trial_data=cellfun(ProcessOneTrialfun,trial_array,'Uni',0);    
    end
       
    if isParallel
        % Parallel
        processed_trial_data=cell(size(trial_array));    
        dimensions=size(processed_trial_data);    
        if numel(dimensions)>2
            error('This function does not support trial arrays with more than 2 dimensions');
        end

        triallist=trial_array(:);
        parfor i=1:numel(triallist)                
            triallist{i}=ProcessOneTrialfun(triallist{i});             
        end
        processed_trial_data=reshape(triallist,dimensions);
    end
    %}
else
    %Use the function on each topic
    data=trial_data;
    %processed=struct(); %processed should preserve the unprocessed data
    processed=data;
    for msg_idx=1:length(topics_list)
        topic = topics_list{msg_idx};
        nsTopic = strsplit(topic,'.');
        try
            msg_table=getfield(data,nsTopic{:});
        catch
            warning('EpicToolbox:topicNotFound','%s does not exist, skipping',topics_list{msg_idx});
            continue
        end
        try
            msg_table=fun(msg_table);        
            processed=setfield(processed,nsTopic{:},msg_table);
        catch ME
            warning('EpicToolbox:topicNotProcessed','%s can not be processed with function, skipping',topics_list{msg_idx});
            warning(ME.identifier,ME.message);
            continue
        end
    end
    processed_trial_data=processed;
end