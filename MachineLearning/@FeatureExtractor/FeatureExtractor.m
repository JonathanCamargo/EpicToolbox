classdef FeatureExtractor < handle
    %A class to extract feature vectors from a window of data. This function serves a
    % simple way to compute different type of features.
    %
    %Usage:
    % 1. Set up a FeatureExtractor using the constructor with the constructor
    % extractor=FeatureExtractor(name_value_pair_options);
    % 2. FEATURE_TABLE=extractor.extract(X) where X is a vector (or matrix) with columns
    % containing a window of data with each row corresponding to a sample
    % inside the window.
    %
    %
    % Name value pair options are: (defaults)
    % - 'LAST' true/ (false) Last sample in the window
    % - 'TD'  true/(false)     Time domain features
    % - 'AR'  true/(false)     Auto recursive
    % - 'AROrder'	(4)       Auto recursive order
    % - 'EN'  true/(false)    Entropy
    % - 'WT'  true/(false)   Wavelet transform
    % - 'wname' ('coif1')     Mother wavelet
    % - 'mean' true/(false)   Mean over window
	
    % See also extract, slide
    % jon-cama@gatech.edu

    properties (Access=private)            
        isReady=false;
        channels=0;
        features_header={};
    end
    properties (Access=public)
         featureOptions=[];
         header={};  
    end

    methods (Static, Hidden)
        features= TD_extract(window)
        features= EN_extract(window)
        features= WT_extract(window,levels,wname)
        features= AR_extract(window,AROrder)
        features= MEAN_extract(window)
        features= LAST_extract(window)
    end

    methods (Access=public)
        function obj=FeatureExtractor(varargin)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% Optional inputs name-value paired %%%%%%
            inputs=inputParser;
            %name value pairs optional inputs
            Names={'TD','AR','AROrder','EN','WT','WTLevels','WTName','MEAN','LAST'};
            Defaults={false,false,2,false,false,4,'coif1',false, false};
            for i=1:numel(Names)
                addOptional(inputs,Names{i},Defaults{i});
            end
            parse(inputs,varargin{:});
            
            narginchk(1,20);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.featureOptions=inputs.Results;
        end
        obj=configureHeader(obj,varargin);
        function obj=reset(obj)
            % Reset the feature extractor so that it regenerates the header
            obj.isReady=false;
        end        
        	
        function featureVector=extract(obj,multiChannelWindow)
            %Compute the feature vector from a colum wise channel window
            % featureVector=extract(obj,multiChannelWindow)
            %Compute the feature vector from a colum wise channel window
            %check if the extractor is defined for this size of input matrix
            if (obj.channels~=size(multiChannelWindow,2) || ~obj.isReady)
                %Number of channels
                obj.channels=size(multiChannelWindow,2);
                fprintf('Configuring headers of feature extraction for %i channels\r\n',obj.channels);
                obj.configureHeader();
                fprintf('Header: ');
                fprintf(' %s ',obj.header{:});
                fprintf('\r\n');
            end
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
    end
    
     methods(Static)
        outdata=slide(e,dataTable,window,increment)
     end
        
end
