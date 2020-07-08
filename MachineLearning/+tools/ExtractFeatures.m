function extractors=ExtractFeatures(filemanager,extractorStruct,varargin)
  % ExtractFeatures from all the files belonging to a specific
  % sensor
  %
  % ExtractFeatures(filemanager,extractorStruct)
  % 
  % Create extractorStructures defining the settings for feature extractor
  % under each field.
  % e.g. extractorStruct.imu={'TD',true};
  
  p=inputParser();
  p.addParameter('Mode','Slide');
  p.addParameter('Window',200);
  p.addParameter('Increment',50);
  p.addParameter('Parallel',false);  
  p.addParameter('OutPath',''); % Out path (where to save features)
  p.addParameter('FileManagerOpts',{}); %Aditional options for file manager
  p.parse(varargin{:});
  
  WINDOW=p.Results.Window;
  INCREMENT=p.Results.Increment;
  Mode=p.Results.Mode;
  OutPath=p.Results.OutPath;
  FileManagerOpts=p.Results.FileManagerOpts;
  
  isParallel=p.Results.Parallel;
  
  e=extractorStruct;
  f=filemanager;
  
  if isempty(OutPath)
      OutPath=f.root;
  end

  % Get the sensors from the extractor struct
  sensors=fieldnames(e);
  
  % Create extractors for each one of the sensors
  for sensorIdx=1:numel(sensors)
      sensor=sensors{sensorIdx};
      if ~isa(class(e.(sensor)),'FeatureExtractor')
          eopts=e.(sensor);
          e.(sensor)=FeatureExtractor(eopts{:});
      end
  end

  %  Now that we have the sensor extractors generate the feature
  % names in readable form.
  for sensorIdx=1:numel(sensors)
      sensor=sensors{sensorIdx};
      fileList=f.fileList('Sensor',sensor,FileManagerOpts{:});
      a=load(fileList{1});
      colNames=a.data.Properties.VariableNames;
      e.(sensor).configureHeader(colNames(2:end));
  end

  % Extract the features using loadrunsave depending on the option selected

for sensorIdx=1:numel(sensors)
    sensor=sensors{sensorIdx};
    fprintf('Extracting features for sensor %s\n',sensor);
    extractor=e.(sensor);
    sensorFiles=f.fileList('Sensor',sensor,FileManagerOpts{:});
    featureFiles=f.modFileList(sensorFiles,'Root',OutPath,'Sensor',[sensor '_features']);    
    switch Mode
        case 'Slide'
            fun=@(datastruct)struct('data',FeatureExtractor.slide(extractor,...
                datastruct.data,WINDOW,INCREMENT));
        case 'Indexed'
            error('Not implemented');
    otherwise
    end
      
    loadRunSave(fun,sensorFiles,'OutputPath',featureFiles,'Parallel',isParallel);
end

   extractors=e;

end





