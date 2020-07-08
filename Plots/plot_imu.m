function h=plot_imu(experiment_data,varargin)
% Plot the imu data 
% use: Topics.plot_imu(experiment_data,optional::options);
% 
% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'phases' | true/(false)            |  Add phases
% 'segments'  | ('foot.Euler')          |  Name of imu topic (Repeat 3 times) for foot, shank, and thigh
% 'channelsE' | ('Roll', 'Pitch', 'Yaw')
% 'channelsQ' | ('X','Y','Z','W')
 
p=inputParser;
p.addParameter('phases',false);
p.addParameter('segments',{'imu.foot','imu.shank','imu.thigh'}');
p.addParameter('channelsE',{'Roll','Pitch','Yaw'});
p.addParameter('channelsQ',{'X','Y','Z','W'});
p.parse(varargin{:});

phases=p.Results.phases;
segments=p.Results.segments;
channelsE=p.Results.channelsE;
channelsQ=p.Results.channelsQ;

% Get the number of segments to plot
numSegments=numel(segments);

% Size of subplot
M=numSegments;N=1;

% Check if the topic is there or throw error

for i=1:numSegments
    
    try     
    eval(sprintf('data=experiment_data.%s;',segments{i}));
    istable(data);
    catch
    error('Topic: %s does not exist',segments{i});
    end
    
    % Plot each segment
    segment=segments{i};
    eval(sprintf('segment_data=experiment_data.%s;',segment));
    subplot(M,N,i);
    
    for j=1:numel(channelsQ)
        channelQ=channelsQ{j};
        % Plot
        t=segment_data.Quaternion.Header;
        x=segment_data.Quaternion.(channelQ);
        eval(sprintf('h%d=plot(t,x);',j)); 
        eval(sprintf("title('%s')",segments{i}));
        hold on;
        
    end

    legend_str={'X','Y','Z'};
    xlabel('Time [s]');
    ylabel('Quaternion []');
    
    if isfield(experiment_data,'fsm') && phases
        Topics.plot_phases(experiment_data);
    end
    hold off;
    legend([h1 h2 h3],legend_str);
    
%     for j=1:numel(channelsE)
%         channelE=channelsE{j};
%         % Plot
%         t=segment_data.Euler.Header;
%         x=segment_data.Euler.(channelE);
%         eval(sprintf('h%d=plot(t,x);',j)); 
%         eval(sprintf("title('%s')",segments{i}));
%         hold on;
%         
%     end
% 
%     legend_str={'Roll','Pitch','Yaw'};
%     xlabel('Time [s]');
%     ylabel('Euler Angles [deg]');
%     
%     if isfield(experiment_data,'fsm') && phases
%         Topics.plot_phases(experiment_data);
%     end
%     hold off;
%     legend([h1 h2 h3],legend_str);
    
end

h=gcf;

end