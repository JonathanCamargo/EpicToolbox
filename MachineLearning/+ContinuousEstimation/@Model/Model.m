classdef Model < dynamicprops & matlab.mixin.Copyable

    properties (Access=public)

        %model; %Internal representation of the model        
        %predict;
        isNormalizing;    % Model is self normalizing (i.e. expects arbitrary input and output ranges and scales internaly).    
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
            %obj.model=struct();
            %obj.modelOptions=struct();
            %obj.predict=@ContinuousEstimation.Model.returnEmpty;
            p=obj.addprop('modelOptions');
            p.NonCopyable = false;
            p=obj.addprop('modelVarargin');
            p.NonCopyable = false;
            p=obj.addprop('model');
            p.NonCopyable = false;
            p=obj.addprop('model_train');
            p.NonCopyable = false;
            p=obj.addprop('model_predict');            
            p.NonCopyable = false;
          
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
                xmax=max(X);ymax=max(Y);
                xmin=min(X);ymin=min(Y);                
                obj.normalizationParameters_.xmin=xmin;
                obj.normalizationParameters_.xmax=xmax;
                obj.normalizationParameters_.ymin=ymin;
                obj.normalizationParameters_.ymax=ymax;
                obj.normalizationReady=true;
            end
            if obj.isNormalizing
                xmin=obj.normalizationParameters_.xmin;
                xmax=obj.normalizationParameters_.xmax;
                ymin=obj.normalizationParameters_.ymin;
                ymax=obj.normalizationParameters_.ymax;
                X=2*rescale(X,'InputMin',xmin,'InputMax',xmax)-1; %Range of -1 to 1
                Y=2*rescale(Y,'InputMin',ymin,'InputMax',ymax)-1; %Range of -1 to 1                                            
            end
		    z=obj.model_train(obj,X,Y);
            obj.model=z;
            % Overloading subref method?
            %output=obj.predict(S);            
        end
        
        function out=predict(obj,X)
            % Abstract function to run the model and predict
            % out=predict(obj,X)
            
            if obj.isNormalizing && obj.normalizationReady
                xmin=obj.normalizationParameters_.xmin;
                xmax=obj.normalizationParameters_.xmax;
                ymin=obj.normalizationParameters_.ymin;
                ymax=obj.normalizationParameters_.ymax;                
                X=2*rescale(X,'InputMin',xmin,'InputMax',xmax)-1; %Range of -1 to 1   
            end
		    Y=obj.model_predict(obj,X);
            if obj.isNormalizing && obj.normalizationReady
                Y=(Y+1)/2.0; % Set in 0-1 range
                Y=Y.*(ymax-ymin)+ymin; 
            end            
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

