function processed_trial_data=transform(fun,trial_data,varargin)
% processed_trial_data=transform(fun,trial_data,varargin)
% Transform all the topics in Topics with the function fun
% this is similar to processTopics but does not require fun to return a
% table including header. Instead it needs fun to return manipulated
% contents. i.e. out=fun(table_data{:,2:end}) with
% size(out)=size(table_data{:,2:end}). 
%
% processed_trial_data=transform(fun,trial,{'/knee/joint_state','/knee/joint_state'});
% Where fun is a function handle to any function supported. i.e. fun is a 
% function trial_data=my_fun(topic_table{:,2:end});
%
% Regular usage:
% trial_data is a data structure containing all the topics
%
% Advanced usage:
% trial_data could be: a cell array containing trial data structures

%% Validate arguments
try
    functions(fun);
catch
    error('Wrong function, Please check the help for transform');
end

narginchk(1,3);

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
% Adding Parameter varagin
p.addOptional('Topics',{},validStrOrCell);
p.addOptional('VariableNames',{},validStrOrCell);
p.parse(varargin{:});

% Get the optional results:
% Get message list
% List of messages to process:
if isempty(p.Results.Topics)
    topics_list=Topics.topics(trial_data);
elseif ischar(p.Results.Topics)
    topics_list={p.Results.Topics};
else
    topics_list=p.Results.Topics;
end



%% Process topics
% Check if trial_data is a cell array this will call processTrials and
% recursively transform inside each trial. If it is not a cell array
% this will execute transform normally.
if iscell(trial_data)
    %This seems convoluted, but sometimes we want to use transform to
    %affect all the topics on all trials in the same way. (e.g. normalize)
    trial_array=trial_data;
    ProcessOneTrialfun=@(any_trial_data)Topics.transform(fun,any_trial_data,topics_list);
    processed_trial_data=cellfun(ProcessOneTrialfun,trial_array,'Uni',0);    
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
        out=fun(msg_table{:,2:end});
        if size(out,1)==size(msg_table.Header,1)
            header=msg_table.Header;
        else
            header=(1:size(out,1))';
        end
        
        if ~isempty(p.Results.VariableNames)                        
            msg_table=array2table([header, out],'VariableNames',p.Results.VariableNames);
        elseif isempty(p.Results.VariableNames) && (size(out,2)==size(msg_table,2)-1)
            VariableNames=msg_table.Properties.VariableNames;
            msg_table=array2table([header, out],'VariableNames',VariableNames);
        else
            msg_table=array2table([header, out]);
            msg_table.Properties.VariableNames{1}='Header';
        end
        
        processed=setfield(processed,nsTopic{:},msg_table);
    end
    processed_trial_data=processed;
end