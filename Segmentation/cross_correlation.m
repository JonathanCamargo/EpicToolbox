%% exploring crosscorrelation ?? not a function.
%% TODO make this a function
clc;clear;close all;
%% Script to postprocess a mat file

% User selects a mat file to process and the script loads the file,
% reads the fsm.State table and segments the data by gait cycles detected.
% Output is a cell array of structures with length=#of gait cycles. The
% times are zero indexed to the initiation of each EarlyStance.

% Load a mat file
mat_file='../Maegan/3.mat';
load(mat_file);

% List of messages to process:
messages_list={'knee.joint_state','ankle.joint_state',...
    'knee.torque_setpoint','ankle.torque_setpoint'};

% Get the number of cycles within a bag file
% i.e. count blocks EarlyStance-EarlyStance in the fsm.State
states=[fsm.State.State{:}]';
times=fsm.State.Header;
index=find(strcmp(states,'EarlyStance'))';
earlyStanceTimes=times(index);


for i=1:(length(earlyStanceTimes)-1)
    extracted=struct('mat_file',mat_file,'start_time',earlyStanceTimes(i));
    extracted=setfield(extracted,'end_time',earlyStanceTimes(i+1));    
    for j=1:length(messages_list)        
        msg_table=eval(messages_list{j});
        out=cut(msg_table,earlyStanceTimes(i),earlyStanceTimes(i+1));
        out.Header=out.Header-out.Header(1);
        fields=strsplit(messages_list{j},'.');
        extracted=setfield(extracted,fields{:},out);        
    end
    cycles{i}=extracted;
end

%% QUESTION: Normalize gait cycle from 0-100% to have non dimensional time?

%% Plot all cycles
figure('Name','Angles');
for i=1:length(cycles)
    subplot(2,1,1);
    plot(cycles{i}.knee.joint_state.Header,cycles{i}.knee.joint_state.Theta);
    xlabel('Time [s]'); ylabel('Angle [deg]'); title('Knee angle');
    hold on;
    subplot(2,1,2);
    plot(cycles{i}.ankle.joint_state.Header,cycles{i}.ankle.joint_state.Theta);
    xlabel('Time [s]'); ylabel('Angle [deg]'); title('Ankle angle');
    hold on;
end
hold off;
figure('Name','Torque');
for i=1:length(cycles)
    subplot(2,1,1);
    plot(cycles{i}.knee.torque_setpoint.Header,cycles{i}.knee.torque_setpoint.Torque_);
    xlabel('Time [s]'); ylabel('Torque [Nm]'); title('Knee torque');
    hold on;
    subplot(2,1,2);
    plot(cycles{i}.ankle.torque_setpoint.Header,cycles{i}.ankle.torque_setpoint.Torque_);
    xlabel('Time [s]'); ylabel('Torque [Nm]'); title('Ankle torque');
    hold on;
end
hold off;

%% Cross Correlation with Two Signals

x=cycles{1}.knee.torque_setpoint.Torque_;
y=cycles{2}.knee.torque_setpoint.Torque_;

[acor,lag]=xcorr(x,y);
[maxacor,I] = max(acor)
lagDiff = lag(I);

figure('Name','Original vs. Best acor for Two Signals -> Torque');
subplot(2,1,1)
plot(x); hold on; plot(y);
legend('x','y')
subplot(2,1,2)
plot(x); hold on; plot([zeros(lagDiff,1); y]);
legend('x', 'y')

%% Cross Correlation with All Signals

for i=1:length(cycles)-1
    x1=cycles{1}.knee.torque_setpoint.Torque_;
    y1=cycles{i+1}.knee.torque_setpoint.Torque_;

    [acor1,lag1]=xcorr(x1,y1);
    [maxacor1(i),I1(i)] = max(acor1(i));
    lagDiff1(i) = lag(I1(i)); 
    
end

figure('Name','New')
plot(x1); hold on; plot(y1(i));hold on;  
plot(x1); hold on; plot([zeros(lagDiff1(i),1); y1]); hold on;




