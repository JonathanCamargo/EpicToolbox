%TODO ADD COMMENTS EXPlAIN
clear all;clc;close all

%%
% JA - joint angle
% JT - joint torque
% JP - joint power
% GRF - ground reaction forces
% This reads in the data from the Excel file

JA_natural=xlsread('Biomechanics Data.xlsx', 'Joint Angles Natural Cadence');
JA_slow=xlsread('Biomechanics Data.xlsx', 'Joint Angles Slow Cadence');
JA_fast=xlsread('Biomechanics Data.xlsx', 'Joint Angles Fast Cadence');
JT_natural=xlsread('Biomechanics Data.xlsx', 'Joint Moment Natural Cadence');
JT_slow=xlsread('Biomechanics Data.xlsx', 'Joint Moment Slow Cadence');
JT_fast=xlsread('Biomechanics Data.xlsx', 'Joint Moment Fast Cadence');
JP_natural=xlsread('Biomechanics Data.xlsx', 'Power Natural Cadence');
JP_slow=xlsread('Biomechanics Data.xlsx', 'Power Slow Cadence');
JP_fast=xlsread('Biomechanics Data.xlsx', 'Power Fast Cadence');
GRF_natural=xlsread('Biomechanics Data.xlsx', 'Ground Reaction Natural Cadence');
GRF_slow=xlsread('Biomechanics Data.xlsx', 'Ground Reaction Slow Cadence');
GRF_fast=xlsread('Biomechanics Data.xlsx', 'Ground Reaction Fast Cadence');
%% RESAMPLING/INTERPOLATING

numPoints=10000;

%% Joint Angle in units of deg
JA_slow_resampled = zeros(numPoints, size(JA_slow,2));
JA_slow_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:7
    JA_slow_resampled(:,i) = interp1(JA_slow(:,1), JA_slow(:,i), JA_slow_resampled(:,1), 'spline', 'extrap');
end

JA_natural_resampled = zeros(numPoints, size(JA_natural,2));
JA_natural_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:7
    JA_natural_resampled(:,i) = interp1(JA_natural(:,1), JA_natural(:,i), JA_natural_resampled(:,1), 'spline', 'extrap');
end

JA_fast_resampled = zeros(numPoints, size(JA_fast,2));
JA_fast_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:7
    JA_fast_resampled(:,i) = interp1(JA_fast(:,1), JA_fast(:,i), JA_fast_resampled(:,1), 'spline', 'extrap');
end

%% Joint Torque in units of (N*m/kg)
JT_slow_resampled = zeros(numPoints, size(JT_slow,2));
JT_slow_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:9
    JT_slow_resampled(:,i) = interp1(JT_slow(:,1), JT_slow(:,i), JT_slow_resampled(:,1), 'spline', 'extrap');
end

JT_natural_resampled = zeros(numPoints, size(JT_natural,2));
JT_natural_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:9
    JT_natural_resampled(:,i) = interp1(JT_natural(:,1), JT_natural(:,i), JT_natural_resampled(:,1), 'spline', 'extrap');
end

JT_fast_resampled = zeros(numPoints, size(JT_fast,2));
JT_fast_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:9
    JT_fast_resampled(:,i) = interp1(JT_fast(:,1), JT_fast(:,i), JT_fast_resampled(:,1), 'spline', 'extrap');
end

%% Joint Power in units of W/kg
JP_slow_resampled = zeros(numPoints, size(JP_slow,2));
JP_slow_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:7
    JP_slow_resampled(:,i) = interp1(JP_slow(:,1), JP_slow(:,i), JP_slow_resampled(:,1), 'spline', 'extrap');
end

JP_natural_resampled = zeros(numPoints, size(JP_natural,2));
JP_natural_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:7
    JP_natural_resampled(:,i) = interp1(JP_natural(:,1), JP_natural(:,i), JP_natural_resampled(:,1), 'spline', 'extrap');
end

JP_fast_resampled = zeros(numPoints, size(JP_fast,2));
JP_fast_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:7
    JP_fast_resampled(:,i) = interp1(JP_fast(:,1), JP_natural(:,i), JP_fast_resampled(:,1), 'spline', 'extrap');
end

%% Ground Reaction Forces in units of N/kg
GRF_slow_resampled = zeros(numPoints, size(GRF_slow,2));
GRF_slow_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:5
    GRF_slow_resampled(:,i) = interp1(GRF_slow(:,1), GRF_slow(:,i), GRF_slow_resampled(:,1), 'spline', 'extrap');
end

GRF_natural_resampled = zeros(numPoints, size(GRF_natural,2));
GRF_natural_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:5
    GRF_natural_resampled(:,i) = interp1(GRF_natural(:,1), GRF_natural(:,i), GRF_natural_resampled(:,1), 'spline', 'extrap');
end

GRF_fast_resampled = zeros(numPoints, size(GRF_fast,2));
GRF_fast_resampled(:,1) = linspace(0,100, numPoints)';
for i=2:5
    GRF_fast_resampled(:,i) = interp1(GRF_fast(:,1), GRF_natural(:,i), GRF_fast_resampled(:,1), 'spline', 'extrap');
end

%% CREATE ARRAYS FROM TABLES

JA_slow = array2table(JA_slow_resampled,...
    'VariableNames',{'Percent_GC','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
JA_natural = array2table(JA_natural_resampled,...
    'VariableNames',{'Percent_GC','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
JA_fast = array2table(JA_fast_resampled,...
    'VariableNames',{'Percent_GC','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
JT_slow = array2table(JT_slow_resampled,...
    'VariableNames',{'Percent_GC','Support_Mean','Support_Std','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
JT_natural = array2table(JT_natural_resampled,...
    'VariableNames',{'Percent_GC','Support_Mean','Support_Std','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
JT_fast = array2table(JT_fast_resampled,...
    'VariableNames',{'Percent_GC','Support_Mean','Support_Std','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
JP_slow = array2table(JP_slow_resampled,...
    'VariableNames',{'Percent_GC','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
JP_natural = array2table(JP_natural_resampled,...
    'VariableNames',{'Percent_GC','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
JP_fast = array2table(JP_fast_resampled,...
    'VariableNames',{'Percent_GC','Hip_Mean','Hip_Std','Knee_Mean','Knee_Std','Ankle_Mean','Ankle_Std'});
GRF_slow = array2table(GRF_slow_resampled,...
    'VariableNames',{'Percent_GC','Vertical_Mean','Vertical_Std','Horizontal_Mean','Horizontal_Std'});
GRF_natural = array2table(GRF_natural_resampled,...
    'VariableNames',{'Percent_GC','Vertical_Mean','Vertical_Std','Horizontal_Mean','Horizontal_Std'});
GRF_fast = array2table(GRF_fast_resampled,...
    'VariableNames',{'Percent_GC','Vertical_Mean','Vertical_Std','Horizontal_Mean','Horizontal_Std'});


