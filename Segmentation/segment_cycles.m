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
    messages_list=Topics.topics(trial_data);
else
    error('Wrong number of arguments please check documentation');
end

% Get the number of cycles within a bag file
% i.e. count blocks EarlyStance-EarlyStance in the fsm.State
states=[trial_data.fsm.State.State];
times=trial_data.fsm.State.Header;
index=find(strcmp(states,'LW_EarlyStance'))';
% index=find(contains(states,'EarlyStance'))';
earlyStanceTimes=times(index);

intervals=[earlyStanceTimes(1:end-1) earlyStanceTimes(2:end)];
intervals=mat2cell(intervals,ones(size(intervals,1),1),[2]);

segmented =Topics.segment(trial_data,intervals,messages_list);
end

