clear; close all; clc

knee_angle = xlsread('Knee_Data.xlsx','Joint_Angle');
knee_moment = xlsread('Knee_Data.xlsx','Joint_Moment');
knee_power = xlsread('Knee_Data.xlsx','Joint_Power');
ankle_angle = xlsread('Ankle_Data.xlsx','Joint_Angle');
ankle_moment = xlsread('Ankle_Data.xlsx','Joint_Moment');
ankle_power = xlsread('Ankle_Data.xlsx','Joint_Power');

%%
knee_angle_young = struct('gaitCycle', knee_angle(:,1), ...
                'natural', knee_angle(:,3), ...
                'verySlow', knee_angle(:,6), ...
                'slow', knee_angle(:,9), ...
                'medium', knee_angle(:,12), ...
                'fast', knee_angle(:,15), ...
                'stairAscend', knee_angle(:,24), ...
                'stairDescend', knee_angle(:,27));

knee_angle_adult = struct('gaitCycle', knee_angle(:,1), ...
                'natural', knee_angle(:,30), ...
                'verySlow', knee_angle(:,33), ...
                'slow', knee_angle(:,36), ...
                'medium', knee_angle(:,39), ...
                'fast', knee_angle(:,42), ...
                'stairAscend', knee_angle(:,51), ...
                'stairDescend', knee_angle(:,54));

knee_moment_young = struct('gaitCycle', knee_moment(:,1), ...
                'natural', knee_moment(:,3), ...
                'verySlow', knee_moment(:,6), ...
                'slow', knee_moment(:,9), ...
                'medium', knee_moment(:,12), ...
                'fast', knee_moment(:,15), ...
                'stairAscend', knee_moment(:,24), ...
                'stairDescend', knee_moment(:,27));

knee_moment_adult = struct('gaitCycle', knee_moment(:,1), ...
                'natural', knee_moment(:,30), ...
                'verySlow', knee_moment(:,33), ...
                'slow', knee_moment(:,36), ...
                'medium', knee_moment(:,39), ...
                'fast', knee_moment(:,42), ...
                'stairAscend', knee_moment(:,51), ...
                'stairDescend', knee_moment(:,54));

knee_power_young = struct('gaitCycle', knee_power(:,1), ...
                'natural', knee_power(:,3), ...
                'verySlow', knee_power(:,6), ...
                'slow', knee_power(:,9), ...
                'medium', knee_power(:,12), ...
                'fast', knee_power(:,15), ...
                'stairAscend', knee_power(:,24), ...
                'stairDescend', knee_power(:,27));

knee_power_adult = struct('gaitCycle', knee_power(:,1), ...
                'natural', knee_power(:,30), ...
                'verySlow', knee_power(:,33), ...
                'slow', knee_power(:,36), ...
                'medium', knee_power(:,39), ...
                'fast', knee_power(:,42), ...
                'stairAscend', knee_power(:,51), ...
                'stairDescend', knee_power(:,54));

ankle_angle_young = struct('gaitCycle', ankle_angle(:,1), ...
                'natural', ankle_angle(:,3), ...
                'verySlow', ankle_angle(:,6), ...
                'slow', ankle_angle(:,9), ...
                'medium', ankle_angle(:,12), ...
                'fast', ankle_angle(:,15), ...
                'stairAscend', ankle_angle(:,24), ...
                'stairDescend', ankle_angle(:,27));

ankle_angle_adult = struct('gaitCycle', ankle_angle(:,1), ...
                'natural', ankle_angle(:,30), ...
                'verySlow', ankle_angle(:,33), ...
                'slow', ankle_angle(:,36), ...
                'medium', ankle_angle(:,39), ...
                'fast', ankle_angle(:,42), ...
                'stairAscend', ankle_angle(:,51), ...
                'stairDescend', ankle_angle(:,54));

