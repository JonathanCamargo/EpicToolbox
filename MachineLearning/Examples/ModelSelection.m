% displayInfo=false;
% input = 'Treadmill/AB06_input.mat';
% output = 'Treadmill/AB06_output.mat';
%
% input = load(input);
% in=input.alldata;
% output=load(output);
%
% outputNames = {'Speed'};
% %%5
% outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
% for i= 1:length(outputNames)
%     outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
% end
% o=output.alldata(:,outputs);
%
% g = output.alldata.gait;
% %
% hiddenLayers = {[30 30] [40 40] [50 50] [1 1 1] [5 5 5] [10 10 10] [20 20 20] [30 30 30]};
% % [hiddenLayers(hiddenLayer)]
% for hiddenLayer = 1:length(hiddenLayers)
% names = fieldnames(in);
% % feats = 1:width(in);
% feats = [1:22 29:width(in)];
% % feats = 1;
% featureList = names(feats);
% binsize = 100;
% partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
% for i = 1:size(partitions,1)
%     tic
%     estimator=ContinuousParameterEstimator('FeatureList',featureList,...
%         'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',hiddenLayers{hiddenLayer}});
%     ind = g<partitions(i,2) & g > partitions(i,1);
%     disp(['Training = feedforwardnet with '  num2str(hiddenLayers{hiddenLayer}) ' hidden layers']);
%     estimator.estimate(in(ind,:), o(ind,:), displayInfo);
%     disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
%     mean_testing_error(hiddenLayer) = mean(estimator.errorSummary.Mean_Testing_Error);
%     time_to_train(hiddenLayer) = toc;
%     est{hiddenLayer} = estimator;
% end
% end
% Classifier.est = est;
% Classifier.HiddenLayers = hiddenLayers;
% Classifier.info = ['NN trained on all mean features except shank to output '...
%     'walking speed with various hidden layers. 100% of the gait cycle given as input. Error in m/s'];
% Classifier.time_to_train = time_to_train;
% Classifier.mean_testing_error = mean_testing_error;
% save('NN_multi','Classifier')
% % Metrics: http://www.ni.com/white-paper/14860/en/
% % Hysteresis: up and down
% % plot(estimator.outputs.combined_desired,
% % estimator.outputs.combined_net,'o') % --> Input vs output
% % Choose best network and do this (index 6)
% % compare various forms of feature selection using this as metric
%
% % For models should compare accuracy to time to train
%%

% window_sizes = 

clear;clc;
displayInfo=false;
input = 'Stair/AB06_input.mat';
output = 'Stair/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'stairHeight'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'stair height with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_stair_300_50','Classifier')

msg=sprintf('Finished training stair for 300 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
displayInfo=false;
input = 'Ramp/AB06_input.mat';
output = 'Ramp/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'rampIncline'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'ramp incline with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_ramp_300_50','Classifier')

msg=sprintf('Finished training ramp for 300 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
displayInfo=false;
input = 'Treadmill/AB06_input.mat';
output = 'Treadmill/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'Speed'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'ramp incline with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_speed_300_50','Classifier')

msg=sprintf('Finished training speed for 300 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);

%%
clear;clc;
SF_Study_Setup(400)
displayInfo=false;
input = 'Stair/AB06_input.mat';
output = 'Stair/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'stairHeight'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'stair height with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_stair_400_50','Classifier')

msg=sprintf('Finished training stair for 400 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
displayInfo=false;
input = 'Ramp/AB06_input.mat';
output = 'Ramp/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'rampIncline'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'ramp incline with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_ramp_400_50','Classifier')

msg=sprintf('Finished training ramp for 400 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
displayInfo=false;
input = 'Treadmill/AB06_input.mat';
output = 'Treadmill/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'Speed'};

%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'ramp incline with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_speed_400_50','Classifier')

msg=sprintf('Finished training speed for 400 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
SF_Study_Setup(500)
displayInfo=false;
input = 'Stair/AB06_input.mat';
output = 'Stair/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'stairHeight'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'stair height with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_stair_500_50','Classifier')

msg=sprintf('Finished training stair for 500 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
displayInfo=false;
input = 'Ramp/AB06_input.mat';
output = 'Ramp/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'rampIncline'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'ramp incline with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_ramp_500_50','Classifier')

msg=sprintf('Finished training ramp for 500 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
displayInfo=false;
input = 'Treadmill/AB06_input.mat';
output = 'Treadmill/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'Speed'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'ramp incline with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_speed_500_50','Classifier')

msg=sprintf('Finished training speed for 500 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
SF_Study_Setup(1000)
displayInfo=false;
input = 'Stair/AB06_input.mat';
output = 'Stair/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'stairHeight'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'stair height with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_stair_1000_50','Classifier')

msg=sprintf('Finished training stair for 1000 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
displayInfo=false;
input = 'Ramp/AB06_input.mat';
output = 'Ramp/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'rampIncline'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'ramp incline with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_ramp_1000_50','Classifier')

msg=sprintf('Finished training ramp for 1000 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
clear;clc;
displayInfo=false;
input = 'Treadmill/AB06_input.mat';
output = 'Treadmill/AB06_output.mat';

input = load(input);
in=input.alldata;
output=load(output);

outputNames = {'Speed'};
%%5
outputs = boolean(zeros(1,length(output.alldata.Properties.VariableNames)));
for i= 1:length(outputNames)
    outputs = outputs | strcmp(output.alldata.Properties.VariableNames,outputNames{i});
end
o=output.alldata(:,outputs);

g = output.alldata.gait;
%
names = fieldnames(in);

feats = [1:22 29:width(in)];

featureList = names(feats);
binsizes = [100 50 33 25 20 12.5 10 5];
for bin = 1:length(binsizes)
    binsize = binsizes(bin);
    partitions = [[0:binsize:(100-binsize)]' [binsize:binsize:100]'];
    disp(['Training = feedforwardnet with '  num2str(binsize) ' bin size']);
    for i = 1:size(partitions,1)
        tic
        estimator=ContinuousParameterEstimator('FeatureList',featureList,...
            'Folds',10,'Model','feedforwardnet','ModelOptions',{'HiddenNodes',[20 20]});
        ind = g<partitions(i,2) & g > partitions(i,1);
        estimator.estimate(in(ind,:), o(ind,:), displayInfo);
        disp(['Mean error = ' num2str(mean(estimator.errorSummary.Mean_Testing_Error))]);
        mean_testing_error(bin,i) = mean(estimator.errorSummary.Mean_Testing_Error);
        time_to_train(bin,i) = toc;
        est{bin,i} = estimator;
    end
end
Classifier.est = est;
Classifier.HiddenLayers = binsizes;
Classifier.info = ['NN trained on all mean features except shank to output '...
    'ramp incline with parts of the gait cycle given as input. [20 20] hidden layers used Error in m/s'...
    ' Row of result is bin size used, and column is bin index.'];
Classifier.time_to_train = time_to_train;
Classifier.mean_testing_error = mean_testing_error;
save('NN_multi_gait_speed_1000_50','Classifier')

msg=sprintf('Finished training speed for 1000 time history\n');
for i = 1:size(mean_testing_error,1)
    msg = [msg sprintf('mean_tesing_error=')];
    msg=[msg sprintf('%10.5f\t',...
        mean_testing_error(i,:))];
    msg =[msg sprintf('\n')];
end
send_email('noelcs@gatech.edu','Model Trained',msg);
%%
estimator.combineFolds;
% estimator.outputs.combined_net = estimator.filter(estimator.outputs.combined_net, 'kalman', {{0, 0.005}});
estimator.plotNet;