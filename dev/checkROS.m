function rosCheck = checkROS(rootDir, varargin)
% Update Conditions files of all trials with logicals vectors for the
% length of the trial which are true when the data across all channels is
% good and false otherwise.
%
% INPUT:
%   - rootDir - path to sf2018 (or more generally the study to process)
% OUTPUT:
%   - rosCheck - struct with all logical vectors per trial and channel
%   Also updates all Condition Files
%
% OPTIONAL INPUTS:
%   - toPlot (bool) - only for debugging check settings
%   - toLog (bool) - output final log to command window
%   - zeroThres (default 0.00001) - magnitude of diff(diff(data)) below which we consider it a gap
%   - gapSize (default 50) - permitted minimum length of data error (0.25 s)
%   - splitUsable (0-1) - percent of usable data for that split to be usable 
%   - trialUsable (0-1) - percent of usable sensorSplits for that trial to be usable
%   - modeUsable (0-1) - percent of trials in a Mode for that Mode to be usable
%   - modeTUsable (0-1) - percent of trials in a ModeT for that ModeT to be usable

%% Params / Thresholds
validScalar=@(x) isnumeric(x) && isscalar(x);
validBool=@(x) islogical(x);
p = inputParser;
p.addParameter('toPlot',false,validBool);
p.addParameter('toLog',true,validBool);
p.addParameter('zeroThres',0.00001,validScalar);
p.addParameter('gapSize',50,validScalar);
p.addParameter('splitUsable',0.8,validScalar);
p.addParameter('trialUsable',0.875,validScalar);
p.addParameter('modeUsable',0.8,validScalar);
p.addParameter('modeTUsable',0.8,validScalar);
p.parse(varargin{:});

toPlot = p.Results.toPlot;
toLog = p.Results.toLog;

zeroThres = p.Results.zeroThres;
gapSize = p.Results.gapSize;

NUM_CHANNELS = 24; % 4 imus * 2 data streams (gyro/accel) * 3 (xyz)
sensorSplits = 1; % 1 (all combined) 4 (separated per imu) 8 (separated to accel/gyro) 24 (separated to xyz)
splitUsable = p.Results.splitUsable; % percent of usable data for that split to be usable
trialUsable = p.Results.trialUsable; % percent of usable sensorSplits for that trial to be usable
modeUsable = p.Results.modeUsable; % percent of trials in a Mode for that Mode to be usable
modeTUsable = p.Results.modeTUsable; % percent of trials in a ModeT for that ModeT to be usable

%% File Import Params
SUBJECTS=dir([rootDir filesep 'treadmill/imu/']); % assuming all modes exported (same subjects for each mode)
DATE = '*';
MODE={'levelground','ramp','stair','treadmill'};
modeT = {{'levelground_cw_slow', 'levelground_cw_normal', 'levelground_cw_fast', 'levelground_ccw_slow', 'levelground_ccw_normal', 'levelground_ccw_fast'}, ...
    {'ramp_1_r','ramp_1_l','ramp_2_r','ramp_2_l','ramp_3_r','ramp_3_l','ramp_4_r','ramp_4_l','ramp_5_r','ramp_5_l','ramp_6_r','ramp_6_l'}, ...
    {'stair_1_r','stair_1_l','stair_2_r','stair_2_l','stair_3_r','stair_3_l','stair_4_r','stair_4_l'}, ...
    {'treadmill'}};
SENSOR='imu';
fname='*.mat';

