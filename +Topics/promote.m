function trial_data=promote(trial_data,varargin)
% Move topics to the root level of the trial_data struct
%
% trial_data=Topics.promote(trial_data,{'knee.joint_state','knee.joint_state'});
% 
% Optional name value pairs: 
% 'Prepend', true/(false)     prepend the name of the topic to the column
%
% Regular usage:
% trial_data is a data structure containing only the topics selected
%
% Advanced usage:
% trial_data could be: a cell array containing trial data structures


% Set the optional arguments
narginchk(1,4);
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
p=inputParser;
p.addOptional('Topics',{},validStrOrCell);
p.addParameter('Prepend',false,@islogical); 
p.parse(varargin{:});

% Get the optional results:
% Get message list
% List of messages to process:
if isempty(p.Results.Topics)
    topics_list=Topics.topics(trial_data,'Header',false);
elseif ischar(p.Results.Topics)
    topics_list={p.Results.Topics};
else
    topics_list=p.Results.Topics;
end

Prepend=p.Results.Prepend;

%% Check if trial_data is a cell array
if iscell(trial_data)
    ADVANCED=true;
else
    ADVANCED=false;
end

for i=1:size(trial_data,1)
    for j=1:size(trial_data,2)
        % Get the data depending if it is cell array or not
        if ADVANCED
            data=trial_data{i,j};
        else
            data=trial_data;
        end
        %Use the function on each topic
        selected=data;
        for msg_idx=1:length(topics_list)
            try
                msg_table=eval(sprintf('data.%s',topics_list{msg_idx}));                          
            catch
                warning('%s does not exist, skipping',topics_list{msg_idx}');
                continue
            end
            fields=split(topics_list{msg_idx},'.');            
            selected=Topics.remove(selected,topics_list{msg_idx});
            if Prepend
                newname=char(join(fields,'_'));
            else
                newname=char(fields{end});
            end
            selected.(newname)=msg_table;
        end
        % Save the result depending if it is cell array or not
        if ADVANCED
            trial_data{i,j}=selected;
        else
            trial_data=selected;
        end
    end
end

    
end