ankle_moment_young = struct('gaitCycle', ankle_moment(:,1), ...
                'natural', ankle_moment(:,3), ...
                'verySlow', ankle_moment(:,6), ...
                'slow', ankle_moment(:,9), ...
                'medium', ankle_moment(:,12), ...
                'fast', ankle_moment(:,15), ...
                'stairAscend', ankle_moment(:,24), ...
                'stairDescend', ankle_moment(:,27));

ankle_moment_adult = struct('gaitCycle', ankle_moment(:,1), ...
                'natural', ankle_moment(:,30), ...
                'verySlow', ankle_moment(:,33), ...
                'slow', ankle_moment(:,36), ...
                'medium', ankle_moment(:,39), ...
                'fast', ankle_moment(:,42), ...
                'stairAscend', ankle_moment(:,51), ...
                'stairDescend', ankle_moment(:,54));

ankle_power_young = struct('gaitCycle', ankle_power(:,1), ...
                'natural', ankle_power(:,3), ...
                'verySlow', ankle_power(:,6), ...
                'slow', ankle_power(:,9), ...
                'medium', ankle_power(:,12), ...
                'fast', ankle_power(:,15), ...
                'stairAscend', ankle_power(:,24), ...
                'stairDescend', ankle_power(:,27));

ankle_power_adult = struct('gaitCycle', ankle_power(:,1), ...
                'natural', ankle_power(:,30), ...
                'verySlow', ankle_power(:,33), ...
                'slow', ankle_power(:,36), ...
                'medium', ankle_power(:,39), ...
                'fast', ankle_power(:,42), ...
                'stairAscend', ankle_power(:,51), ...
                'stairDescend', ankle_power(:,54));

%%              
knee_angle = struct('young', knee_angle_young, 'adult', knee_angle_adult);
knee_moment = struct('young', knee_moment_young, 'adult', knee_moment_adult);
knee_power = struct('young', knee_power_young, 'adult', knee_power_adult);
ankle_angle = struct('young', ankle_angle_young, 'adult', ankle_angle_adult);
ankle_moment = struct('young', ankle_moment_young, 'adult', ankle_moment_adult);
ankle_power = struct('young', ankle_power_young, 'adult', ankle_power_adult);                    

knee = struct('angle',knee_angle,'moment',knee_moment,'power',knee_power);
ankle = struct('angle',ankle_angle,'moment',ankle_moment,'power',ankle_power);

%% RESAMPLING/INTERPOLATING
numPoints = 1000;
ankle_gaitCycle_resampled = linspace(0,1, numPoints)';
knee_gaitCycle_resampled = ankle_gaitCycle_resampled;


knee_angle_young_resampled = struct('gaitCycle', knee_gaitCycle_resampled,...
       'natural',       interp1(knee.angle.young.gaitCycle,knee.angle.young.natural,      knee_gaitCycle_resampled, 'spline', 'extrap'),...
      'verySlow',       interp1(knee.angle.young.gaitCycle,knee.angle.young.verySlow,     knee_gaitCycle_resampled, 'spline', 'extrap'),...
      'slow',           interp1(knee.angle.young.gaitCycle,knee.angle.young.slow,         knee_gaitCycle_resampled, 'spline', 'extrap'), ...
      'medium',         interp1(knee.angle.young.gaitCycle,knee.angle.young.medium,       knee_gaitCycle_resampled, 'spline', 'extrap'), ...
      'fast',           interp1(knee.angle.young.gaitCycle,knee.angle.young.fast,         knee_gaitCycle_resampled, 'spline', 'extrap'), ...
      'stairAscend',    interp1(knee.angle.young.gaitCycle,knee.angle.young.stairAscend,  knee_gaitCycle_resampled, 'spline', 'extrap'), ...
      'stairDescend',   interp1(knee.angle.young.gaitCycle,knee.angle.young.stairDescend, knee_gaitCycle_resampled, 'spline', 'extrap'));

