function trial_data=select(trial_data,varargin)
% Selects some specific topics from
%
% selected_trial_data=selectTopics(trial_data,{'knee.joint_state','knee.joint_state'});
% 
% Parameters:
% 'Channels' : a list of channels to select
% 'Search' :  'regexp', 'contains', ('strcmp') how to look for channels 
% Regular usage:
% trial_data is a data structure containing topics
% or a cell array containing trial data structures

%% Set the optional arguments
narginchk(1,6);

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
% Adding Parameter varagin
p.addOptional('Topics',{},validStrOrCell);
p.addParameter('Channels',{},validStrOrCell);
p.addParameter('Search',{},validStrOrCell);
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

if isempty(p.Results.Channels)
    channel_list=repmat({''},size(topics_list));
elseif ischar(p.Results.Channels)
    channel_list=repmat({{p.Results.Channels}},size(topics_list));
elseif iscell(p.Results.Channels) && (numel(p.Results.Channels)~=numel(topics_list))
    error('Channels dimensions do not match with topics list');
else
    channel_list=p.Results.Channels;
end

Search=p.Results.Search;
if isempty(p.Results.Search)
    Search='strcmp';
elseif ~any(ismember(Search,{'contains','regexp','strcmp'}))
    error('Search method not supported');
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
        selected=struct();
        for msg_idx=1:length(topics_list)
            try
                %msg_table=eval(sprintf('data.%s',topics_list{msg_idx}));
                a=strsplit(topics_list{msg_idx},'.');
                msg_table=getfield(data,a{:});                                
            catch
                warning('%s does not exist, skipping',topics_list{msg_idx}');
                continue
            end
            if istable(msg_table)
                channels=msg_table.Properties.VariableNames;
                %Channels for this topic is empty -> select all channels and header
                if isempty(channel_list{msg_idx}) || any(strcmp(channel_list{msg_idx},'*'))
                       channel_list{msg_idx}=channels;
                       selectedChannelsInd=1:numel(channels);
                else
                    % Old version using ismember requires exact string for channel
                    % [isSelected,selectedChannelsInd]=ismember(channel_list{msg_idx},msg_table.Properties.VariableNames);
                    % selectedChannelsInd=sort(selectedChannelsInd(isSelected));        
                    % Use regexp to allow easy selection of channels with a pattern                
                    keys=channel_list{msg_idx};
                    isSelected=false(size(keys));
                    selectedChannelsInd=[];
                    for keyIdx=1:numel(keys)
                        key=keys{keyIdx};
                        switch Search
                            case 'regexp'
                                foundcell=regexp(msg_table.Properties.VariableNames,key);
                                found=cellfun(@(x)(~isempty(x)),foundcell);
                            case 'contains'
                                found=contains(msg_table.Properties.VariableNames,key);
                            case 'strcmp'
                                found=strcmp(msg_table.Properties.VariableNames,key);
                        end                                        
                        isSelected(keyIdx)=any(found);                    
                        selectedChannelsInd=[selectedChannelsInd find(found)];
                    end
                    selectedChannelsInd=unique(selectedChannelsInd,'stable');
                end
                

                msg_table=msg_table(:,selectedChannelsInd);              
            end
            fields=strsplit(topics_list{msg_idx},'.');
            selected=setfield(selected,fields{:},msg_table);
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
