function h=plot_kinematics(experiment_data,varargin)
% Plot the loadcell data 
% use: Topics.plot_kinematics(experiment_data,optional::options);
% 
% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'phases'   | true/(false)            |  Add phases
% 'joints'   | {'ankle','knee'}        |  Joints to plot
% 'Channels' | {'Theta' , 'ThetaDot'}               |  Channels to plot

p=inputParser;
p.addParameter('phases',false);
p.addParameter('joints',{'ankle','knee'});
p.addParameter('channels',{'Theta'});
p.parse(varargin{:});


phases=p.Results.phases;
joints=p.Results.joints;
channels=p.Results.channels;

% Get the number of joints to plot:
DOF=numel(joints);

% Size of subplot
M=DOF;N=1;

%Hardcode prismatic joints by name (until we stablish better
%custom_msgs.
jointType=cell(DOF,1);
for i=1:DOF
    switch joints{i}
        case 'ankle'
            jointType{i}='revolute';
        case 'knee'
            jointType{i}='revolute';
        case 'hip'
            jointType{i}='revolute';
        case 'z'
            jointType{i}='prismatic';
        otherwise 
            jointType{i}='revolute';
    end
end

washold=ishold;

for i=1:DOF
    %Plot each joint
    joint=joints{i};
    joint_data=experiment_data.(joint);
    subplot(M,N,i);
    if washold
        hold on;
    else
        hold off;
    end
    t=joint_data.joint_state.Header;
    legend_str={};
    ylabel_str=[];
               
    for j=1:numel(channels)
        channel=channels{j};        
        % Plot
        t=joint_data.joint_state.Header;
        x=joint_data.joint_state.(channel);
        eval(sprintf('h%d=plot(t,x);',j)); 
        hold on;        
        % Hardcoded names for p-joint
        if strcmp(jointType{i},'prismatic')
            switch channel
                case 'Theta'
                    channel='x';
                    ylbl='Position [m]';
                case 'ThetaDot'
                    channel='Velocity [m/s]';
                case 'Torque'
                    channel='Force [N]';
            end       
        elseif strcmp(jointType{i},'revolute')
            switch channel
                case 'Theta'            
                    ylbl='Angle [deg]';
                case 'ThetaDot'
                    ylbl='Angular vel [deg/s]';
                case 'Torque'
                    ylbl='Torque [Nm]';
            end       
        end
        legend_str=[legend_str channel];
        ylabel_str=[ylabel_str ' / ' ylbl];
    end   
    ylabel_str=ylabel_str(3:end); %remove /
    % Show labels and title
    
    title(sprintf('%s joint kinematics',joint));
    xlabel('Time [s]'); ylabel(ylabel_str);
           
    if isfield(experiment_data,'fsm')&& phases
        Topics.plot_phases(experiment_data);
    end
    if ~washold
        hold off;
    end
    
    %%%%%%%%% TODO --> How to change number of h (i.e h1, h2,...) for
    %%%%%%%%% legend properties
%     h=[];n_old=0;
%     n=length(findobj('type','line'))-n_old;
%     for k=1:n
%         eval(sprintf('h=[h h%d];',k));
%     end
%     legend(h,legend_str);
%     h=[];
%     n_old=n;
    
    legend([h1],legend_str)
end

h=gcf;

end



