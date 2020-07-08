%% 
clc;clear;close all;

%TODO (Shae,Krishan): please split the examples in this script to multiple mfiles in the examples folder.
%similar to the ReadingBagFiles.m examples. Let me know if what functions are failing or
%should change. Thanks!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% Getting started:
%%% This Toolbox is meant to be used as a regular matlab toolbox.
%%% this means that you should add the toolbox to your matlab path
%%% i.e. don't run your working scripts from the Toolbox directory.
%%% 
%%%  Feel free to contribute by expanding the toolbox with more functionality or examples. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This script will guide you through the main functionality that this toolbox offers

%% SET UP
% You can add the toolbox to your path permanently with matlab setpath
% Optionally you can use addpath(genpath(folder_path));
% Example: to your scripts.
addpath(genpath('~/home/somefolder/EpicToolbox'));

%% READING ROSBAG FILES
% Examples about reading bags and converting them to mat files.
run ReadingBagFiles.m;

%% Plots
% Examples about 
addpath(genpath('/Users/sheamcmurtry/Dropbox (GaTech)/ROSBAG FILES/'))
addpath(genpath('~smcmurtry3/EpicToolbox'));
%% test with new code segment and normalize
rosbag_path=('SAMPLE_DATA/5.mat');
experiment_data=load(rosbag_path);
experiment_data=timeshift(experiment_data,'auto',Topics.internal);
warning off;
segmented=segment(experiment_data);
mask=filtering(segmented);
filtered=segmented(~mask);
normalized=normalize(filtered);
interpolated=interpolate(normalized,0:0.001:1);
[meanvals,std_vals,maxvals,minvals]=average(interpolated);
warning on;
figure(2)
subplot(2,1,1);
joint='knee';
shadedErrorBar(meanvals.(joint).joint_state.Header,meanvals.(joint).joint_state.Theta,std_vals.(joint).joint_state.Theta,'b');
subplot(2,1,2);
joint='ankle';
shadedErrorBar(meanvals.(joint).joint_state.Header,meanvals.(joint).joint_state.Theta,std_vals.(joint).joint_state.Theta,'b');




%% Example: segmented by cycles and normalize
% Read the struct with raw data
rosbag_path=('SAMPLE_DATA/5.mat');
experiment_data=load(rosbag_path);
% Segment the data by cycles
segmented=segment_cycles(experiment_data);
% Normalize
normalized=normalize(segmented);

%% Example: Filter 
% TODO example
% Read the struct with raw data
rosbag_path=('SAMPLE_DATA/1.mat');
experiment_data=load(rosbag_path);
% Segment the data by cycles
segmented=segment_cycles(experiment_data);
%Filtering
mask=filtering(segmented);
filtered=segmented(mask);
% Normalize
normalized=normalize(filtered);
%%
%% Example : Plots
% Plot kinematics
Topics.plot(normalized{1},'kinematics');

%% Example : Resampling
resampled=resampling(normalized,1000);

%% Example: Resampling Plots
for i=1:length(resampled)
    figure(1)
    Topics.plot(resampled{i},'kinematics');
    figure(2)
    Topics.plot(resampled{i},'torques');
    figure(3)
end

%% Example: Averaging Signal

[averaged, std_signal] = averaging(resampled);

%% Sepperate 
%%Plotting Averaged Signal for verification
close all;
% for i=1:length(resampled)
%     figure(1)
%     hold on;
%     plot(resampled{i}.knee.joint_state.Header, resampled{i}.knee.joint_state.Theta, 'r');
%     figure(2)
%     hold on;
%     plot(resampled{i}.ankle.joint_state.Header, resampled{i}.ankle.joint_state.Theta, 'r');
% end

