function [mean_values,std_values] = LoadWinterData(mode)
% Returns the winter data for the mode specified by mode
% mode could be:
%    'fast', 'natural', 'slow',...

%complete the comments with code

ALL_WINTER_DATA=load('winter_data.mat');

switch mode
case 'fast'
    %Data is structured where each joint has % GC, angle, torque, power
    % There are mean values as well as standard deviation values for each
    % mode
    
    header=ALL_WINTER_DATA.JA_fast.Percent_GC;
    
    x=ALL_WINTER_DATA.JA_fast.Ankle_Mean;
    d=[header x];
    mean_values.ankle.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.ankle.Properties.VariableUnits={'%GC','deg'};    
    
    x=ALL_WINTER_DATA.JA_fast.Knee_Mean;
    d=[header x];
    mean_values.knee.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.knee.Properties.VariableUnits={'%GC','deg'};
    
    x=ALL_WINTER_DATA.JA_fast.Hip_Mean;
    d=[header x];
    mean_values.hip.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.hip.Properties.VariableUnits={'%GC','deg'};
    
    %Standard deviation:
    x=ALL_WINTER_DATA.JA_fast.Ankle_Std;
    d=[header x];
    std_values.ankle.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.ankle.Properties.VariableUnits={'%GC','deg'};    
    
    x=ALL_WINTER_DATA.JA_fast.Knee_Std;
    d=[header x];
    std_values.knee.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.knee.Properties.VariableUnits={'%GC','deg'};
    
    x=ALL_WINTER_DATA.JA_fast.Hip_Std;
    d=[header x];
    std_values.hip.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.hip.Properties.VariableUnits={'%GC','deg'};
    
    %?x=ALL_WINTER_DATA.GRF_fast.Ankle_Mean;
    %d=[header x];
    %mean_values.ankle=array2table(d,'VariableNames',{'Header','Theta'});
                
case 'slow'
    %Data is structured where each joint has % GC, angle, torque, power
    % There are mean values as well as standard deviation values for each
    % mode    
    
    header=ALL_WINTER_DATA.JA_slow.Percent_GC;
    
    x=ALL_WINTER_DATA.JA_slow.Ankle_Mean;
    d=[header x];
    mean_values.ankle.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.ankle.Properties.VariableUnits={'%GC','deg'};    
    
    x=ALL_WINTER_DATA.JA_slow.Knee_Mean;
    d=[header x];
    mean_values.knee.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.knee.Properties.VariableUnits={'%GC','deg'};
    
    x=ALL_WINTER_DATA.JA_slow.Hip_Mean;
    d=[header x];
    mean_values.hip.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.hip.Properties.VariableUnits={'%GC','deg'};
    
    x=ALL_WINTER_DATA.JT_slow.Ankle_Mean;
    d=[header x];
    mean_values.ankle.torque=array2table(d,'VariableNames',{'Header','Torque'});
    mean_values.ankle.Properties.VariableUnits={'%GC','Nm'};    
    
    x=ALL_WINTER_DATA.JT_slow.Knee_Mean;
    d=[header x];
    mean_values.knee.torque=array2table(d,'VariableNames',{'Header','Torque'});
    mean_values.knee.Properties.VariableUnits={'%GC','Nm'};
    
    %Standard deviation:
    x=ALL_WINTER_DATA.JA_slow.Ankle_Std;
    d=[header x];
    std_values.ankle.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.ankle.Properties.VariableUnits={'%GC','deg'};    
    
    x=ALL_WINTER_DATA.JA_slow.Knee_Std;
    d=[header x];
    std_values.knee.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.knee.Properties.VariableUnits={'%GC','deg'};
    
    x=ALL_WINTER_DATA.JA_slow.Hip_Std;
    d=[header x];
    std_values.hip.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.hip.Properties.VariableUnits={'%GC','deg'};
    
    x=ALL_WINTER_DATA.JT_slow.Ankle_Std;
    d=[header x];
    std_values.ankle.torque=array2table(d,'VariableNames',{'Header','Torque'});
    std_values.ankle.Properties.VariableUnits={'%GC','Nm'};    
    
    x=ALL_WINTER_DATA.JT_slow.Knee_Std;
    d=[header x];
    std_values.knee.torque=array2table(d,'VariableNames',{'Header','Torque'});
    std_values.knee.Properties.VariableUnits={'%GC','Nm'};
    
    %{
    mean_values.ankle.angle=ALL_WINTER_DATA.JA_slow.Ankle_Mean;
    mean_values.ankle.torque=ALL_WINTER_DATA.JT_slow.Ankle_Mean;
    mean_values.ankle.power=ALL_WINTER_DATA.JP_slow.Ankle_Mean;
    
    mean_values.knee.angle=ALL_WINTER_DATA.JA_slow.Knee_Mean;
    mean_values.knee.torque=ALL_WINTER_DATA.JT_slow.Knee_Mean;
    mean_values.knee.power=ALL_WINTER_DATA.JP_slow.Knee_Mean;
    
    mean_values.hip.angle=ALL_WINTER_DATA.JA_slow.Hip_Mean;
    mean_values.hip.torque=ALL_WINTER_DATA.JT_slow.Hip_Mean;
    mean_values.hip.power=ALL_WINTER_DATA.JP_slow.Hip_Mean;
    
    mean_values.grf.vertical=ALL_WINTER_DATA.GRF_slow.Vertical_Mean;
    mean_values.grf.horizontal=ALL_WINTER_DATA.GRF_slow.Horizontal_Mean;
    
    std_values.ankle.angle=ALL_WINTER_DATA.JA_slow.Ankle_Std;
    std_values.ankle.torque=ALL_WINTER_DATA.JT_slow.Ankle_Std;
    std_values.ankle.power=ALL_WINTER_DATA.JP_slow.Ankle_Std;
    
    std_values.knee.angle=ALL_WINTER_DATA.JA_slow.Knee_Std;
    std_values.knee.torque=ALL_WINTER_DATA.JT_slow.Knee_Std;
    std_values.knee.power=ALL_WINTER_DATA.JP_slow.Knee_Std;
    
    std_values.hip.angle=ALL_WINTER_DATA.JA_slow.Hip_Std;
    std_values.hip.torque=ALL_WINTER_DATA.JT_slow.Hip_Std;
    std_values.hip.power=ALL_WINTER_DATA.JP_slow.Hip_Std;
    
    std_values.grf.vertical=ALL_WINTER_DATA.GRF_slow.Vertical_Std;
    std_values.grf.horizontal=ALL_WINTER_DATA.GRF_slow.Horizontal_Std;
    %}
    
