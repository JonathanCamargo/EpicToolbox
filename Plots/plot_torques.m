function h=plot_torques(experiment_data)
% Plot joint states for knee and angle including:
% -subplot of Theta
% -subplot of thetadot

a_js=experiment_data.ankle.torque_setpoint;
k_js=experiment_data.knee.torque_setpoint;

subplot(2,1,1); hold on;
a=plot(a_js.Header,a_js.Torque_);
ylabel('Torque [Nm]');%xlim([t_1(1)-t1_0 t_1(end)-t1_0]);
title('Ankle torque');
if isfield(experiment_data,'fsm')
    Topics.plot_phases(experiment_data);
end
uistack(a,'top');


subplot(2,1,2); hold on;
a=plot(k_js.Header,k_js.Torque_);
ylabel('Torque [Nm]');%xlim([t_1(1)-t1_0 t_1(end)-t1_0]);
title('Knee torque');
if isfield(experiment_data,'fsm')
    Topics.plot_phases(experiment_data);
end
uistack(a,'top');

h=gcf;
end

