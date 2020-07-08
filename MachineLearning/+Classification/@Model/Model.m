classdef Model < dynamicprops

    properties (Access=public)

        %model; %Internal representation of the model
        %modelOptions; %Options used for construct the model
        %predict;
        isNormalizing;    % Model is self normalizing (i.e. expects arbitrary input and output ranges and scales internaly).
        inputSize;
    end
    
    properties (Access=private)

        %model; %Internal representation of the model
        %modelOptions; %Options used for construct the model
        %predict;
        normalizationParameters_=struct('xmin',[],'xmax',[],'ymin',[],'ymax',[]);
        normalizationReady=false;
    end
    
    
    methods (Access=public)
       
        function obj=Model(varargin)
            % Model(varargin) a model wrapper to organize different common
            % models used for continuous estimation and model's internal
            % parameters.
            % Model(varargin)
            % 'Normalizing' (true) Model is self normalizing (i.e. expects arbitrary input and output ranges and scales internaly).    
            
            p=inputParser();
            p.KeepUnmatched=true;
            parameters={'Normalizing'};
            defaults={true};
            validation={@islogical};
            for i=1:numel(parameters)
                p.addParameter(parameters{i},defaults{i},validation{i});
            end            
            p.parse(varargin{:});
            
            obj.isNormalizing=p.Results.Normalizing;
            obj.inputSize=[];
            %obj.model=struct();
            %obj.modelOptions=struct();
            %obj.predict=@ContinuousEstimation.Model.returnEmpty;
            obj.addprop('modelOptions');
            obj.addprop('model');
            obj.addprop('model_train');
            obj.addprop('model_predict');            
          
        end
        
        function obj=setNormalization(obj,enable,xmin,xmax,ymin,ymax)
            obj.isNormalizing=enable;
            obj.normalizationParameters_.xmin=xmin;
            obj.normalizationParameters_.xmin=xmax;
            obj.normalizationParameters_.ymin=ymin;
            obj.normalizationParameters_.ymin=ymax;      
            obj.normalizationReady=true;
        end
        
        function parameters=getNormalization(obj)
            % Read access to current normalization parameters stored in the
            % model.
            parameters=obj.normalizationParameters_;
        end
        
        function obj=train(obj,X,Y)
            % Pseudo-abstract function train(X,Y)
            % to train the model. Where X and Y are numerical matrices with
            % rows=samples and cols=features.            
            if obj.isNormalizing && ~obj.normalizationReady
                % Compute the normalization using X and Y                                
                xmax=max(X);
                xmin=min(X);                
                obj.normalizationParameters_.xmin=xmin;
                obj.normalizationParameters_.xmax=xmax;                
                obj.normalizationReady=true;
            end
            if obj.isNormalizing
                xmin=obj.normalizationParameters_.xmin;
                xmax=obj.normalizationParameters_.xmax;
                X=2*rescale(X,'InputMin',xmin,'InputMax',xmax)-1; %Range of -1 to 1                
            end
		    z=obj.model_train(obj.model,X,Y);
            obj.model=z;
            obj.inputSize=size(X,2);
            % Overloading subref method?
            %output=obj.predict(S);            
        end
        
        function out=predict(obj,X)
            % Abstract function to run the model and predict
            % out=predict(obj,X)
            
            if obj.isNormalizing && obj.normalizationReady
                xmin=obj.normalizationParameters_.xmin;
                xmax=obj.normalizationParameters_.xmax;
                X=2*rescale(X,'InputMin',xmin,'InputMax',xmax)-1; %Range of -1 to 1   
            end
		    Y=obj.model_predict(obj.model,X);
            out=Y;
            % Overloading subref method?
            %output=obj.predict(S);            
        end
    end
        
    methods (Static)
        [net, validation_meanerror]=trainModel(training_data, output, HiddenLayerSize,Model)
        [testing_meanerror,netOutput]=testModel(testingData, testingOutput, model, obj)        
    end
                      
    
    methods(Static)
       
        %function output=returnEmpty(S)
        %   output=[]; 
        %end
        
    end


	
	
end

