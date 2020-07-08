function obj=BuildModel(model,varargin)	
% BuildModel(model,ModelOptions)	
% Construct a model object compatible with the ContinuousEstimation architecture
% model can be these options:
% 
% 'feedforwardnet': %TODO EXPLAIN
% 'cascadeforwardnet': 
% 'fitsvm':
% 'TreeBagger':
%
% Name-Value pair Options
% 'ModelOptions': Use to explicitly configure the parameters of the model.
% 'ModelVarargin': Use to directly pass the arguments for the
% model-specific constructor (for advanced users - more flexibility).


narginchk(1,8);
p=inputParser();
p.KeepUnmatched=true;
p.addParameter('ModelOptions',struct());
p.addParameter('ModelVarargin',{});
p.parse(varargin{:});
             

obj=ContinuousEstimation.Model(varargin{:});
obj.modelOptions=p.Results.ModelOptions;
obj.modelVarargin=p.Results.ModelVarargin;

if isempty(obj.modelVarargin)
    useModelVarargin=false;
    
else
    useModelVarargin=true;
    
end
    switch model
    case 'feedforwardnet'
        if ~useModelVarargin            
            HL=fieldExistsOrDefault(obj.modelOptions,'HiddenSizes',[10]);                                    
            model=feedforwardnet(HL);
        else
            model=feedforwardnet(obj.modelVarargin{:});
        end
        % ModelOptions for feedforwardnet:                              
        model.trainParam.showWindow=true; %Hide the nntool        
        obj.model=model;                                
        % Define the train function
        obj.model_train=@(obj,input,output)train(obj.model,input',output');        
        obj.model_predict=@(obj,input,output)(sim(obj.model,input'))'; % Data is always rows(samples)xcols(features)
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

    otherwise % Create an empty model useful for making a custom wrapper on the fly
        error('Model %s not supported',model);

    end
end


function value=fieldExistsOrDefault(structure,fieldname,default)
% 
if contains(fieldnames(structure),fieldname)
   value=structure.fieldname;
else
   value=default; 
end
end