figure(1)
plot(averaged{1}.knee.joint_state.Header, averaged{1}.knee.joint_state.Theta, 'r', 'LineWidth', 2);
hold on
plot(minus1std{1}.knee.joint_state.Header, minus1std{1}.knee.joint_state.Theta, 'k', 'LineWidth', 1);
hold on
plot(plus1std{1}.knee.joint_state.Header, plus1std{1}.knee.joint_state.Theta, 'k', 'LineWidth', 1);

figure(2)
plot(averaged{1}.ankle.joint_state.Header, averaged{1}.ankle.joint_state.Theta, 'b', 'LineWidth', 2);
hold on
plot(minus1std{1}.ankle.joint_state.Header, minus1std{1}.ankle.joint_state.Theta, 'k', 'LineWidth', 1);
hold on
plot(plus1std{1}.ankle.joint_state.Header, plus1std{1}.ankle.joint_state.Theta, 'k', 'LineWidth', 1);

%% Shaded Error Bar
close all;clear all;clc;
% Read the struct with raw data
rosbag_path=('SAMPLE_DATA/16.mat');
experiment_data=load(rosbag_path);
% Segment the data by cycles
segmented=segment_cycles(experiment_data);
%Filtering
mask=filtering(segmented);
filtered=segmented(mask);
% Normalize
normalized=normalize(filtered);
% Resample
resampled=resampling(normalized,1000);
% Average
[averaged, std_signal] = averaging(resampled);

x=linspace(0,100,size(averaged{1}.ankle.joint_state.Theta,1));

figure('Name','Ankle Theta')
shadedErrorBar(x,averaged{1}.ankle.joint_state.Theta,std_signal{1}.ankle.joint_state.Theta,'r')
xlabel('% Gait Cycle')
ylabel('Ankle Theta')
figure('Name','Knee Theta')
shadedErrorBar(x,averaged{1}.knee.joint_state.Theta,std_signal{1}.knee.joint_state.Theta,'r')
xlabel('% Gait Cycle')
ylabel('Knee Theta')
figure('Name','Ankle Torque')
shadedErrorBar(x,averaged{1}.ankle.torque_setpoint.Torque_,std_signal{1}.ankle.torque_setpoint.Torque_,'b')
xlabel('% Gait Cycle')
ylabel('Ankle Torque')
figure('Name','Knee Torque')
shadedErrorBar(x,averaged{1}.knee.torque_setpoint.Torque_,std_signal{1}.knee.torque_setpoint.Torque_,'b')
xlabel('% Gait Cycle')
ylabel('Knee Torque')

% figure
% shadedErrorBar(x,averaged{1}.imu.foot.Euler.Pitch,std_signal{1}.imu.foot.Euler.Pitch,'b')
% hold on
% shadedErrorBar(x,averaged{1}.imu.foot.Euler.Yaw,std_signal{1}.imu.foot.Euler.Yaw,'g')
% shadedErrorBar(x,averaged{1}.imu.foot.Euler.Roll,std_signal{1}.imu.foot.Euler.Roll,'r')
% legend('Pitch', 'Yaw', 'Roll')
% title('Foot IMU')
% 
% figure
% shadedErrorBar(x,averaged{1}.imu.shank.Euler.Pitch,std_signal{1}.imu.shank.Euler.Pitch,'b')
% hold on
% shadedErrorBar(x,averaged{1}.imu.shank.Euler.Yaw,std_signal{1}.imu.shank.Euler.Yaw,'g')
% shadedErrorBar(x,averaged{1}.imu.shank.Euler.Roll,std_signal{1}.imu.shank.Euler.Roll,'r')
% legend('Pitch', 'Yaw', 'Roll')
% title('Shank IMU')
% 
% figure
% shadedErrorBar(x,averaged{1}.imu.thigh.Euler.Pitch,std_signal{1}.imu.thigh.Euler.Pitch,'b')
% hold on
% shadedErrorBar(x,averaged{1}.imu.thigh.Euler.Yaw,std_signal{1}.imu.thigh.Euler.Yaw,'g')
% shadedErrorBar(x,averaged{1}.imu.thigh.Euler.Roll,std_signal{1}.imu.thigh.Euler.Roll,'r')
% legend('Pitch', 'Yaw', 'Roll')
% title('Thigh IMU')
% 
% figure
% shadedErrorBar(x,averaged{1}.Foot.ACC.X,std_signal{1}.Foot.ACC.x,'b')
% hold on
% shadedErrorBar(x,averaged{1}.Foot.ACC.Y,std_signal{1}.Foot.ACC.y,'g')
% shadedErrorBar(x,averaged{1}.Foot.ACC.Z,std_signal{1}.Foot.ACC.z,'r')
% legend('Acc x', 'Acc y', 'Acc z')
% title('Trigno IMU')
%%
%% Plot Able-Bodied Data and Transfemoral Amputee Data
clear;;clc;
load('winter_data.mat')
%load('TF03_12_15_17_Treadmill_8.mat')

