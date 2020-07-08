%% Depicting Data
% Divya Chowbey
% Data from Bovi
%
function plot_Biomechanics(varargin)
    %% load data
    load('ankle.mat');
    load('knee.mat');

    p = inputParser; % create parser object
    % add inputs to scheme
    defaultJoint = 'knee';
    validJoint = {'knee', 'ankle'};
    checkJoint = @(x) any(validatestring(x, validJoint));
    
    defaultMode = 'LW';
    validMode = {'LW', 'SA', 'SD'};
    checkMode = @(x) any(validatestring(x, validMode));
    
    validChannel = {'theta', 'moment', 'power'};
    checkChannel = @(x) any(validatestring(x, validChannel));
    
    
    addRequired(p, 'joint', checkJoint);
    addRequired(p, 'mode', checkMode);
    addRequired(p, 'channel', checkChannel);
    
    p.KeepUnmatched = true; % allow plotBiomechanics to accept additional params
    parse(p,varargin{:});
    
    jointState = p.Results.joint;
    disp(['State: ', p.Results.joint])
    mode = p.Results.mode;
    disp(['Mode: ', p.Results.mode])
    channel = p.Results.channel;
    disp(['Channel: ', p.Results.channel])
   
    figure(1); clf;
switch p.Results.mode
    case 'LW'
        switch p.Results.joint
            case 'knee'
                switch p.Results.channel
                    case 'theta'
                        plot(knee_resampled.angle.adult.gaitCycle, knee_resampled.angle.adult.natural);
                    case 'moment'
                        plot(knee_resampled.moment.adult.gaitCycle, knee_resampled.moment.adult.natural);
                    case 'power'
                        plot(knee_resampled.power.adult.gaitCycle, knee_resampled.power.adult.natural);
                end
            case 'ankle'
                switch p.Results.channel
                    case 'theta'
                        plot(ankle_resampled.angle.adult.gaitCycle, ankle_resampled.angle.adult.natural);                        
                    case 'moment'
                        plot(ankle_resampled.moment.adult.gaitCycle, ankle_resampled.moment.adult.natural); 
                    case 'power'
                        plot(ankle_resampled.power.adult.gaitCycle, ankle_resampled.power.adult.natural); 
                end
        end
    case 'SA'
        switch p.Results.joint
            case 'knee'
                switch p.Results.channel
                    case 'theta'
                        plot(knee_resampled.angle.adult.gaitCycle, knee_resampled.angle.adult.stairAscend); 
                    case 'moment'
                        plot(knee_resampled.moment.adult.gaitCycle, knee_resampled.moment.adult.stairAscend); 
                    case 'power'
                         plot(knee_resampled.power.adult.gaitCycle, knee_resampled.power.adult.stairAscend); 
                end
            case 'ankle'
                switch p.Results.channel
                    case 'theta'
                        plot(ankle_resampled.angle.adult.gaitCycle, ankle_resampled.angle.adult.stairAscend);
                    case 'moment'
                        plot(ankle_resampled.moment.adult.gaitCycle, ankle_resampled.moment.adult.stairAscend); 
                    case 'power'
                        plot(ankle_resampled.power.adult.gaitCycle, ankle_resampled.power.adult.stairAscend); 
                end
        end
    case 'SD'
        switch p.Results.joint
            case 'knee'
                switch p.Results.channel
                    case 'theta'
                        plot(knee_resampled.angle.adult.gaitCycle, knee_resampled.angle.adult.stairDescend); 
                    case 'moment'
                        plot(knee_resampled.moment.adult.gaitCycle, knee_resampled.moment.adult.stairDescend); 
                    case 'power'
                        plot(knee_resampled.power.adult.gaitCycle, knee_resampled.power.adult.stairDescend); 
                end
            case 'ankle'
                switch p.Results.channel
                    case 'theta'
                        plot(ankle_resampled.angle.adult.gaitCycle, ankle_resampled.angle.adult.stairDescend); 
                    case 'moment'
                        plot(ankle_resampled.moment.adult.gaitCycle, ankle_resampled.moment.adult.stairDescend); 
                    case 'power'
                        plot(ankle_resampled.power.adult.gaitCycle, ankle_resampled.power.adult.stairDescend); 
                end
        end
    otherwise
        warning('no mode specified');
end

xlabel('Gait Cycle');
ylabel(p.Results.channel);
title(strcat(p.Results.mode,": ",  p.Results.channel, ' vs. ', 'gait cycle'));

    
end