function segmented= segment_cycles(trial_data,varargin)
%Segment the trial data by cycles
%Function receives a trial_data structure containing the topics in
%ros namespace and split them to a cell array of structures
% according to trial_data.
%
% usage: 
%        %Segment only ankle.joint_state 
%        segment_cycles(experiment_data,{'ankle.joint_state'});
%
%        %Segment all the topics configured in the @Topics class 
%        segment_cycles(experiment_data);


if nargin==2
    % List of messages to process:
    messages_list=varargin{1};
elseif nargin==1
    messages_list=Topics.fields;
else
    error('Wrong number of arguments please check documentation');
end

% Get the number of cycles within a bag file
% i.e. count blocks EarlyStance-EarlyStance in the fsm.State
states=[trial_data.fsm.State.State{:}]';
times=trial_data.fsm.State.Header;
index=find(strcmp(states,'EarlyStance'))';
% index=find(contains(states,'EarlyStance'))';
earlyStanceTimes=times(index);

cycles={};
for i=1:(length(earlyStanceTimes)-1)
    extracted=struct('mat_file',trial_data.trial,'start_time',earlyStanceTimes(i));
    extracted=setfield(extracted,'end_time',earlyStanceTimes(i+1));    
    for j=1:length(messages_list)        
        msg_table=eval(sprintf('trial_data.%s',messages_list{j}));
        out=cut(msg_table,earlyStanceTimes(i),earlyStanceTimes(i+1));
        
        out.Header=out.Header-earlyStanceTimes(i);
        fields=strsplit(messages_list{j},'.');
        extracted=setfield(extracted,fields{:},out);        
    end
    cycles{i}=extracted;
end

segmented=cycles;

end

