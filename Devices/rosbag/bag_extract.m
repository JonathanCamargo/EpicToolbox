function [t,content] = bag_extract( bag,topic)
%Get all the messages of a specific topic from a matlab bag
% Select topics
selected_msgs=bag.select('Topic',topic);
messages=selected_msgs.readMessages();

t=selected_msgs.MessageList{:,1};

if ~isempty(messages)
    type=messages{1}.MessageType;
    content=parse_contents(messages,type);
else
    error(['No messages of topic ' topic]);
end

end

function content=parse_contents(messages,type)
N=length(messages);
switch type
    case {'std_msgs/Bool'}
        variables={'Data'};
        content=zeros(N,1);
        for i=1:N
            content(i)=messages{i}.Data;
        end
    case {'std_msgs/String'}
        variables={'Data'};
        content=cell(N,1);
        for i=1:N
            content{i}=messages{i}.Data;
        end
    case {'custom_msgs/JointState'}
        variables={'Theta','ThetaDot','Torque'};
        content=zeros(N,3);
        for i=1:N
            content(i,:)=[messages{i}.Theta messages{i}.ThetaDot messages{i}.Torque] ;
        end
    case {'custom_msgs/Torque'}
        variables={'torque'};
        content=zeros(N,1);
        for i=1:N
            content(i,:)=messages{i}.Torque_;
        end
    case {'custom_msgs/LoadCellReadings'}
        variables={'forceX', 'forceY', 'forceZ', 'momentX', 'momentY', 'momentZ'};
        content=zeros(N,6);
        for i=1:N
            content(i,:)=[messages{i}.forceX messages{i}.forceY messages{i}.forceZ messages{i}.momentX messages{i}.momentY messages{i}.momentZ] ;
        end   
    otherwise
        error(['Message type ' type ' not supported please edit bag_extract.m and add a section in the parse_contents function']);
end
content=array2table(content,'VariableNames',variables);


end

