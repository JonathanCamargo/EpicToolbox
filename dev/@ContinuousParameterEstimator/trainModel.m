function [model, validation_meanerror] = trainModel(training_data, output, obj)
%% trainModel(training_data, output, obj)
%
%   trainModel takes training data, desired training output, and information
%   about the model to run and outputs the error of the model when used to estimate the
%   desired output from the data input
%
%   This function returns validation mean error, and the trained network
%
%   See also ESTIMATE, TRAINNN

%% Configurations
% Default unless defined in estimationOptions

switch obj.Model
    case 'feedforwardnet'
        HL = obj.ModelOptions{2}; % TODO FIX
        model = feedforwardnet(HL);
        model.trainParam.showWindow=false; %Hide the nntool
        model=train(model, training_data', output');
        ypred=model(training_data');
        validation_meanerror=ContinuousParameterEstimator.errorMetric(output, ypred');
    case 'cascadeforwardnet'
        HL = obj.ModelOptions{2};
        model = cascadeforwardnet(HL);
        model.trainParam.showWindow=false; %Hide the nntool
        model=train(model, training_data', output');
        ypred=model(training_data');
        validation_meanerror=ContinuousParameterEstimator.errorMetric(output, ypred');
    case 'fitsvm'
        model = fitrsvm(training_data, output);
        ypred= predict(model,training_data)';
        validation_meanerror=ContinuousParameterEstimator.errorMetric(output, ypred');
    case 'TreeBagger'
        model = TreeBagger(4,training_data,output); % FIX HARDCODE
        ypred= predict(model,training_data)';
        ypred = cellfun(@(s) str2double(s), ypred)';
        validation_meanerror=ContinuousParameterEstimator.errorMetric(output, ypred);
end

end
