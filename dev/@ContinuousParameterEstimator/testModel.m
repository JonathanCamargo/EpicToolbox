function [testing_meanerror,ypred]=testModel(testing_data, testing_output, model, obj)
%% TESTModel
%
%   TESTModel() takes testing data, desired testing output, and a model
%   and outputs the error of the NN when used to estimate the
%   desired output from the data input
%   a single .mat file
%
%   This function returns testing mean error, the prediction of the neural
%   network, and any relevant details.
%
%   See also ESTIMATE

switch obj.Model
    case 'feedforwardnet'
        ypred = model(testing_data');
        testing_meanerror = ContinuousParameterEstimator.errorMetric(testing_output,ypred');
    case 'cascadeforwardnet'
        ypred = model(testing_data');
        testing_meanerror = ContinuousParameterEstimator.errorMetric(testing_output,ypred');
    case 'fitsvm'
        ypred = predict(model,testing_data)';
        testing_meanerror = ContinuousParameterEstimator.errorMetric(testing_output,ypred');
    case 'TreeBagger'
        ypred = predict(model,testing_data)';
        ypred = cellfun(@(s) str2double(s), ypred);
        testing_meanerror = ContinuousParameterEstimator.errorMetric(testing_output,ypred');
end

end