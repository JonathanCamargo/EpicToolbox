%% Download some data
params.subject='AB01';
params.ambulation='Treadmill';
sf_download(params);
%% Add time as Header column for each file
allFiles=sf_fileList('Root','RawMatlab');
% Create output folder structure
dest=allFiles;
src=allFiles;
for i=1:numel(allFiles)
    dest{i}=fullfile('WithHeader',allFiles{i});
    src{i}=fullfile('RawMatlab',allFiles{i});
end
loadRunSave(@addtime,src,'OutputPath',dest,'Parallelize',true);
sf_export2EpicToolbox('WithHeader','Export_EpicToolbox');
%% Plot some of the signals
foundfiles=dir(fullfile('Export_EpicToolbox','Treadmill','AB01','*','*.mat'));
files=join([{foundfiles.folder}',{foundfiles.name}'],filesep());
%% Load just one file
trial=load(files{1});
topics={'EMG','FSR','IMU','GON'};
trial=normalize(trial,topics);
subplot(2,1,1);
Topics.plot_generic(trial,'EMG')
hold on;
Topics.plot_generic(trial,'FSR','channels',{'Toe'})
subplot(2,1,2);
Topics.plot_generic(trial,'IMU')
%% Load multiple trial files
trials=multiLoad(files(1:5));
trials=normalize(trials,topics);
subplot(3,1,1)
Topics.plot_generic(trials{1},'EMG')
subplot(3,1,2)
Topics.plot_generic(trials{2},'IMU')
subplot(3,1,3)
Topics.plot_generic(trials{3},'FSR','channels',{'Start'})
%%
% find the start of the trial
trial=trials{1};
startTime_idx=find(trial.FSR.Start>0,1);
startTime=trial.FSR.Header(startTime_idx);
endTime=trial.FSR.Header(end);
trial=cut(trial,startTime,endTime,topics);
subplot(3,1,1)
Topics.plot_generic(trial,'EMG')
subplot(3,1,2)
Topics.plot_generic(trial,'IMU')
subplot(3,1,3)
Topics.plot_generic(trial,'FSR','channels',{'Start'}); hold on;
Topics.plot_generic(trial,'FSR','channels',{'Heel'})
Topics.plot_generic(trial,'FSR','channels',{'Toe'})
% Find the times of heel contact
heelContacts_idx=([0;diff(trial.FSR.Heel)]>0.5);
heelContactTimes=trial.FSR.Header(heelContacts_idx);

segmentTimes_mat=[heelContactTimes, [heelContactTimes(2:end);1] ];
segmentTimes=splitapply(@(x){x},segmentTimes_mat,[1:length(segmentTimes_mat)]');
segmented=segment(trial,topics,'times',segmentTimes);
%% Plot a segment
trial=segmented{1};
subplot(3,1,1)
Topics.plot_generic(trial,'EMG')
subplot(3,1,2)
Topics.plot_generic(trial,'IMU')
subplot(3,1,3)
Topics.plot_generic(trial,'FSR','channels',{'Start'}); hold on;
Topics.plot_generic(trial,'FSR','channels',{'Heel'})
Topics.plot_generic(trial,'FSR','channels',{'Toe'})


%%                                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out=addtime(content)
    FS=1000; %Hz
    x=content.data{:,:};
    header=content.data.Properties.VariableNames;
    header=['Header',header];
    time=0:1/FS:(size(x,1)-1)/FS;
    x=[time' x];
    data=array2table(x,'VariableNames',header);
    out.data=data;
end
