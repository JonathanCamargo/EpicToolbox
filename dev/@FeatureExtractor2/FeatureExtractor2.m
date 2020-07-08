classdef FeatureExtractor2 < handle
    warning('Consider removing windowing and sliding from this function or update the documentation to make this understandable');
    warning('Personaly I think that sliding makes this too complicated and that should be part of the script or another function');
    error('This function is poorly documented please fix');
    %A class to extract feature vectors from data
    %
    %Usage:
    % 1. Set up a FeatureExtractor using the constructor with the constructor
    % extractor=FeatureExtractor(name_value_pair_options);
    % 2. FEATURE_TABLE=extractor.parseFeatures(X) where X is a vector (or matrix) with columns
    % containing a window of data with each row corresponding to a sample
    % inside the window.
    %
    %
    % Name value pair options are: (defaults)
    % - 'TD' (true)/false     Time domain features
    % - 'AR' true/(false)     Auto recursive
    % - 'AROrder'	(4)       Auto recursive order
    % - 'EN'  true/(false)    Entropy
    % - 'WT'   true/(false)   Wavelet transform
    % - 'wname' ('coif1')     Mother wavelet
    % - 'mean' true/(false)   Mean over window
    properties
        header={};
        featureOptions=[];
        isReady=false;
        channels=0;
        features_header={};
    end
    
    methods (Static, Hidden)
        features= TD_extract(window)
        features= EN_extract(window)
        features= WT_extract(window,levels,wname)
        features= AR_extract(window,AROrder)
        features= MEAN_extract(window)
        features= LAST_extract(window)
    end
    
    methods
        function obj=FeatureExtractor(varargin)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% Optional inputs name-value paired %%%%%%
            inputs=inputParser;
            %name value pairs optional inputs
            Names={'type','window','slide','TD','AR','AROrder','EN','WT','WTLevels','WTName','MEAN','LAST'};
            Defaults={'SlidingWindow',NaN, NaN, false,false,2,false,false,4,'coif1',false, false};
            for i=1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.featureOptions=inputs.Results;
        end
        
        function featureVector=generateFeature(obj,multiChannelWindow)
            %Compute the feature vector from a colum wise channel window
            
            N_features=numel(obj.features_header);
            if (isnumeric(multiChannelWindow(1)))
                featureVector=zeros(1,N_features*obj.channels);
            elseif (iscell(multiChannelWindow(1)))
                featureVector=cell(1,N_features*obj.channels);
            end
            features_start=1;
            for channel_i=1:obj.channels
                
                if (obj.featureOptions.AR)
                    AROrder=obj.featureOptions.AROrder;
                    feats=FeatureExtractor.AR_extract(multiChannelWindow(:,channel_i),AROrder);
                    featureVector(features_start:features_start+numel(feats)-1)=feats;
                    features_start=features_start+numel(feats);
                end
                
                if (obj.featureOptions.EN)
                    feats=FeatureExtractor.EN_extract(multiChannelWindow(:,channel_i));
                    featureVector(features_start:features_start+numel(feats)-1)=feats;
                    features_start=features_start+numel(feats);
                end
                
                if (obj.featureOptions.TD)
                    feats=FeatureExtractor.TD_extract(multiChannelWindow(:,channel_i));
                    featureVector(features_start:features_start+numel(feats)-1)=feats;
                    features_start=features_start+numel(feats);
                end
                
                if (obj.featureOptions.WT)
                    levels=obj.featureOptions.WTLevels;
                    wname=obj.featureOptions.WTName;
                    feats=FeatureExtractor.WT_extract(multiChannelWindow(:,channel_i),levels,wname);
                    featureVector(features_start:features_start+numel(feats)-1)=feats;
                    features_start=features_start+numel(feats);
                end
                
                if (obj.featureOptions.MEAN)
                    feats=FeatureExtractor.MEAN_extract(multiChannelWindow(:,channel_i));
                    featureVector(features_start:features_start+numel(feats)-1)=feats;
                    features_start=features_start+numel(feats);
                end
                
                if (obj.featureOptions.LAST)
                    feats=FeatureExtractor.LAST_extract(multiChannelWindow(:,channel_i));
                    featureVector(features_start:features_start+numel(feats)-1)=feats;
                    features_start=features_start+numel(feats);
                end
            end
        end
        
        function output = extractFeatures(obj, input, varargin)
            % Extract the features from some input data
            % output=extractor.extractFeatures(input);
            % Input data can be either a trial structure or a sensor table
            % Output data is a trial structure or a sensor table
            % respectively.
            
            inputs=inputParser;
            %name value pairs optional inputs
            Names={'gait','location'};
            Defaults={NaN, 0};
            for i=1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            gait=inputs.Results.gait;
            location=inputs.Results.location;
            
            output=[];
            if istable(input)
                data=input;
                % Check if data has a Header column and ignore it... we
                % don't want to generate features from timestamp.
                if strcmp(data.Properties.VariableNames(1),'Header')
                    data=data(:,2:end);
                end
            elseif isstruct(input)
                % Recursively extractFeatures from the structure
                a=fieldnames(input);
                for i=1:numel(a)
                    b=input.(a{1});
                    output.(a{1})=obj.extractFeatures(b);
                end
                return;
            else
                return;
            end
            
            %check if the extractor is defined for this size of input matrix
            if (obj.channels~=size(data,2) || ~strcmp(obj.header{1}(1:2),data.Properties.VariableNames{1}(1:2)) || ~obj.isReady)
                %Number of channels
                obj.channels=size(data,2);
                fprintf('Configuring headers of feature extraction for %i channels\r\n',obj.channels);
                obj.configureHeader(data.Properties.VariableNames);
                fprintf('Header: ');
                fprintf(' %s ',obj.header{:});
                fprintf('\r\n');
            end
            
            if strcmp(obj.featureOptions.type, 'SlidingWindow')
                
                indx = 1;
                start = 1;
                finish = start + obj.featureOptions.window - 1;
                if (isnumeric(table2array(data(1, 1))))
                    features = [];
                elseif (iscell(table2array(data(1, 1))))
                    features = {};
                end
                while finish<size(data,1)
                    window=table2array(data(start:finish,:));
                    windowFeatures=obj.generateFeature(window);
                    features=[features; windowFeatures];
                    indx=indx+1;
                    start=start+obj.featureOptions.slide;
                    finish = start+obj.featureOptions.window-1;
                end
                features = array2table(features,'VariableNames',obj.header);
                
                if istable(input)
                    output=features;
                end
            elseif strcmp(obj.featureOptions.type, 'GaitDependent')
                % This is not robust, fix this
                [~,locs] = findpeaks(double(sign(gait - location-0.0001)>0));
%                 locs = find(gait == location);
                locs = locs((locs > obj.featureOptions.window)==1);
                
                if (isnumeric(table2array(data(1, 1))))
                    features = [];
                elseif (iscell(table2array(data(1, 1))))
                    features = {};
                end
                
                for i = 1:length(locs)
                    window=table2array(data((locs(i)-obj.featureOptions.window):locs(i),:));
                    windowFeatures=obj.generateFeature(window);
                    features=[features; windowFeatures];
                end
                features = array2table(features,'VariableNames',obj.header);
                
                if istable(input)
                    output=features;
                end
            end
        end
    end
end
