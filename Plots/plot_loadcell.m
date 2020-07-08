function h=plot_loadcell(experiment_data,varargin)
% Plot the loadcell data 
% use: Topics.plot_loadcell(experiment_data,optional::options);
% 
% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'phases' | true/(false)            |  Add phases
% 'topic'  | ('loadcellreadings')    |  Came of the loadcell topic
 

p=inputParser;
p.addParameter('phases',false);
p.addParameter('topic','loadcell.load_cell_readings');
p.parse(varargin{:});

phases=p.Results.phases;
topic=p.Results.topic;

% Check if the topic is there or throw error

try     
    eval(sprintf('data=experiment_data.%s;',topic));
    istable(data);
catch
    error('Topic: %s does not exist',topic);
end

subplot(2,1,1);
t=data.Header;
x=data.ForceX;
y=data.ForceY;
z=data.ForceZ;
h1=plot(t,x);hold on;
h2=plot(t,y);
h3=plot(t,z);
legend_str={'Fx','Fy','Fz'};
title('Loadcell Forces');
xlabel('Time [s]'); ylabel('Force [N]');
if isfield(experiment_data,'fsm')&& phases
    Topics.plot_phases(experiment_data);
end
hold off;
legend([h1 h2 h3],legend_str);

subplot(2,1,2);
t=data.Header;
x=data.MomentX;
y=data.MomentY;
z=data.MomentZ;
h1=plot(t,x);hold on;
h2=plot(t,y);
h3=plot(t,z);
legend_str={'Mx','My','Mz'};
title('Loadcell Moment');
xlabel('Time [s]'); ylabel('Moment [Nm]');
if isfield(experiment_data,'fsm')&& phases
    Topics.plot_phases(experiment_data);
end
hold off;
legend([h1 h2 h3],legend_str);
h=gcf;


end