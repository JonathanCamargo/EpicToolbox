classdef Classifier < handle
    %CLASSIFIER A class to classify data into a set of classes
    %Usage
    % 1. Set up a Classifier object using the constructor
    % classifier = Classifier(name_value_pair_options);
    % 2. classifier.classify() - modifies the instance with results
    %
    % see also: Classifier
    
    
    
    properties
        FeatureList=[];
        errorSummary = {}
        labels = {};
        Model = '';
        Folds = [];
    end
    
    methods
        model = trainClassifier(obj, training_data, labels);
        [testing_accuracy, lab_pred, conf]=testClassifier(testing_data, lab_truth, model, obj);
    end
    
    methods
        function obj = Classifier(varargin)
            %CLASSIFIER Construct an instance of this class
            %   Set parameters to those passed in the constructor
            % Options: name value pairs
            % ----------------------------------------------
            %  name    value1/value2/(default)  Description
            % ----------------------------------------------
            % 'Model' | ('lda') |  Type of classifier to use
            % 'Folds'       | (10) |  Number of k-folds
            
            inputs=inputParser;
            Names = {'Model','Folds'};
            Defaults = {'lda', 10};
            % Validations
            %             validStrOrCell=@(x) iscell(x) || ischar(x);
            % Adding Parameter varagin
            for i = 1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});
            varOpts=inputs.Results;
            
            % Get options:
            obj.Model = varOpts.Model;
            obj.Folds = varOpts.Folds;
        end
        
        function [meanAcc, pred, truth, foldInd] = classify(obj, input, labels, trialInds)
        %% Function to train and test a model for input features and labels
        %
        % [meanAcc, pred, truth] = classify(obj, input, labels)
            
            
            %kInds = crossvalind('KFold', labels', 10);
            
            accPerFold = zeros(1, max(trialInds));
            pred = {};
            truth = {};
            foldInd = [];
            for k = 1:max(trialInds)
                fprintf('Testing %s model with %d features: Fold %d of %d...\n', obj.Model, size(input, 2), k, max(trialInds));
                
                trainMask = trialInds ~= k;
                model = obj.trainClassifier(input(trainMask, :), labels(trainMask));
                [accPerFold(k), pred_temp] = obj.testClassifier(input(~trainMask, :), ...
                                             labels(~trainMask), model);
                pred = [pred; pred_temp];
                truth = [truth; labels(~trainMask)];
                foldInd = [foldInd; (zeros(length(pred_temp), 1) + k)];
            end
            meanAcc = mean(accPerFold);
        end
    end
    
    methods (Hidden)
        model = trainDBN(features, labels, varargin); 
        [pred, conf] = testDBN(model, features, varargin);
    end
    
end


