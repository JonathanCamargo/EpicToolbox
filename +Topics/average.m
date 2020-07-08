function [meanvalues, stdvalues, maxvalues, minvalues] = average(trials_array, varargin)
%   Average by topic for data obtained from different trials
%   [meanvalues, stdvalues, maxvalues, minvalues]=average(trials_array,OPTIONAL:TOPICNAMES)
%
%    Inputs: [Required] Resampled data in a cell array. All the trials
%            should have the same number of points.
%            [Optional] Message list to average. If no list is passed
%            in, the Topics.defaults.fields list will be used.
%            
%    Output: 1x1 cell array with averaged messages as Nx1 tables within 
%            each message struct.
%
  
% Get message list
if nargin==2
    topics_list=varargin{1};
    if ~iscell(topics_list) && ischar(topics_list)
        topics_list={topics_list};
    end
else
    topics_list=Topics.topics(trials_array,'Header',false);
end

meanvalues=struct();stdvalues=struct();maxvalues=struct();minvalues=struct();

for msg_idx=1:length(topics_list)
    allmessages=[];
    %Extract data from this message from every trial and add to 3dim in
    %allmessages matrix.
    SKIP_TOPIC=false;
    for i=1:size(trials_array,1)
        for j=1:size(trials_array,2)
            if SKIP_TOPIC
                break
            end
            data=trials_array{i,j};            
            try
                msg_table=eval(sprintf('data.%s',topics_list{msg_idx}));
            catch
                warning('EpicToolbox:TopicNotFound','%s does not exist, skipping',topics_list{msg_idx}');
                SKIP_TOPIC=true;
                continue
            end
            try
                if istable(msg_table)
                    x=table2array(msg_table);                    
                elseif isnumeric(msg_table)
                    x=msg_table;
                else
                    error('Data not supported');
                end
                
                if isempty(allmessages)
                    allmessages=x;
                else
                    allmessages=cat(3,allmessages,x);
                end                                    
                
            catch
                warning('Problem with %s: cannot average topic',topics_list{msg_idx}');
                SKIP_TOPIC=true;
                continue
            end
                
        end
    end
    if SKIP_TOPIC
        continue
    end    
    %allmessages contain all the data from this message
    meanmat=nanmean(allmessages,3);
    stdmat=nanstd(allmessages,0,3);
    maxmat=nanmax(allmessages,[],3);
    minmat=nanmin(allmessages,[],3);
    
    %save the data in in the corresponding struct
    if istable(msg_table)
        properties=msg_table.Properties;    
        meantable=array2table(meanmat);meantable.Properties=properties;
        stdtable=array2table(stdmat);stdtable.Properties=properties;
        maxtable=array2table(maxmat);maxtable.Properties=properties;
        mintable=array2table(minmat);mintable.Properties=properties;        
    elseif isnumeric(msg_table)
        meantable=meanmat;
        stdtable=stdmat;
        maxtable=maxmat;
        mintable=minmat;        
    end
    
    fields=strsplit(topics_list{msg_idx},'.');        
    meanvalues=setfield(meanvalues,fields{:},meantable);
    stdvalues=setfield(stdvalues,fields{:},stdtable);
    maxvalues=setfield(maxvalues,fields{:},maxtable);
    minvalues=setfield(minvalues,fields{:},mintable);
   
end
    
end
