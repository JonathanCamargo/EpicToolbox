%% Filter Outliers
%% HELP:
%{
    This function takes all gait cycles as a cell array and then returns a mask
    representing the gaits that need to be filtered out. By default, this
    function determines an outlier by time, but a function handle can be passed
    in to supply your own filtering criteria as a varargin. Note: The mask
    marks the "outlier" gaits to be filtered out. 
 
    Inputs: [Required] Resampled Gait Cycle 1xG cell array, with each
            signal being N points.
            [Optional] Function handle to a filtering function which returns a
            logical true or false for one single gait cycle. 
                
    Output: 1xG logical array, where a true denotes an outlier. 
%}
%% Code
function [isoutlier_mask] = filtering (all_cycles, varargin)
    %% TODO add help
       
    p = inputParser;
    f = @(trial_data)isOutlier_time(trial_data);
    p.addOptional('function',f);
    p.parse(varargin{:});
    
    filter_fnc=p.Results.function;
    
    isoutlier_mask=Topics.processTrials(filter_fnc,all_cycles);
    isoutlier_mask=cell2mat(isoutlier_mask);
    isoutlier_mask=logical(isoutlier_mask);
end

function output= isOutlier_time (trial_data, varargin)
    % Checks if total trial time is within time range, default 0.5<t<3sec
    %Return logical true for all good signal
    p = inputParser;
    p.addOptional('min', 0.5);
    p.addOptional('max', 3.0);
    p.parse(varargin{:});
    threshold1 = p.Results.min;
    threshold2 = p.Results.max;
    
    end_time=trial_data.knee.joint_state.Header(end);
    start_time=trial_data.knee.joint_state.Header(1);
    total_time=end_time - start_time;
    if(total_time < threshold1 || total_time > threshold2)
        output = true; 
    else
        output = false;
    end
end


% TODO Add functionality to isOutlier such as Peak values of kinematic or
% kinetic data, 