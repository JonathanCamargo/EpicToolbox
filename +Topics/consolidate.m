function [consolidate,names]=consolidate(trial_data,varargin)
% Consolidate all channels for the topics from a trial_data in a big table
%
%  [consolidate,names]=consolidate(trial_data,OPTIONAL:TopicsList)
%
%   consolidate is the big table
%   names is the equivalency of names in the table to topic.channel names
%   
%   Optional: use short names
%   'ShortNames', true/(false)
%   'Prepend', true/(false)     prepend the name of the topic to the column
%   names
%
if ~isstruct(trial_data)
    error('trial_data must be struct');
end

% Set the optional arguments
narginchk(1,6);
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
p=inputParser;
p.addOptional('Topics',{},validStrOrCell);
p.addParameter('ShortNames',false,@islogical);
p.addParameter('Prepend',true,@islogical); 
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
useShortNames=p.Results.ShortNames;
Prepend=p.Results.Prepend;
% Collect all the values in a big table
featureTable={};
N=0;
shortnames={};longnames={};


firstHeaderData=[];


for i=1:numel(topics_list)
    topic_name=topics_list{i};
    try        
        x=eval(sprintf('trial_data.%s',topic_name));       
    catch
        warning('EpicToolbox:topicNotFound','%s does not exist, skipping',topic_name);
        continue
    end
    
    if strcmp(x(:,1).Properties.VariableNames,'Header') && isempty(firstHeaderData)
        firstHeaderData=x.Header;   
        x_header=x.Properties.VariableNames;
        if Prepend
            x_header=strcat(repmat({[topic_name '_']},size(x_header)),x_header);
        end
        x_header(1)={'Header'};
    elseif ~isempty(firstHeaderData) && strcmp(x(:,1).Properties.VariableNames,'Header')
        if (numel(x.Header)~=numel(firstHeaderData) || ~sum(x.Header==firstHeaderData))
            warning('Header data is different for %s. Intersecting',topic_name);
            [firstHeaderData, x_inds, tblInds]=intersect(x.Header,firstHeaderData);
            x=x(x_inds, :);
            featureTable = {featureTable{1}(tblInds, :)};
        end
        x=x(:,2:end); %Remove header
        x_header=x.Properties.VariableNames;
        if Prepend
            x_header=strcat(repmat({[topic_name '_']},size(x_header)),x_header);
        end
    else %There is no header
        x_header=x.Properties.VariableNames;
        if Prepend
            x_header=strcat(repmat({[topic_name '_']},size(x_header)),x_header);
        end
    end 
    
    %Get a dummy naming for the features
    n=length(x_header);
    names=strsplit(sprintf('F%d\t',(N+(1:n))),'\t'); names=names(1:end-1);    
    shortnames=[shortnames ;names'];
    longnames=[longnames ;x_header'];
    %featureTable=[featureTable table2cell(x(:,:))];
    x.Properties.VariableNames=names';
    featureTable=[featureTable x]; 
    %
    N=N+n;
end
longnames=strrep(longnames,'.','_');
featureNames=[shortnames longnames];

featureNames=array2table(featureNames,'VariableNames',{'ShortName','LongName'});

if useShortNames
    featureTable.Properties.VariableNames=shortnames;
elseif ~(length(unique(longnames))==length(longnames))    
    error('Can not use long names, names are repeated');
else 
    featureTable.Properties.VariableNames=longnames;
end
consolidate=featureTable;
names=featureNames;

end
