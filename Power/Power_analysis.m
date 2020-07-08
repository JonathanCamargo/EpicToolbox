%% power anaylsis
function power=Power_anaylsis(experiment_data,varargin)

%% process data
Get message list
if nargin==2
    % List of messages to process:
    topics_list=varargin{1};
elseif nargin==1
    topics_list=Topics.fields;
else
    error('Wrong number of arguments please check documentation');
end
%
% List of messages to process:
messages_list={'knee.joint_state','ankle.joint_state',...
    'knee.torque_setpoint','ankle.torque_setpoint'};

%% power analysis 

% instantaneous power=T*w 

for i=1:length(experiment_data)
   power{1,i}.ankle.inst = experiment_data{i}.ankle.torque_setpoint.Torque_.*experiment_data{i}.ankle.joint_state.ThetaDot;
   power{1,i}.knee.inst = experiment_data{i}.knee.torque_setpoint.Torque_.*experiment_data{i}.knee.joint_state.ThetaDot;   
end

% actual power = int(p(dt))
    for i=1:length(cycles)
        Time_power_ankle(i) = int(power_ankle(i),trial_data{i}.start_time,trial_data{i}.end_time); 
        Time_power_knee(i) = int(power_knee(i),trial_data{i}.start_time,trial_data{i}.end_time);      
    end
    end
   
    


