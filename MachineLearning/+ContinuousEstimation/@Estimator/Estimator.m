classdef Estimator < dynamicprops
    %Estimator A class to estimate continuous walking parameters
    %Usage
    % 1. Set up a Estimator object using the constructor
    % estimator = Estimator(name_value_pair_options);
    % 2. estimator.estimate() - modifies the instance with results
    %
    % see also: Estimator, estimate    
    properties      
        errorSummary = {};
        outputs = {};        
        ErrorMetric ={};        
        filterProps={};
    end
    

    methods
        function obj = Estimator(model,varargin)
            %Estimator Construct an instance of this class
            %   Set extraction methods to those passed in the constructor
            % Options: name value pairs
            % ----------------------------------------------
            %  name           (default)           Description
            % ----------------------------------------------
            % 'FeatureList' | ([])               |  List of features to use
            % 'Model'       | ('feedforwardnet') |  Internal model representation            
            % 'Folds'       | (10)               |  Number of k-folds
            % 'Smoothing'   | 'kf'               |  Smoothing function to use in the output.                        
            % 'ErrorMetric' | (@meanAbsErrorMetric) | Function to compute error of prediction vs ground truth
            % see also: estimate
            
            inputs=inputParser;
            Names = {'ErrorMetric','Smoothing'};
            Defaults = {@ContinuousEstimation.meanAbsErrorMetric,'kf'};
            % Adding Parameter varagin
            for i = 1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});
            varOpts=inputs.Results;
            
            obj.addprop('model');
            obj.addprop('backupmodel');
            obj.addprop('bestmodel');
            
            % Get options:
            obj.ErrorMetric=varOpts.ErrorMetric;  
            obj.model=model;
            obj.backupmodel=copy(obj.model);
            
        end
                  
                
        function obj = train(obj,X,Y,varargin)
           % Train the estimator with the given inputs X and outputs Y 
           % -----------------------------------------------------------
           %  name           (default)           Description
           % -----------------------------------------------------------           
            inputs=inputParser;
            Names = {};
            Defaults = {false};
            for i = 1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});                       
            z=obj.model.train(X,Y);
            obj.model=z;                                
        end
        
        function out = predict(obj,X,varargin)
           % Use the estimator to predict the output from inputs X
           % -----------------------------------------------------------
           %  name           (default)           Description
           % -----------------------------------------------------------           
            inputs=inputParser;
            Names = {};
            Defaults = {false};
            for i = 1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});                       
            out=obj.model.predict(X);

	    % TODO Connect the filter here
            
        end
        
        
        function [y,out] = test(obj,X,varargin)
           % Test the estimator with the given inputs X and (optional) outputs Y 
           % returning the error metric if ground truth Y is given.
           % [y,out] = test(obj,X,Y(optional))
           
           inputs=inputParser;
           Names = {'Y'};
           Defaults = {[]};
           for i = 1:numel(Names)
               addOptional(inputs,Names{i},Defaults{i});
           end
             
           Names = {};
           Defaults = {false};
           for i = 1:numel(Names)
               addParameter(inputs,Names{i},Defaults{i});
           end
           
           parse(inputs,varargin{:});
           Y=inputs.Results.Y;
           
           y=obj.predict(X);
           if isempty(Y)
               out=nan;
           else
            out=obj.ErrorMetric(Y,y);
           end
            
        end
        
        
        function out=estimate(obj,xtrain,ytrain,varargin)
           % Estimate trains and tests model and saves info internally
           % out=estimate(obj,xtrain,ytrain,varargin)
           % out=estimate(obj,xtrain,ytrain,xtest,ytest,varargin)
           % 
           % Options:
           % 'Output': What the function should return ('Error') / 'Estimator'
           % 'Reset' : Reset the estimator before training
           % TODO save error metrics internally and keep track of best model
           % TODO include filtering too
            p=inputParser;
            
            Names = {'xtest','ytest'};
            Defaults = {[],[]};
            for i = 1:numel(Names)
                p.addOptional(Names{i},Defaults{i});
            end
            
            Names = {'Reset'};
            Defaults = {true};
            for i = 1:numel(Names)
                p.addParameter(Names{i},Defaults{i});
            end
            p.parse(varargin{:});
           
            Reset=p.Results.Reset;
            xtest=p.Results.xtest;
            ytest=p.Results.ytest;
            
            if Reset
                obj.reset();
            end
            
            % Estimate trains the model given some input and output data
            obj.train(xtrain,ytrain);
                        
            if isempty(xtest) || isempty(ytest)
               warning('Potential overfitting. Error will be computed on train data');
               [~,out]=obj.test(xtrain,ytrain);
               return;
            end
         
            [~,errorvalue]=obj.test(xtest,ytest); 
            out=errorvalue;
            
            
            
            
            
            
        end
        
        
        
        
        function obj=reset(obj)
           % Returns the estimator to a fresh state clearing any history of previous training
           % and filtering adaptation.
           
           obj.model=copy(obj.backupmodel);
           
           %TODO clear internal tracking variables
            
        end
        
        function freshEstimate(obj,X,Y)
           obj.reset();
           obj.estimate(X,Y);
        end
        
        
        
        
        
        
        
        
        function report(obj)
            fprintf('Estimator:\n');
            
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
        end
            
        
        %%%%%%%%%%%%%% SMOOTHING FUNCTIONS %%%%%%%%%%%%%%%%%%%%%
    
            function kalman(data,varargin)
                
                
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
            
          
            
            
            function MA(data)
                filtered = filter(ones(1,filterOptions{1})/filterOptions{1}, ...
                    1, data);
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

