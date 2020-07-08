function obj=BuildModel(model,varargin)	
% BuildModel(model,ModelOptions)	
% Construct a model object compatible with the ContinuousEstimation architecture
% model can be these options:
% 
% 'feedforwardnet': %TODO EXPLAIN
% 'cascadeforwardnet': 
% 'fitsvm':
% 'TreeBagger':

narginchk(1,8);
p=inputParser();
p.KeepUnmatched=true;
p.addParameter('ModelOptions',struct());
p.parse(varargin{:});
             

obj = Classification.Model(varargin{:});
obj.modelOptions=p.Results.ModelOptions;

    switch model
    case 'feedforwardnet'
        HL = obj.modelOptions.HiddenSizes; % TODO FIX       
        model = feedforwardnet(HL);
        model.trainParam.showWindow=true; %Hide the nntool
        %obj.addprop('model');
        obj.model=model;                                
        obj.model_train=@(input,output)train(obj.model,input',output');        
        obj.model_predict=@(input,output)(sim(obj.model,input'))'; % Data is always rows(samples)xcols(features)
        %model=train(model, training_data', output');
        %ypred=model(training_data');
        %validation_meanerror=ContinuousParameterEstimator.errorMetric(output, ypred');
    case 'cascadeforwardnet'
        HL = obj.ModelOptions;
        model = cascadeforwardnet(HL);
        model.trainParam.showWindow=false; %Hide the nntool
        obj.model=model;
        %model=train(model, training_data', output');
        %ypred=model(training_data');
        %validation_meanerror=ContinuousParameterEstimator.errorMetric(output, ypred');
    case 'rsvm'
        obj.model = 'rsvm';
        obj.train=@(X,Y)fitrsvm(X,Y);
        %fitrsvm(training_data, output);
        %ypred= predict(model,training_data)';
        %validation_meanerror=ContinuousParameterEstimator.errorMetric(output, ypred');
    case 'TreeBagger'
        obj.model = 'TreeBagger';
        %model = TreeBagger(4,training_data,output); % FIX HARDCODE
        %ypred= predict(model,training_data)';
        %ypred = cellfun(@(s) str2double(s), ypred)';
        %validation_meanerror=ContinuousParameterEstimator.errorMetric(output, ypred);
    case 'lda'
        obj.model = 'lda';
        obj.model_train = @(obj,X,Y)fitcdiscr(X,Y);
        obj.model_predict = @(obj,X) predict(obj,X);
    otherwise % Create an empty model useful for making a custom wrapper on the fly
        error('Model %s not supported',model);

    end
end

