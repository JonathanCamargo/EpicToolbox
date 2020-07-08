function [normalized,min_values,max_values]= normalize(trial_data, varargin)
% [normalized,min_values,max_values]= normalize(trial_data, varargin)
%Normalize the trial data by 0-1 for all or selected channels
%
% Function receives a trial_data structure containing the topics
%
% normalized=normalize(trial_data,OPTIONAL:TOPICNAMES,OPTIONAL:CHANNELS)
% 
% 
% usage: 
%
%        %normalize only the header for ankle.joint_state
%        normalize(experiment_data,{'ankle.joint_state'},'Header');
%
%        %normalize only the header for all the topics configured in the Topics class for all
%        normalize(experiment_data,{},'Header');
%
%        
%        %normalize Theta and Header for ankle.joint_state, and only Header for
%        knee.joint_state
%        normalize(experiment_data,{'ankle.joint_state','knee.joint_state'},{{'Theta','Header'},{'Header'}});
%
%        %normalize all the topics configured in the Topics class for all
%        the channels (including Header)
%        normalize(experiment_data);

%% Set the optional arguments
narginchk(1,4);

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
% Adding Parameter varagin
p.addOptional('Topics',{},validStrOrCell);
p.addOptional('Channels',{},validStrOrCell);
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

if any(ismember([channel_list{:}],'Header'))
    NormalizeHeader=true;
else
    NormalizeHeader=false;
end
    

if iscell(trial_data) %it is not an individual trial but a cell array with trials. 
    %run the normalize function individually.
    trials_array=trial_data;
    fun=@(each_trial_data)Topics.normalize(each_trial_data,varargin{:});
    normalized=cellfun(fun,trials_array,'Uni',0);
else
    
    if NormalizeHeader
        %Header should be normalized accross topics thus we need to go
        %through all of them and find the min and max time.
        fun=@(table_data)table_data.Header(1);
        start_times=Topics.processTopics(fun,trial_data,topics_list);
        fun=@(table_data)table_data.Header(end);
        end_times=Topics.processTopics(fun,trial_data,topics_list);
        min_time=inf;
        max_time=0;
        for msg_idx=1:length(topics_list)
                try
                    start_time=eval(sprintf('start_times.%s',topics_list{msg_idx}));
                    end_time=eval(sprintf('end_times.%s',topics_list{msg_idx}));
                catch
                    continue
                end
                if start_time<min_time
                    min_time=start_time;
                end
                if end_time>max_time
                    max_time=end_time;
                end
        end
    end
    
    
    %Other channels are normalized for each table own data so we need to
    %find max and min values per topic.
    fun=@(table_data)max_(table_data);    
    max_values=Topics.processTopics(fun,trial_data,topics_list);
    fun=@(table_data)min_(table_data);
    min_values=Topics.processTopics(fun,trial_data,topics_list);
    
    
    %Now normalize the channels that we were asked to normalize
    normHeader=false(size(topics_list));
    for msg_idx=1:length(topics_list)        
        try
            table_data=eval(sprintf('trial_data.%s',topics_list{msg_idx}));
        catch
            warning('EpicToolbox:topicNotFound','%s does not exist, skipping',topics_list{msg_idx});
            continue
        end
        
        channels=table_data.Properties.VariableNames;
        maxVals=array2table(ones(size(channels)),'VariableNames',channels);
        minVals=array2table(zeros(size(channels)),'VariableNames',channels);
        
        %Channels for this topic is empty -> normalize all channels and header
        if isempty(channel_list{msg_idx})
            channel_list{msg_idx}=channels;
        end
        
        %If any of the channels is a header skip the header since this is normalized in a different way        
        if any(ismember(channel_list{msg_idx},'Header')) 
            normHeader(msg_idx)=true;     
            channel_list{msg_idx}=setdiff(channel_list{msg_idx},{'Header'});
        end
        
        if isempty(channel_list{msg_idx})
            continue;
        end

        % Get all the channels and normalize        
        % if there is no channels to normalize for this topic then skip. Probably
        % we just need to normalize the header and that is done outside of this for loop.
        if isempty(channel_list{msg_idx})
            continue;
        end
        % Remove Header
        [isSelected,selectedChannelsInd]=ismember(channel_list{msg_idx},table_data.Properties.VariableNames);
        selectedChannelsInd=sort(selectedChannelsInd(isSelected));        
        
        b=(max_values.(topics_list{msg_idx}));        
        maxVals{1,selectedChannelsInd}=b{1,selectedChannelsInd};
        max_values.(topics_list{msg_idx})=maxVals;
        
        b=(min_values.(topics_list{msg_idx}));
        minVals{1,selectedChannelsInd}=b{1,selectedChannelsInd};                      
        min_values.(topics_list{msg_idx})=minVals;
        
        table_data=normalize_table(table_data,maxVals.Variables,minVals.Variables);
        
        try
            eval(sprintf('trial_data.%s=table_data;',topics_list{msg_idx}));
        catch
            warning('EpicToolbox:topicNotFound','%s does not exist, skipping',topics_list{msg_idx});
            continue
        end        
        
    end
   
    normalized=trial_data;
    if NormalizeHeader
        %normalize Header for desired topics
        fun=@(table_data)normalize_table_header(table_data,max_time,min_time);
        normalized=Topics.processTopics(fun,trial_data,topics_list(logical(normHeader)));
    end
    
   % RETURN ALL or only normalized?
   % normalized=Topics.select(normalized,topics_list); 
   % min_values=Topics.select(min_values,topics_list);
   % max_values=Topics.select(max_values,topics_list);
end
end

function normalized_table = normalize_table(table_data,maxvalues,minvalues)
% Given a vector of maxvalues and minvalues normalize the data in a table
% table_data
% 
% Do not use this function directly. Use normalize instead
% See also normalize
   normalized_table=table_data;
   [M,~]=size(table_data);
   maxVals=repmat(maxvalues,M,1);
   minVals=repmat(minvalues,M,1);
   normalized_table{:,:}=(normalized_table{:,:}-minVals)./(maxVals-minVals);
end

function normalized_table = normalize_table_header(table_data,maxtime,mintime)
% Given a vector of maxvalues and minvalues normalize the data in a table
% table_data
% 
% Do not use this function directly. Use normalize instead
% See also normalize   
   table_data.Header=(table_data.Header-mintime)/(maxtime-mintime);   
   normalized_table=table_data;
end

function out=max_(table_data)
    %Modified max function for tables
    out=nan(1,size(table_data,2));
    z=table_data(1,:);
    isnum=varfun(@isnumeric,z);
    isnum=isnum{1,:};
    out(isnum)=max(table_data{:,isnum});
    out=array2table(out,'VariableNames',table_data.Properties.VariableNames);
end

function out=min_(table_data)
    %Modified min function for tables
    out=nan(1,size(table_data,2));
    z=table_data(1,:);
    isnum=varfun(@isnumeric,z);
    isnum=isnum{1,:};
    out(isnum)=min(table_data{:,isnum});
    out=array2table(out,'VariableNames',table_data.Properties.VariableNames);
end