knee_angle_adult_resampled = struct('gaitCycle', knee_gaitCycle_resampled,...
     'natural',         interp1(knee.angle.adult.gaitCycle,knee.angle.adult.natural,      knee_gaitCycle_resampled, 'spline', 'extrap'),...
     'verySlow',        interp1(knee.angle.adult.gaitCycle,knee.angle.adult.verySlow,     knee_gaitCycle_resampled, 'spline', 'extrap'),...
     'slow',            interp1(knee.angle.adult.gaitCycle,knee.angle.adult.slow,         knee_gaitCycle_resampled, 'spline', 'extrap'), ...
     'medium',          interp1(knee.angle.adult.gaitCycle,knee.angle.adult.medium,       knee_gaitCycle_resampled, 'spline', 'extrap'), ...
     'fast',            interp1(knee.angle.adult.gaitCycle,knee.angle.adult.fast,         knee_gaitCycle_resampled, 'spline', 'extrap'), ...
     'stairAscend',     interp1(knee.angle.adult.gaitCycle,knee.angle.adult.stairAscend,  knee_gaitCycle_resampled, 'spline', 'extrap'), ...
     'stairDescend',    interp1(knee.angle.adult.gaitCycle,knee.angle.adult.stairDescend, knee_gaitCycle_resampled, 'spline', 'extrap'));