% Read the struct with raw data
rosbag_path=('../TF02_12_12_17/Treadmill/1p5mph_3.mat');
experiment_data=load(rosbag_path);
% Segment the data by cycles
segmented=segment_cycles(experiment_data);
%Filtering
mask=filtering(segmented);
filtered=segmented(mask);
% Normalize
normalized=normalize(filtered);
% Resample
resampled=resampling(normalized,1000);
% Average
[averaged, std_signal] = averaging(resampled);

x=linspace(0,100,size(averaged{1}.ankle.joint_state.Theta,1));

q=linspace(0,100,size(JA_natural,1));
% q1=linspace(0,100,size(averaged{1}.ankle.joint_state.Theta,1))
% q2=linspace(0,100,size(averaged{1}.ankle.joint_state.Theta,1))
% q3=linspace(0,100,size(averaged{1}.ankle.joint_state.Theta,1))
i=8;
W1=102.06;
W2=99.79;
W3=74.84;

% figure('Name','Ankle Theta')
subplot(2,2,1)
shadedErrorBar(q,JA_slow.Ankle_Mean,JA_slow.Ankle_Std,'g')
hold on
plot(x, averaged{1}.ankle.joint_state.Theta, 'b');
% plot(x, resampled{i}.ankle.joint_state.Theta, 'b');
hold off
xlabel('% Gait Cycle')
ylabel('Ankle Theta')
legend('Winter', 'TF03')
title('Ankle Theta')

subplot(2,2,2)
% figure('Name','Knee Theta')
shadedErrorBar(q,JA_slow.Knee_Mean,JA_slow.Knee_Std,'g')
hold on
plot(x, averaged{1}.knee.joint_state.Theta, 'b')
% plot(x, resampled{i}.knee.joint_state.Theta, 'b')
hold off
xlabel('% Gait Cycle')
ylabel('Knee Theta')
legend('Winter','TF03')
title('Knee Theta')

subplot(2,2,3)
% figure('Name','Ankle Torque')
shadedErrorBar(q,-JT_slow.Ankle_Mean,-JT_slow.Ankle_Std,'g')
hold on
plot(x, averaged{1}.ankle.torque_setpoint.Torque_/W2, 'b');
% plot(x, resampled{i}.ankle.torque_setpoint.Torque_/W1, 'b');
hold off
xlabel('% Gait Cycle')
ylabel('Ankle Torque')
legend('Winter', 'TF03')
title('Ankle Torque')

subplot(2,2,4)
% figure('Name','Knee Torque')
shadedErrorBar(q,-JT_slow.Knee_Mean,-JT_slow.Knee_Std,'g')
hold on
plot(x, averaged{1}.knee.torque_setpoint.Torque_/W2, 'b')
% plot(x, resampled{i}.knee.torque_setpoint.Torque_/W1, 'b')
hold off
xlabel('% Gait Cycle')
ylabel('Knee Torque')
legend('Winter','TF03')
title('Knee Torque')

