classdef ContinuousParameterEstimator < handle
    %CONTINUOUSPARAMETERESTIMATOR A class to estimate continuous walking parameters
    %Usage
    % 1. Set up a ContinuousParameterEstimator object using the constructor
    % estimator = ContinuousParameterEstimator(name_value_pair_options);
    % 2. estimator.estimate() - modifies the instance with results
    %
    % see also: ContinuousParameterEstimator, estimate    
    properties
        Folds=[];
        HiddenNodes=[];
        FeatureList=[];
        errorSummary = {};
        outputs = {};
        bestModel = {};
        Model = '';
        ModelOptions = {};
    end
    
    methods (Static)
        [net, validation_meanerror]=trainModel(training_data, output, HiddenLayerSize,Model)
        [testing_meanerror,netOutput]=testModel(testingData, testingOutput, model, obj)
        error = errorMetric(ytrain, ypred);
    end
    
    methods
        function obj = ContinuousParameterEstimator(varargin)
            %CONTINUOUSPARAMETERESTIMATOR Construct an instance of this class
            %   Set extraction methods to those passed in the constructor
            % Options: name value pairs
            % ----------------------------------------------
            %  name           (default)           Description
            % ----------------------------------------------
            % 'FeatureList' | ([])               |  List of features to use
            % 'Model'       | ('feedforwardnet') |  Type of model to train
            % 'ModelOptions'| ({})               |  Options to use like number of hidden layers
            % 'Folds'       | (10)               |  Number of k-folds
            %
            % see also: estimate
            
            inputs=inputParser;
            Names = {'FeatureList','Folds','Model','ModelOptions'};
            Defaults = {'*', [], 10, 'feedforwardnet',{}};
            % Adding Parameter varagin
            for i = 1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});
            varOpts=inputs.Results;
            
            % Get options:
            obj.FeatureList=varOpts.FeatureList;
            obj.Folds = varOpts.Folds;
            obj.Model = varOpts.Model;
            obj.ModelOptions = varOpts.ModelOptions;
            
        end
        
        function estimate(obj, input, output, varargin)
            %estimate trains and tests model and saves info internally
            % Options: name value pairs
            % -----------------------------------------------------------
            %  name           (default)           Description
            % -----------------------------------------------------------
            % 'displayInfo'       | (false)    |  DisplayInfo?
            % 'randomFoldIndeces' | (~random~) |  Indeces to use for folding
	        %
            %ESTIMATE Estimate walking data
            % estimate(input,output,display_folds)
            
            inputs=inputParser;
            Names = {'displayInfo','randomFoldIndeces'};
            Defaults = {false,randi(obj.Folds, 1, height(input))};
            for i = 1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});
            display_folds=inputs.Results.displayInfo;
            randomFoldIndeces=inputs.Results.randomFoldIndeces;
            
            concatenateNames = @(tag_cell_array) cell2mat(cellfun(@(tags) [tags ', '],...
                tag_cell_array, 'UniformOutput', 0));

            % Get summary table ready
            resultsHeader = {'FoldNumber','ValidationError','TestingError'};
            summary = zeros(obj.Folds, length(resultsHeader));
            
            % Find features to use
            [~, indeces] = intersect(input.Properties.VariableNames,obj.FeatureList);
            if display_folds
                fprintf(['  Estimating ' concatenateNames(output.Properties.VariableNames) ...
                    'with ' num2str(length(indeces)) ' features.\n']);
            end
            max_error=Inf;
            foldI = [];
            
            % Iterate over folds
            for j=1:obj.Folds
                if display_folds
                    fprintf(['   Fold ' num2str(j) '/' num2str(obj.Folds) '\n']);
                end
               
                foldIndeces = randomFoldIndeces == j;
                foldI = [foldI; repmat(j, length(find(foldIndeces)), 1)];
                % Make subsets of the data
                trainingOutput = output{~foldIndeces, :};
                testingOutput = output{foldIndeces, :};
                trainingData = input{~foldIndeces, indeces};
                testingData = input{foldIndeces,indeces};
                if display_folds
                    fprintf('    Training\n')
                end
                [model, validation_meanerror]=obj.trainModel(trainingData, trainingOutput, obj);
                
                if display_folds
                    fprintf('    Testing\n')
                end
                
                [testing_meanerror,netOutput_j]=obj.testModel(testingData, testingOutput, model, obj);
                if testing_meanerror < max_error
                    obj.bestModel = model;
                    max_error = testing_meanerror;
                end
                summary(j,:)=[j,validation_meanerror,testing_meanerror];
                desiredOutput{j} = testingOutput;
                netOutput{j} = netOutput_j';
                %                     details{j}=details_j;
            end
            obj.errorSummary = array2table(summary,'VariableNames',{'Fold', 'Mean_Validation_Error', 'Mean_Testing_Error'});
            obj.outputs.desired = desiredOutput;
            obj.outputs.net = netOutput;
            [obj.outputs.des_timeSeries, obj.outputs.net_timeSeries] = resetFiltering(obj);
            [~,b] = sort(foldI);
            obj.outputs.net_timeSeries = obj.outputs.net_timeSeries(b);
            obj.outputs.des_timeSeries = obj.outputs.des_timeSeries(b);
        end
        
        function [desired, net] = resetFiltering(obj)
            % Combine output folds into one dataset
            % Clear previous data
            if any(contains(fieldnames(obj.outputs), 'combined_net'))
                obj.outputs=rmfield(obj.outputs,'combined_net');
            end
            if any(contains(fieldnames(obj.outputs),'combined_desired'))
                obj.outputs=rmfield(obj.outputs,'combined_desired');
            end
            net = [];
            desired = [];
            for i = 1:obj.Folds
                desired = [desired; obj.outputs.desired{i}];
                net = [net; obj.outputs.net{i}];
            end
            [obj.outputs.combined_desired, indeces] = sort(desired);
            for i = 1:size(net,2)
                obj.outputs.combined_net(:,i) = net(indeces(:,i),i);
            end
            
        end
        
        function filtered = filter(obj,data,filterType, filterOptions)
            % filter combined output
            switch filterType
                case 'kalman'
                    kalman(data);
                case 'adaptiveKalman'
                    adaptiveKalman(data);
                case 'MA'
                    MA(data);
                otherwise
                    fprintf('  No filter method used for data.\n');
            end
            function kalman(data)
                for j = 1:size(data,2)
                    mu_p = filterOptions{j}{1};
                    sigma_p = filterOptions{j}{2};
                    ypred = data(:,j);
                    
