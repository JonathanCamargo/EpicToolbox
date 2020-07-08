function data_table = parse_topic(bag,topic_name)
% Takes a bagselection object (help rosbag) and generates a table for the
% specific topic (topic_name).
% e.g
% bag=rosbag('somefile.bag');
% a_table=parse_topic(bag,'/GlobalNam/espace/sometopic');
% a_table will contain the information of that topic

try
    selected_msgs=bag.select('Topic',topic_name);
    messages=readMessages(selected_msgs,'DataFormat','struct');
catch
    warning('%s not supported please use rosgenmsg ~/epic_git/ros_firmware/custom_msgs_ws/src',topic_name);
    data_table={};
    return
end

if ~isempty(messages)
    VariableNames=fieldnames(messages{1});
else
    error(['No messages of topic ' topic_name]);
end

for k=1:numel(VariableNames)
    field = VariableNames{k};
    if strcmp(field,'Header') % double time
        data.(field) = cellfun(@(m) double(m.Header.Stamp.Sec) + double(m.Header.Stamp.Nsec)/10^9,messages); 
    elseif ~strcmp(field,'MessageType')
        if ~iscell(messages{1}.(field)) && ~isstruct(messages{1}.(field)) && isscalar(messages{1}.(field)) && ~ischar(messages{1}.(field))
            data.(field) = cellfun(@(m) double(m.(field)),messages,'UniformOutput',true);
        else
            data.(field) = cellfun(@(m) m.(field),messages,'UniformOutput',false);
        end
    end
end
data_table=struct2table(data);
end