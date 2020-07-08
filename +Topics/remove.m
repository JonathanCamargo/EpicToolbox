function trial_data=remove(trial_data,varargin)
% Remove topics from trial_data
%
% trial_data=Topics.remove(trial_data,{'knee.joint_state','knee.joint_state'});
% 
%
% Regular usage:
% trial_data is a data structure containing only the topics selected
%
% Advanced usage:
% trial_data could be: a cell array containing trial data structures


% Get message list
if nargin==2
    topics_list=varargin{1};
    if ischar(topics_list)
        topics_list={topics_list};
    end
else
    topics_list=Topics.defaults.fields;
end

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
            for field_idx=fliplr(1:numel(fields))                
                if (length(fields)==1)  % Arrived to root level
                      eval(sprintf('selected=rmfield(selected,''%s'');',char(fields(end))));    
                    break;
                end
                prefix=fields(1:end-1);
                a=char(join(prefix,'.'));
                b=eval(sprintf('fieldnames(selected.%s)',a));                                
                if isempty(b)                    
                    fields=fields(1:end-1);
                else
                    eval(sprintf('selected.%s=rmfield(selected.%s,''%s'');',a,a,char(fields(end))));    
                    break;
                end
            end        
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