%% Plot Winter Data and ALL TF01-03 Data
clear;close all;clc;

load('winter_data.mat')
load('TF01.mat')
load('TF02.mat')
load('TF03.mat')

x1=linspace(0,100,size(TF01_averaged{1}.ankle.joint_state.Theta,1));
x2=linspace(0,100,size(TF02_averaged{1}.ankle.joint_state.Theta,1));
x3=linspace(0,100,size(TF03_averaged{1}.ankle.joint_state.Theta,1));
q=linspace(0,100,size(JA_natural,1));

W1=102.06;
W2=99.79;
W3=74.84;

h=zeros(4,1);
g=zeros(3,1);

figure('Name','Ankle Theta')
% subplot(2,2,1)
h=shadedErrorBar(q,JA_slow.Ankle_Mean,JA_slow.Ankle_Std,'g');
hold on
g(1)=plot(x1, TF01_resampled{8}.ankle.joint_state.Theta, 'b', 'LineWidth' , 2);
g(2)=plot(x2, TF02_averaged{1}.ankle.joint_state.Theta, 'r', 'LineWidth' , 2);
g(3)=plot(x3, TF03_averaged{1}.ankle.joint_state.Theta, 'm', 'LineWidth' , 2);
hold off
xlabel('% Gait Cycle')
ylabel('Ankle Theta')
g=[g(1) g(2) g(3) h.mainLine];
legend(g,'TF01', 'TF02', 'TF03', 'Winter' ,'Location', 'southeast')
title('Ankle Angle (deg)')
xt = get(gca);
set(gca, 'FontSize', 16)

figure('Name','Knee Theta')
% subplot(2,2,2)
h=shadedErrorBar(q,JA_slow.Knee_Mean,JA_slow.Knee_Std,'g');
hold on
g(1)=plot(x1, TF01_resampled{8}.knee.joint_state.Theta, 'b', 'LineWidth' , 2);
g(2)=plot(x2, TF02_averaged{1}.knee.joint_state.Theta, 'r', 'LineWidth' , 2);
g(3)=plot(x3, TF03_averaged{1}.knee.joint_state.Theta, 'm', 'LineWidth' , 2);
hold off
xlabel('% Gait Cycle')
ylabel('Knee Theta')
g=[g(1) g(2) g(3) h.mainLine];
legend(g,'TF01', 'TF02', 'TF03', 'Winter','Location', 'southeast')
title('Knee Angle (deg)')
xt = get(gca);
set(gca, 'FontSize', 16)

figure('Name','Ankle Torque')
% subplot(2,2,3)
h=shadedErrorBar(q,-JT_slow.Ankle_Mean,-JT_slow.Ankle_Std,'g');
hold on
g(1)=plot(x1, TF01_resampled{8}.ankle.torque_setpoint.Torque_/W1, 'b','LineWidth' , 2);
g(2)=plot(x2, TF02_averaged{1}.ankle.torque_setpoint.Torque_/W2, 'r', 'LineWidth' , 2);
g(3)=plot(x3, TF03_averaged{1}.ankle.torque_setpoint.Torque_/W3, 'm', 'LineWidth' , 2);
hold off
xlabel('% Gait Cycle')
ylabel('Ankle Torque')
g=[g(1) g(2) g(3) h.mainLine];
legend(g,'TF01', 'TF02', 'TF03', 'Winter','Location', 'southeast')
title('Ankle Torque (N*m/kg)')
xt = get(gca);
set(gca, 'FontSize', 16)

