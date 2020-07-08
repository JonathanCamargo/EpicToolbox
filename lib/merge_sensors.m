function TABLE=merge_sensors(data_structure)
% Merges all the sensor data to a single table
% i.e. from a.EMG a.IMU a.OTHERSENSOR
%      to TABLE
sensors=fields(data_structure);
TOTAL={};
for sensor_idx=1:length(sensors)    
    sensor=sensors{sensor_idx};
    X=data_structure.(sensor);
    for i=1:length(X.Properties.VariableNames)
        X.Properties.VariableNames{i}=[sensor '_' X.Properties.VariableNames{i}];
    end
    TOTAL=[TOTAL X];
end
    TABLE=TOTAL; 
end