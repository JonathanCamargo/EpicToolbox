%% Filter dataset (includes outliers,... add more!)
%% HELP:
%{
    This function takes all experiment data and returns it filtered. By default, this
    function filters acceleration and quaternions.
 
    Inputs: [Required] Experiment Data
                
    Output: Filtered Experiment Data

%}
%% Code
function [filtered_data] = filteringData (trial_data, varargin)
    %% TODO add help
       
    p = inputParser;
    f = @(trial_data)isOutlier_value(trial_data);
    p.addOptional('function',f);   
    p.parse(varargin{:});
    
    filter_fnc=p.Results.function;
    filter_accel_fnc = @(trial_data)isOutlier_accel_value(trial_data);
    filter_quaternion_fnc = @(trial_data)isOutlier_quaternion_value(trial_data);
    filter_gyro_fnc = @(trial_data)isOutlier_gyro_value(trial_data);

    filtered_accel = Topics.processTopics(filter_accel_fnc, trial_data, ...
                        {'imu.foot.Accel',...
                        'imu.shank.Accel', ...
                        'imu.thigh.Accel',...
                        'imu.trunk.Accel'});
    filtered_quat=Topics.processTopics(filter_quaternion_fnc, trial_data,...
                    {'imu.foot.Quaternion', ...  
                    'imu.shank.Quaternion',...
                    'imu.thigh.Quaternion', ...
                    'imu.trunk.Quaternion'});
    filtered_gyro=Topics.processTopics(filter_gyro_fnc, trial_data,...
                    {'imu.foot.Gyro', ...  
                    'imu.shank.Gyro',...
                    'imu.thigh.Gyro', ...
                    'imu.trunk.Gyro'});
   filtered_data = combineData(trial_data, filtered_accel,...
                        {'imu.foot.Accel',...
                        'imu.shank.Accel', ...
                        'imu.thigh.Accel',...
                        'imu.trunk.Accel'});
   filtered_data = combineData(filtered_data, filtered_quat,...
                         {'imu.foot.Quaternion', ...  
                    'imu.shank.Quaternion',...
                    'imu.thigh.Quaternion', ...
                    'imu.trunk.Quaternion'});
   filtered_data = combineData(filtered_data, filtered_gyro,...
                         {'imu.foot.Gyro', ...  
                    'imu.shank.Gyro',...
                    'imu.thigh.Gyro', ...
                    'imu.trunk.Gyro'});
                
end

function output = combineData(trial_data, new_data, topics_list)
    output = trial_data;
    for msg_idx = 1:length(topics_list)
        try
            eval(sprintf('output.%s=new_data.%s;',topics_list{msg_idx}, topics_list{msg_idx}));
        catch
             warning('EpicToolbox:topicNotFound','%s eval sprintf N/A, skipping',topics_list{msg_idx});
        end
    end 
end 

function output = isOutlier_accel_value(trial_data, varargin)
%      AList = {'imu.foot.Accel',...
%               'imu.shank.Accel', ...
%               'imu.thigh.Accel',...
%               'imu.trunk.Accel'};
     channelsA = {'X','Y','Z'};
     p = inputParser;
     p.addOptional('max', 1000); % assuming acceptable accel values< 1E3
     p.parse(varargin{:});
     threshold = p.Results.max;

     output = trial_data;
     
         for j=1:numel(channelsA)
            channelA=channelsA{j};
            % find outliers
            threshFilt = abs(output.(channelA)) > threshold;
            % replace outliers by interpolating
            output.(channelA)(threshFilt) = interp1(output.Header(~threshFilt) ,...
                    output.(channelA)(~threshFilt), output.Header(threshFilt));
         end       
end

function output= isOutlier_quaternion_value (trial_data, varargin)
    % Checks each value in Quaternions
    % if value > Threshold, interpolate and replace
    channelsQ = {'X','Y','Z','W'};
    p = inputParser;
    p.addOptional('max', 1.1); % assuming acceptable |quat values| <1.1
    p.parse(varargin{:});
    threshold = p.Results.max;
    
    output = trial_data;
    
    for j=1:numel(channelsQ)
        channelQ=channelsQ{j};
        % find outliers (defined as above threshold)
        threshFilt = abs(output.(channelQ)) > threshold;
        % replace outliers by interpolating
        output.(channelQ)(threshFilt) = interp1(output.Header(~threshFilt), output.(channelQ)(~threshFilt), output.Header(threshFilt));
        
        filt = false(1, length(output.(channelQ)));
        filt(isoutlier(output.(channelQ), 'movmedian', 10)) = true;%find outliers
        output.(channelQ)(filt) = interp1(output.Header(~filt), output.(channelQ)(~filt), output.Header(filt));
    end  
    
    
end

function output = isOutlier_gyro_value(trial_data, varargin)
    channelsA = {'X','Y','Z'};
    p = inputParser;
    p.addOptional('max', 1000); % assuming acceptable accel values< 1E3
    p.parse(varargin{:});
    threshold = p.Results.max;

    output = trial_data;
     
        for j=1:numel(channelsA)
           channelA=channelsA{j};
           % find outliers
           threshFilt = abs(output.(channelA)) > threshold;
           % replace outliers by interpolating
           output.(channelA)(threshFilt) = interp1(output.Header(~threshFilt) ,...
                   output.(channelA)(~threshFilt), output.Header(threshFilt));
        end     
end