%                     ypred = [repmat(ypred(1), 20, 1); ypred];
                    
                    i = 21;
                    % Prior Gaussian
                    mu_prev = mean(ypred((i-20):(i-1)));
                    sigma_prev = std(ypred((i-20):(i-1)));
                    
                    for i = 21:length(ypred)
                        % Current Time Measurement
                        y_k = ypred(i);
                        sigma_k = std(ypred((i-19):i));
                        
                        [mu_prev,sigma_prev] = kf(mu_p,sigma_p , mu_prev,sigma_prev, y_k,sigma_k);
                        estimate(i) = mu_prev;
                    end
                    filtered(:,j) = estimate';
                end
            end
            
            function adaptiveKalman(data)
                for j = 1:size(data,2)
                    mu_p = filterOptions{j}{1};
                    sigma_p1 = filterOptions{j}{2};
                    sigma_p2 = filterOptions{j}{3};
                    thresh = filterOptions{j}{4};
                    ypred = data(:,j);
                    
                    i = 21;
                    % Prior Gaussian
                    mu_prev = mean(ypred((i-20):(i-1)));
                    sigma_prev = std(ypred((i-20):(i-1)));
                    
                    for i = 21:length(ypred)
                        % Current Time Measurement
                        y_k = ypred(i);
                        sigma_k = std(ypred((i-19):i));
                        if sigma_k > thresh
                            sigma_p = sigma_p1;
                        else
                            sigma_p = sigma_p2;
                        end
                        
                        [mu_prev,sigma_prev] = kf(mu_p,sigma_p , mu_prev,sigma_prev, y_k,sigma_k);
                        estimate(i) = mu_prev;
                    end
                    filtered(:,j) = estimate';
                end
            end
            
            function [mu,sigma] = kf(mu_p,sigma_p,mu_prev,sigma_prev,mu_curr,sigma_curr)
                % KALMAN  single variable kalman filter for current time
                %   inputs: Model Guassian
                %           - mu_p - Dynamic model mean
                %           - sigma_p - Dynamic model std deviation
                %           Prior Guassian
                %           - mu_prev - Previous time mean
                %           - sigma_prev - Previous time std. deviation
                %           Current Time Measurement
                %           - mu_curr - current measurement mean
                %           - sigma_curr - current measurement std. deviation
                %   output: mu - kalman filter estimate for current time
                %           sigma - kalman filter std. deviation for current time
                
                % Time Prediction Update: Convolution w/ Model Gaussian
                mu_c = mu_prev + mu_p;
                sigma_c = sqrt(sigma_prev^2 + sigma_p^2);
                
                % Measurement Update: Multpilication with Convolved Gaussian
                mu = (mu_c*sigma_curr^2 + mu_curr*sigma_c^2)/(sigma_curr^2 + sigma_c^2);
                sigma = sqrt(1/(1/sigma_curr^2+1/sigma_c^2));
            end
            
            
            function MA(data)
                filtered = filter(ones(1,filterOptions{1})/filterOptions{1}, ...
                    1, data);
            end
        end
        
        function optimalKF(obj)
            obj.resetFiltering;
            options = optimoptions('fmincon','Display','off');
            x=fmincon(@(x) obj.errorMetric(obj.filter(obj.outputs.combined_net,...
                'kalman', {{0,x}}),obj.outputs.combined_desired),0.1,[],[],[],[],0,2,[],options);
            obj.outputs.combined_net=obj.filter(obj.outputs.combined_net,'kalman',{{0 x(1)}});
        end
        
        
        function plotNet(obj,varargin)
            % plot the neural network
            inputs=inputParser;
            Names = {'TimeSeries','SplitMetric'};
            Defaults = {false,false};
            for i = 1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});
            varOpts=inputs.Results;
            % Get options:
            for i = 1:size(obj.outputs.combined_desired,2)
                h=figure(i);clf;
                hold on
                y = obj.outputs.combined_net(:,i);
                x = (1:length(y))/20;
                plot(x,y,'LineWidth',2.5)
                plot(x,obj.outputs.combined_desired(:,i),'LineWidth',1.5)
                set(h, 'WindowStyle', 'Docked');
                set(gca,'FontSize',20);
                axis([min(x) max(x) min(y)-max(y)/10 max(y)+max(y)/10])
                xlabel('Time [seconds]','interpreter','latex');
                ylabel('Stair Height [in]','interpreter','latex');
                legend('Network Output','Desired Output','interpreter','latex');
                set(gca,'TickLabelInterpreter', 'latex');
                set(gca,'FontSize',40)
                set(gca,'linewidth',4)
                grid on
            end
            if varOpts.TimeSeries
                h=figure(i+1);clf;
                hold on
                y = obj.outputs.des_timeSeries(:,i);
                x = (1:length(y))/1000;
                plot(x,y,'LineWidth',1.5)
                plot(x,obj.outputs.net_timeSeries(:,i),'LineWidth',1.5)
                set(h, 'WindowStyle', 'Docked');
                set(gca,'FontSize',20);
                xlabel('Time');
                ylabel('Desired Output');
                legend('Network Output','Desired Output');
                grid on
            end
        end
    end
end