figure('Name','Knee Torque')
% subplot(2,2,4)
h=shadedErrorBar(q,-JT_slow.Knee_Mean,-JT_slow.Knee_Std,'g');
hold on
g(1)=plot(x1, TF01_resampled{8}.knee.torque_setpoint.Torque_/W1, 'b', 'LineWidth' , 2);
g(2)=plot(x2, TF02_averaged{1}.knee.torque_setpoint.Torque_/W2, 'r', 'LineWidth' , 2);
g(3)=plot(x3, TF03_averaged{1}.knee.torque_setpoint.Torque_/W3, 'm', 'LineWidth' , 2);
hold off
xlabel('% Gait Cycle')
ylabel('Knee Torque')
g=[g(1) g(2) g(3) h.mainLine];
legend(g,'TF01', 'TF02', 'TF03', 'Winter','Location', 'southeast')
title('Knee Torque (N*m/kg)')
xt = get(gca);
set(gca, 'FontSize', 16)
%% WALKING SPEEDS
clear;close all;clc;
load('winter_data.mat')
q=linspace(0,100,size(JA_natural,1));
W=99.79;

% Read the struct with raw data
for i=1:5

file_number=10+i;

rosbag_path=sprintf('../TF02_01_16_18/Treadmill/%d.mat',file_number);

experiment_data=load(rosbag_path);
% Segment the data by cycles
segmented=segment_cycles(experiment_data);
%Filtering
mask=filtering(segmented);
filtered=segmented(mask);
% Normalize
normalized=normalize(filtered);
% Resample
resampled=resampling(normalized,1000);
% Average
[averaged, std_signal] = averaging(resampled);

x=linspace(0,100,size(averaged{1}.ankle.joint_state.Theta,1));

subplot(2,2,1)
plot(x,averaged{1}.ankle.joint_state.Theta,'r', 'LineWidth', 2)
hold on
plot(q,JA_slow.Ankle_Mean,'b', 'LineWidth', 2)
plot(q,JA_natural.Ankle_Mean,'g', 'LineWidth', 2)
plot(q,JA_fast.Ankle_Mean,'m', 'LineWidth', 2)
xlabel('% Gait Cycle', 'FontSize', 24)
ylabel('Ankle Theta', 'FontSize', 24)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 22)


subplot(2,2,2)
plot(x,averaged{1}.knee.joint_state.Theta,'r', 'LineWidth', 2)
hold on
plot(q,JA_slow.Knee_Mean,'b', 'LineWidth', 2)
plot(q,JA_natural.Knee_Mean,'g', 'LineWidth', 2)
plot(q,JA_fast.Knee_Mean,'m', 'LineWidth', 2)
xlabel('% Gait Cycle', 'FontSize', 24)
ylabel('Knee Theta', 'FontSize', 24)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 22)

subplot(2,2,3)
plot(x,averaged{1}.ankle.torque_setpoint.Torque_/W,'r', 'LineWidth', 2)
hold on
plot(q,-JT_slow.Ankle_Mean,'b', 'LineWidth', 2)
plot(q,-JT_natural.Ankle_Mean,'g', 'LineWidth', 2)
plot(q,-JT_fast.Ankle_Mean,'m', 'LineWidth', 2)
xlabel('% Gait Cycle', 'FontSize', 24)
ylabel('Ankle Torque', 'FontSize', 24)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 22)


subplot(2,2,4)
plot(x,averaged{1}.knee.torque_setpoint.Torque_/W,'r', 'LineWidth', 2)
hold on
plot(q,-JT_slow.Knee_Mean,'b', 'LineWidth', 2)
plot(q,-JT_natural.Knee_Mean,'g', 'LineWidth', 2)
plot(q,-JT_fast.Knee_Mean,'m', 'LineWidth', 2)
xlabel('% Gait Cycle', 'FontSize', 24)
ylabel('Knee Torque', 'FontSize', 24)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 22)

drawnow
pause(1)


end
%% Example: extract raw data from a rosbag file
rosbag_path=('../TF02_01_16_18/Treadmill/10.trigno');
fprintf('Processing %s\n\r',rosbag_path);
experiment=trignoread(rosbag_path); 
% experiment is a structure with the data, you can save 