%% checkROS Algorithm
rosCheck = struct(); % struct to store sensor and gap index information
for s=3:length(SUBJECTS)
    for m=1:length(MODE)
        for t=1:length(modeT{m})
            str = fullfile(rootDir,MODE{m},SENSOR,SUBJECTS(s).name,DATE,[modeT{m}{t} fname]);
            files = matchFiles(str);
            
            for f=1:length(files)
                rosFile = files{f};
                condFile = strrep(files{f},'imu','conditions');
                [~,name] = fileparts(rosFile);
                disp(['Processing: ' SUBJECTS(s).name ' | ' name])
                
                ros = load(rosFile);
                T = table();
                time = ros.data{:,1};
                T = [T, table(time,'VariableNames',{'Header'})];
                
                if strcmp(MODE{m},'treadmill')
                    cond = load(condFile);
                    nonIdle = ones(size(time));
                else
                    try
                        cond = load(condFile);
                        nonIdle = ~strcmp('idle',cond.labels.Label);
                    catch
                        break;
                    end
                end
                
                if toPlot
                    h = figure(1);
                    tg = uitabgroup; % tabgroup
                end
                
                for i = 2:width(ros.data)
                    data = ros.data{:,i};
                    if toPlot
                        thistab = uitab(tg,'Title',ros.data.Properties.VariableNames{i}); % build i_th tab
                        axes('Parent',thistab); % somewhere to plot
                        plot(time,data);
                    end
                    
                    % Combined Gap and Straight line (capture loc + width)
                    checkLog = [0; abs(diff(diff(data))) < zeroThres; 0];
                    [~,L,W,~] = findpeaks(checkLog,'MinPeakWidth',gapSize); %min size for contiguous "bad" data
                    checkLog = zeros(length(data),1);
                    for l=1:length(L)
                        checkLog((L(l)):(L(l)+W(l))) = 1;
                    end
                    checkLog = ~(checkLog & nonIdle);
                    T = [T, table(checkLog,'VariableNames',ros.data.Properties.VariableNames(i))];
                end
                cond.isgoodROS = mean(T{:,2:end},2) == 1;
                save(condFile,'-struct','cond');
                rosCheck.(SUBJECTS(s).name).(MODE{m}).(modeT{m}{t}).(name).isgood = T;
                rosCheck.(SUBJECTS(s).name).(MODE{m}).(modeT{m}{t}).(name).nonIdleLen = sum(nonIdle);
            end
        end
    end
end

%% Logging
if toLog
    SUB = fieldnames(rosCheck);
    ModeSUB = array2table(zeros(length(SUB)+1,length(MODE)),'VariableNames',MODE,'RowNames',[SUB; 'sum']);
    ModeTSUB = array2table(zeros(length(SUB)+1,length(horzcat(modeT{:}))),'VariableNames',horzcat(modeT{:}),'RowNames',[SUB; 'sum']);
    
    for s=1:length(SUB)
        MODE = fieldnames(rosCheck.(SUB{s}));
        for m=1:length(MODE)
            MODE_T = fieldnames(rosCheck.(SUB{s}).(MODE{m}));
            goodModeTs = zeros(1,length(MODE_T));
            for mt=1:length(MODE_T)
                TRIALS = fieldnames(rosCheck.(SUB{s}).(MODE{m}).(MODE_T{mt}));
                goodTrials = zeros(1,length(TRIALS));
                for t=1:length(TRIALS)
                    isgood = rosCheck.(SUB{s}).(MODE{m}).(MODE_T{mt}).(TRIALS{t}).isgood;
                    nonIdleLen = rosCheck.(SUB{s}).(MODE{m}).(MODE_T{mt}).(TRIALS{t}).nonIdleLen;
                    goodSplits = zeros(1,sensorSplits);
                    for i=1:sensorSplits
                        inds = 1+[((i-1)*NUM_CHANNELS/sensorSplits+1):i*NUM_CHANNELS/sensorSplits];
                        log = mean(isgood{:,inds},2) == 1;
                        if ((sum(log)/nonIdleLen) >= splitUsable)
                            goodSplits(i) = 1;
                        end
                    end
                    if(sum(goodSplits)/length(goodSplits) >= trialUsable)
                        goodTrials(t) = 1;
                    end
                end
                ModeTSUB.(MODE_T{mt})(s) = sum(goodTrials)/length(goodTrials);
                if(sum(goodTrials)/length(goodTrials) > modeUsable)
                    goodModeTs(mt) = 1;
                end
            end
            ModeSUB.(MODE{m})(s) = sum(goodModeTs)/length(goodModeTs);
        end
    end
    ModeSUB{end,:} = sum(ModeSUB{:,:} > modeUsable)
    ModeTSUB{end,:} = sum(ModeTSUB{:,:} > modeTUsable)
end
end