knee_moment_young_resampled = struct('gaitCycle', knee_gaitCycle_resampled,...
    'natural',          interp1(knee.moment.young.gaitCycle, knee.moment.young.natural,       knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'verySlow',         interp1(knee.moment.young.gaitCycle, knee.moment.young.verySlow,      knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'slow',             interp1(knee.moment.young.gaitCycle, knee.moment.young.slow,          knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'medium',           interp1(knee.moment.young.gaitCycle, knee.moment.young.medium,        knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'fast',             interp1(knee.moment.young.gaitCycle, knee.moment.young.fast,          knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairAscend',      interp1(knee.moment.young.gaitCycle, knee.moment.young.stairAscend,   knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairDescend',     interp1(knee.moment.young.gaitCycle, knee.moment.young.stairDescend,  knee_gaitCycle_resampled, 'spline', 'extrap'));

knee_moment_adult_resampled = struct('gaitCycle', knee_gaitCycle_resampled,...
    'natural',          interp1(knee.moment.adult.gaitCycle, knee.moment.adult.natural,       knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'verySlow',         interp1(knee.moment.adult.gaitCycle, knee.moment.adult.verySlow,      knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'slow',             interp1(knee.moment.adult.gaitCycle, knee.moment.adult.slow,          knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'medium',           interp1(knee.moment.adult.gaitCycle, knee.moment.adult.medium,        knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'fast',             interp1(knee.moment.adult.gaitCycle, knee.moment.adult.fast,          knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairAscend',      interp1(knee.moment.adult.gaitCycle, knee.moment.adult.stairAscend,   knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairDescend',     interp1(knee.moment.adult.gaitCycle, knee.moment.adult.stairDescend,  knee_gaitCycle_resampled, 'spline', 'extrap'));

knee_power_young_resampled = struct('gaitCycle', knee_gaitCycle_resampled,...
    'natural',          interp1(knee.power.young.gaitCycle, knee.power.young.natural,     knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'verySlow',         interp1(knee.power.young.gaitCycle, knee.power.young.verySlow,    knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'slow',             interp1(knee.power.young.gaitCycle, knee.power.young.slow,        knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'medium',           interp1(knee.power.young.gaitCycle, knee.power.young.medium,      knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'fast',             interp1(knee.power.young.gaitCycle, knee.power.young.fast,        knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairAscend',      interp1(knee.power.young.gaitCycle, knee.power.young.stairAscend, knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairDescend',     interp1(knee.power.young.gaitCycle, knee.power.young.stairDescend,knee_gaitCycle_resampled, 'spline', 'extrap'));

knee_power_adult_resampled = struct('gaitCycle', knee_gaitCycle_resampled,...
    'natural',          interp1(knee.power.adult.gaitCycle, knee.power.adult.natural,     knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'verySlow',         interp1(knee.power.adult.gaitCycle, knee.power.adult.verySlow,    knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'slow',             interp1(knee.power.adult.gaitCycle, knee.power.adult.slow,        knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'medium',           interp1(knee.power.adult.gaitCycle, knee.power.adult.medium,      knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'fast',             interp1(knee.power.adult.gaitCycle, knee.power.adult.fast,        knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairAscend',      interp1(knee.power.adult.gaitCycle, knee.power.adult.stairAscend, knee_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairDescend',     interp1(knee.power.adult.gaitCycle, knee.power.adult.stairDescend,knee_gaitCycle_resampled, 'spline', 'extrap'));

ankle_angle_young_resampled = struct('gaitCycle', ankle_gaitCycle_resampled,...
       'natural',       interp1(ankle.angle.young.gaitCycle,ankle.angle.young.natural,      ankle_gaitCycle_resampled, 'spline', 'extrap'),...
      'verySlow',       interp1(ankle.angle.young.gaitCycle,ankle.angle.young.verySlow,     ankle_gaitCycle_resampled, 'spline', 'extrap'),...
      'slow',           interp1(ankle.angle.young.gaitCycle,ankle.angle.young.slow,         ankle_gaitCycle_resampled, 'spline', 'extrap'), ...
      'medium',         interp1(ankle.angle.young.gaitCycle,ankle.angle.young.medium,       ankle_gaitCycle_resampled, 'spline', 'extrap'), ...
      'fast',           interp1(ankle.angle.young.gaitCycle,ankle.angle.young.fast,         ankle_gaitCycle_resampled, 'spline', 'extrap'), ...
      'stairAscend',    interp1(ankle.angle.young.gaitCycle,ankle.angle.young.stairAscend,  ankle_gaitCycle_resampled, 'spline', 'extrap'), ...
      'stairDescend',   interp1(ankle.angle.young.gaitCycle,ankle.angle.young.stairDescend, ankle_gaitCycle_resampled, 'spline', 'extrap'));

ankle_angle_adult_resampled = struct('gaitCycle', ankle_gaitCycle_resampled,...
     'natural',         interp1(ankle.angle.adult.gaitCycle,ankle.angle.adult.natural,      ankle_gaitCycle_resampled, 'spline', 'extrap'),...
     'verySlow',        interp1(ankle.angle.adult.gaitCycle,ankle.angle.adult.verySlow,     ankle_gaitCycle_resampled, 'spline', 'extrap'),...
     'slow',            interp1(ankle.angle.adult.gaitCycle,ankle.angle.adult.slow,         ankle_gaitCycle_resampled, 'spline', 'extrap'), ...
     'medium',          interp1(ankle.angle.adult.gaitCycle,ankle.angle.adult.medium,       ankle_gaitCycle_resampled, 'spline', 'extrap'), ...
     'fast',            interp1(ankle.angle.adult.gaitCycle,ankle.angle.adult.fast,         ankle_gaitCycle_resampled, 'spline', 'extrap'), ...
     'stairAscend',     interp1(ankle.angle.adult.gaitCycle,ankle.angle.adult.stairAscend,  ankle_gaitCycle_resampled, 'spline', 'extrap'), ...
     'stairDescend',    interp1(ankle.angle.adult.gaitCycle,ankle.angle.adult.stairDescend, ankle_gaitCycle_resampled, 'spline', 'extrap'));

ankle_moment_young_resampled = struct('gaitCycle', ankle_gaitCycle_resampled,...
    'natural',          interp1(ankle.moment.young.gaitCycle, ankle.moment.young.natural,       ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'verySlow',         interp1(ankle.moment.young.gaitCycle, ankle.moment.young.verySlow,      ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'slow',             interp1(ankle.moment.young.gaitCycle, ankle.moment.young.slow,          ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'medium',           interp1(ankle.moment.young.gaitCycle, ankle.moment.young.medium,        ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'fast',             interp1(ankle.moment.young.gaitCycle, ankle.moment.young.fast,          ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairAscend',      interp1(ankle.moment.young.gaitCycle, ankle.moment.young.stairAscend,   ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairDescend',     interp1(ankle.moment.young.gaitCycle, ankle.moment.young.stairDescend,  ankle_gaitCycle_resampled, 'spline', 'extrap'));

ankle_moment_adult_resampled = struct('gaitCycle', ankle_gaitCycle_resampled,...
    'natural',          interp1(ankle.moment.adult.gaitCycle, ankle.moment.adult.natural,       ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'verySlow',         interp1(ankle.moment.adult.gaitCycle, ankle.moment.adult.verySlow,      ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'slow',             interp1(ankle.moment.adult.gaitCycle, ankle.moment.adult.slow,          ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'medium',           interp1(ankle.moment.adult.gaitCycle, ankle.moment.adult.medium,        ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'fast',             interp1(ankle.moment.adult.gaitCycle, ankle.moment.adult.fast,          ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairAscend',      interp1(ankle.moment.adult.gaitCycle, ankle.moment.adult.stairAscend,   ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairDescend',     interp1(ankle.moment.adult.gaitCycle, ankle.moment.adult.stairDescend,  ankle_gaitCycle_resampled, 'spline', 'extrap'));

ankle_power_young_resampled = struct('gaitCycle', ankle_gaitCycle_resampled,...
    'natural',          interp1(ankle.power.young.gaitCycle, ankle.power.young.natural,     ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'verySlow',         interp1(ankle.power.young.gaitCycle, ankle.power.young.verySlow,    ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'slow',             interp1(ankle.power.young.gaitCycle, ankle.power.young.slow,        ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'medium',           interp1(ankle.power.young.gaitCycle, ankle.power.young.medium,      ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'fast',             interp1(ankle.power.young.gaitCycle, ankle.power.young.fast,        ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairAscend',      interp1(ankle.power.young.gaitCycle, ankle.power.young.stairAscend, ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairDescend',     interp1(ankle.power.young.gaitCycle, ankle.power.young.stairDescend,ankle_gaitCycle_resampled, 'spline', 'extrap'));

ankle_power_adult_resampled = struct('gaitCycle', ankle_gaitCycle_resampled,...
    'natural',          interp1(ankle.power.adult.gaitCycle, ankle.power.adult.natural,     ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'verySlow',         interp1(ankle.power.adult.gaitCycle, ankle.power.adult.verySlow,    ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'slow',             interp1(ankle.power.adult.gaitCycle, ankle.power.adult.slow,        ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'medium',           interp1(ankle.power.adult.gaitCycle, ankle.power.adult.medium,      ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'fast',             interp1(ankle.power.adult.gaitCycle, ankle.power.adult.fast,        ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairAscend',      interp1(ankle.power.adult.gaitCycle, ankle.power.adult.stairAscend, ankle_gaitCycle_resampled, 'spline', 'extrap'),...
    'stairDescend',     interp1(ankle.power.adult.gaitCycle, ankle.power.adult.stairDescend,ankle_gaitCycle_resampled, 'spline', 'extrap'));

knee_angle_resampled = struct('young', knee_angle_young_resampled, 'adult', knee_angle_adult_resampled);
knee_moment_resampled = struct('young', knee_moment_young_resampled, 'adult', knee_moment_adult_resampled);
knee_power_resampled = struct('young', knee_power_young_resampled, 'adult', knee_power_adult_resampled);
ankle_angle_resampled = struct('young', ankle_angle_young_resampled, 'adult', ankle_angle_adult_resampled);
ankle_moment_resampled = struct('young', ankle_moment_young_resampled, 'adult', ankle_moment_adult_resampled);
ankle_power_resampled = struct('young', ankle_power_young_resampled, 'adult', ankle_power_adult_resampled);                    

knee_resampled = struct('angle',knee_angle_resampled,'moment',knee_moment_resampled,'power',knee_power_resampled);
ankle_resampled = struct('angle',ankle_angle_resampled,'moment',ankle_moment_resampled,'power',ankle_power_resampled);