%% Example: extract raw data for all bag and trigno files files from a folder and merge
% This script reads all the *.bag files inside a specific folder and 
% all trigno files from the folder and 
% processes the files to produce a corresponding *.mat file.  *.mat files
% are saved in the same folder. This is for convenience of post processing,
% since bag files are slow to be read from matlab.

% folder_path='/home/kbhakta/Dropbox (GaTech)/ROSBAG FILES/TF02_01_16_18/Treadmill/';
% folder_path='/home/kbhakta/Dropbox (GaTech)/ROSBAG FILES/TF01_02_07_18/';
folder_path='/home/kbhakta/Dropbox (GaTech)/Research Stuff/PapersForPublications/ASME/MATLAB/data/';


files=dir([folder_path '0.bag']);

for i=1:numel(files)
    file_name=files(i).name;
    file_no_extension=file_name(1:end-4);
    trigno_file=[file_no_extension '.trigno'];    
    fprintf('Processing %s\n\r',file_name);
    rosbag_path=[files(i).folder '/' file_name];
    trigno_path=[files(i).folder '/' trigno_file];
    rosbag_data=rosbagread(rosbag_path);    
    
    %Find minimum time accross all Topics
    mintime=minTime(rosbag_data);
    initial_trigno_time=mintime;
    if ~exist(trigno_path,'file')
        warning('Trigno file %s does not exist: skipped',trigno_file);
    else
        fprintf('Processing %s\n\r',trigno_file);
        trigno_data=trignoread(trigno_path,'InitialTime',initial_trigno_time);        
    end
    %Merge trigno_data with rosbag_data
    rosbag_fields=fields(rosbag_data);
    for field_idx=1:length(rosbag_fields)
       field=rosbag_fields{field_idx};
       experiment.(field)=rosbag_data.(field);        
    end
    trigno_fields=fields(trigno_data);
    for field_idx=1:length(trigno_fields)
        field=trigno_fields{field_idx};
        experiment.delsys.(field)=trigno_data.(field);        
    end
    mat_file_name=strrep(file_name,'.bag','.mat');
    mat_path=[files(i).folder '/' mat_file_name];
    save(mat_path,'-struct','experiment');
end

%% ROSBAG READ ONLY FUNCTION
% Example: extract raw data for all bag and trigno files files from a folder and merge
% This script reads all the *.bag files inside a specific folder and 
% all trigno files from the folder and 
% processes the files to produce a corresponding *.mat file.  *.mat files
% are saved in the same folder. This is for convenience of post processing,
% since bag files are slow to be read from matlab.

folder_path='/home/kbhakta/Dropbox (GaTech)/Research Stuff/Tuning/TF/TF02_02_20_2018/';
% folder_path='/home/kbhakta/Dropbox (GaTech)/ROSBAG FILES/Benchtop_04_08_18/';
% folder_path='/home/kbhakta/Dropbox (GaTech)/Research Stuff/PapersForPublications/ASME/MATLAB/data/';
% folder_path='/home/kbhakta/Dropbox (GaTech)/VIP_Prosthetic/Experiment Data/AB01_01_27_18/Treadmill/';
% folder_path='/home/kbhakta/Dropbox (GaTech)/VIP_Prosthetic/Experiment Data/FINAL/AB02/';

files=dir([folder_path '*.bag']);

for i=1:numel(files)
    file_name=files(i).name;
    file_no_extension=file_name(1:end-4);
    fprintf('Processing %s\n\r',file_name);
    rosbag_path=[files(i).folder '/' file_name];
    rosbag_data=rosbagread(rosbag_path);  
    
    rosbag_fields=fields(rosbag_data);
    for field_idx=1:length(rosbag_fields)
       field=rosbag_fields{field_idx};
       experiment.(field)=rosbag_data.(field);        
    end
    
    mat_file_name=strrep(file_name,'.bag','.mat');
    mat_path=[files(i).folder '/' mat_file_name];
    save(mat_path,'-struct','experiment');
end