case 'natural'
    %Data is structured where each joint has % GC, angle, torque, power
    % There are mean values as well as standard deviation values for each
    % mode
    
    header=ALL_WINTER_DATA.JA_natural.Percent_GC;
    
    x=ALL_WINTER_DATA.JA_natural.Ankle_Mean;
    d=[header x];
    mean_values.ankle.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.ankle.Properties.VariableUnits={'%GC','deg'};    
    
    x=ALL_WINTER_DATA.JA_natural.Knee_Mean;
    d=[header x];
    mean_values.knee.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.knee.Properties.VariableUnits={'%GC','deg'};
     
    x=ALL_WINTER_DATA.JT_natural.Hip_Mean;
    d=[header x];
    mean_values.hip.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    mean_values.hip.Properties.VariableUnits={'%GC','deg'};
    
    x=ALL_WINTER_DATA.JT_natural.Ankle_Mean;
    d=[header x];
    mean_values.ankle.torque=array2table(d,'VariableNames',{'Header','Torque'});
    mean_values.ankle.Properties.VariableUnits={'%GC','Nm'};    
    
    x=ALL_WINTER_DATA.JT_natural.Knee_Mean;
    d=[header x];
    mean_values.knee.torque=array2table(d,'VariableNames',{'Header','Torque'});
    mean_values.knee.Properties.VariableUnits={'%GC','Nm'};
    
    %Standard deviation:
    x=ALL_WINTER_DATA.JA_natural.Ankle_Std;
    d=[header x];
    std_values.ankle.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.ankle.Properties.VariableUnits={'%GC','deg'};    
    
    x=ALL_WINTER_DATA.JA_natural.Knee_Std;
    d=[header x];
    std_values.knee.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.knee.Properties.VariableUnits={'%GC','deg'};
       
    x=ALL_WINTER_DATA.JA_natural.Hip_Std;
    d=[header x];
    std_values.hip.joint_state=array2table(d,'VariableNames',{'Header','Theta'});
    std_values.hip.Properties.VariableUnits={'%GC','deg'};
    
    x=ALL_WINTER_DATA.JT_natural.Ankle_Std;
    d=[header x];
    std_values.ankle.torque=array2table(d,'VariableNames',{'Header','Torque'});
    std_values.ankle.Properties.VariableUnits={'%GC','Nm'};    
    
    x=ALL_WINTER_DATA.JT_natural.Knee_Std;
    d=[header x];
    std_values.knee.torque=array2table(d,'VariableNames',{'Header','Torque'});
    std_values.knee.Properties.VariableUnits={'%GC','Nm'};
    %{
    mean_values.ankle.angle=ALL_WINTER_DATA.JA_natural.Ankle_Mean;
    mean_values.ankle.torque=ALL_WINTER_DATA.JT_natural.Ankle_Mean;
    mean_values.ankle.power=ALL_WINTER_DATA.JP_natural.Ankle_Mean;
    
    mean_values.knee.angle=ALL_WINTER_DATA.JA_natural.Knee_Mean;
    mean_values.knee.torque=ALL_WINTER_DATA.JT_natural.Knee_Mean;
    mean_values.knee.power=ALL_WINTER_DATA.JP_natural.Knee_Mean;
    
    mean_values.hip.angle=ALL_WINTER_DATA.JA_natural.Hip_Mean;
    mean_values.hip.torque=ALL_WINTER_DATA.JT_natural.Hip_Mean;
    mean_values.hip.power=ALL_WINTER_DATA.JP_natural.Hip_Mean;
    
    mean_values.grf.vertical=ALL_WINTER_DATA.GRF_natural.Vertical_Mean;
    mean_values.grf.horizontal=ALL_WINTER_DATA.GRF_natural.Horizontal_Mean;
    
    std_values.ankle.angle=ALL_WINTER_DATA.JA_natural.Ankle_Std;
    std_values.ankle.torque=ALL_WINTER_DATA.JT_natural.Ankle_Std;
    std_values.ankle.power=ALL_WINTER_DATA.JP_natural.Ankle_Std;
    
    std_values.knee.angle=ALL_WINTER_DATA.JA_natural.Knee_Std;
    std_values.knee.torque=ALL_WINTER_DATA.JT_natural.Knee_Std;
    std_values.knee.power=ALL_WINTER_DATA.JP_natural.Knee_Std;
    
    std_values.hip.angle=ALL_WINTER_DATA.JA_natural.Hip_Std;
    std_values.hip.torque=ALL_WINTER_DATA.JT_natural.Hip_Std;
    std_values.hip.power=ALL_WINTER_DATA.JP_natural.Hip_Std;
    
    std_values.grf.vertical=ALL_WINTER_DATA.GRF_natural.Vertical_Std;
    std_values.grf.horizontal=ALL_WINTER_DATA.GRF_natural.Horizontal_Std;
    %}
end

end

