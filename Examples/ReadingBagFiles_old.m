%%
clc;clear;close all;
%% Addpath 
addpath(genpath('..'));
run init();
%% READING ROSBAG FILES:
addpath(genpath('/Users/sheamcmurtry/Dropbox (GaTech)/ROSBAG FILES'))
%% Example 1. Read a single bag file and save experiment data:
rosbag_path=('SAMPLE_DATA/1.bag');
fprintf('Processing %s\n\r',rosbag_path);
experiment=rosbagread(rosbag_path); 
mat_path=('1.mat');
save(mat_path,'-struct','experiment');
% experiment is a structure with the data, you can save 

%% Example 2. Convert all the bag files in a folder to mat files
% This script reads all the *.bag files inside a specific folder and 
% processes the files to produce a corresponding *.mat file.  *.mat files
% are saved in the same folder. This is for convenience of post processing,
% since bag files are slow to be read from matlab.
%folder_path='SAMPLE_DATA/';
folder_path='/home/ossip/Dropbox (GaTech)/ROSBAGFILES/TF03_12_15_17/Treadmill/'
files=dir([folder_path '*.bag']);
for i=1:numel(files)
    file_name=files(i).name;
    fprintf('Processing %s\n\r',file_name);
    rosbag_path=[files(i).folder '/' file_name];
    experiment=rosbagread(rosbag_path);    
    mat_file_name=strrep(file_name,'.bag','.mat');
    mat_path=[files(i).folder '/' mat_file_name];
    save(mat_path,'-struct','experiment');
end

%% Example 3. Extract raw data for all bag and trigno files files from a folder and merge
% This script reads all the *.bag files inside a specific folder and 
% all trigno files from the folder and 
% processes the files to produce a corresponding *.mat file.  *.mat files
% are saved in the same folder. This is for convenience of post processing,
% since bag files are slow to be read from matlab.

folder_path='../TF02_01_16_18/Treadmill/';

files=dir([folder_path '16.bag']);

for i=1:numel(files)
    file_name=files(i).name;
    file_no_extension=file_name(1:end-4);
    trigno_file=[file_no_extension '.trigno'];    
    fprintf('Processing %s\n\r',file_name);
    rosbag_path=[files(i).folder '/' file_name];
    trigno_path=[files(i).folder '/' trigno_file];
    rosbag_data=rosbagread(rosbag_path);    
    
    rosout_agg=rosbag_data.rosout_agg;
    has_record=contains([rosout_agg.Name{:}],'/record');
    record_times=[];
    for j=1:length(has_record)
        if ~has_record(j)
            break;
        end
        record_times=[record_times rosout_agg.Header(j)];
    end
    next_msgtime=rosout_agg.Header(j);
    mean_record_msgs=mean(record_times);
    if abs(next_msgtime-mean_record_msgs)<10E-3 %TOL
        initial_time=record_times(1);
    else
        initial_time=next_msgtime;
    end            
    % Get initial time for trigno in a safe estimation from rosout msgs
            
    if ~exist(trigno_path,'file')
        warning('Trigno file %s does not exist: skipped',trigno_file);
    else
        fprintf('Processing %s\n\r',trigno_file);
        trigno_data=trignoread(trigno_path,'InitialTime',initial_time);        
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
        experiment.(field)=trigno_data.(field);        
    end
    mat_file_name=strrep(file_name,'.bag','.mat');
    mat_path=[files(i).folder '/' mat_file_name];
    save(mat_path,'-struct','experiment');
end

