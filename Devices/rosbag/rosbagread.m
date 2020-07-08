function [experiment,readTopics] = rosbagread(bag_path,varargin)
%Read the rosbag file in bag_path and return a structure (experiment)
%that holds all the messages organized in tables by topic name.
%
% varargins are name value pairs:
% - 'ignore': cell array with topics to discard
% - 'read': cell array with topics to read (if not used it will
% read all (except the ignored).
%
% e.g. rosbagread('example.bag','ignore',{'/clock'});

%% Optional name value pairs
inputs=inputParser;
%name value pairs optional inputs
Names={'ignore','read'};
Defaults={{},{}};
for i=1:numel(Names)
    addOptional(inputs,Names{i},Defaults{i});
end
parse(inputs,varargin{:});
ignore=inputs.Results.ignore;
read=inputs.Results.read;
%%
bag=rosbag(bag_path);
all_topics=bag.AvailableTopics.Properties.RowNames;

experiment=struct('trial',bag_path);
%Filter topics from all topics according to 'read' and 'ignore' options
topics=all_topics;
if ~isempty(read)
    index=zeros(length(all_topics),1);
    for i=1:length(read)
        mask=strcmp(all_topics,read(i));
        index=index|mask;
    end
    topics=all_topics(index);
end
if ~isempty(ignore)
    index=zeros(length(topics),1);
    for i=1:length(ignore)
        mask=strcmp(topics,ignore(i));
        index=index|mask;
    end
    topics=topics(~index);
end

fprintf('Selected Topics:\n');
fprintf('%s\n',topics{:});
fprintf('\n')

count=0;
readTopics=topics;
for i=1:length(topics)
    topic=topics{i};
    fprintf('Processing topic: %s\r',topic);
    data_table=parse_topic(bag,topic);
    if ~isempty(data_table)
        nsTopic = strsplit(topic(2:end),'/');
        experiment=setfield(experiment,nsTopic{:},data_table);
        count=count+1;
        readTopics{count}=strjoin(nsTopic,'.');
    end
end
readTopics=readTopics(1:count);
end




