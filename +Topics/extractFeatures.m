  function out = extractFeatures(trial_data,extractors, varargin)
            % Extract the features from some input data
            % output=extractFeatures(trialdata,extactors,OPTIONAL);
            % Where trialdata is the trial struct and extractors is 
            % a feature extractor object or a trial struct containing
            % independent extractors for each topic.
            %
            % Output data is a trial structure containing features
            % Optional inputs name-value pair:
            % 'Window' number of samples for each window
            % 'Increment' number of for stride in sliding window
            % 'Location' indices for backwards feature extraction
            %            when this is used, increment is ignored and
            %            the features are computed from a window containing
            %            [location-window:location]
            % 'KeepNames' Keep colum names for feature names
            %             true/false (default true)
            
    narginchk(1,8);
    % Validations
    validCell=@(x) iscell(x) && ischar(x{1});
    
    inputs=inputParser;
    %name value pairs optional inputs
    Names={'Window','Increment','Location','KeepNames'};
    Defaults={250,50,[],true};
    addOptional(inputs,'Topics',{},validCell);
    for i=1:numel(Names)        
        addParameter(inputs,Names{i},Defaults{i});            
    end
    parse(inputs,varargin{:});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    window=inputs.Results.Window;
    increment=inputs.Results.Increment;
    location=inputs.Results.Location;
    keepNames=inputs.Results.KeepNames;

    % Get the optional results:
    % Get message list
    % List of messages to process:
    if isempty(inputs.Results.Topics)
        topics_list=Topics.defaults.fields;
    elseif ischar(inputs.Results.Topics)
        topics_list={inputs.Results.Topics};
    else
        topics_list=inputs.Results.Topics;
    end

    if istable(trial_data)
        out=extractFeatures_table(trial_data,extractors);
    else
        if iscell(trial_data) %it is not an individual trial but a cell array with trials. 
            %run the cut function individually.
            trials_array=trial_data;
            fun=@(each_trial_data)extractFeatures(each_trial_data,extractors,varargin);
            out=Topics.processTrials(fun,trials_array);
        else
            out=struct;
            for topicIdx=1:numel(topics_list)
                if isstruct(extractors)
                    extractor=extractors.(topics_list);
                else
                    extractor=extractors;
                    extractor=extractor.reset();
                end
                if keepNames
                    a=trial_data.(topics_list{topicIdx});
                    a=a.Properties.VariableNames;
                    extractor=extractor.configureHeader(a(2:end));
                end
                fun=@(table_data)extractFeatures_table(table_data,extractor);
                out.(topics_list{topicIdx})=fun(trial_data.(topics_list{topicIdx}));                
            end
        end
    end


function features=extractFeatures_table(table_data,extractor)

  %remove the Header column since we don't want features from it.
  data=table_data(:,2:end);
  if ~isempty(location)
      features=[];
      for i=1:numel(location)                
        features=[features;extractor.extract(data{location(i)-window+1:location(i),:})];
      end
       features = array2table(features,'VariableNames',extractor.header);
  else              
        indx = 1;
        start = 1;
        finish = start + window - 1;
        if (isnumeric(table2array(data(1, 1))))
            features = [];
        elseif (iscell(table2array(data(1, 1))))
            features = {};
        end
        while finish<size(data,1)
            windowData=table2array(data(start:finish,:));
            windowFeatures=extractor.extract(windowData);
            features=[features; windowFeatures];
            indx=indx+1;
            start=start+increment;
            finish = start+window-1;
        end
        features = array2table(features,'VariableNames',extractor.header);
  end

end

end
            
            
            
            
            
            
            
            