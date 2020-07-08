function export2EpicToolbox(inputFolder,outputFolder)
% For an input folder containing the sf_post data combine all the sensors
% of the same trial into a mat file matching the structure for usage with
% EpicToolbox.
%
% sf_export2EpicToolbox(inputFolder,outputFolder)

%% Transform data for EpicToolbox

%% Combine data from different sensors into one struct
%Get all the files
sf=FileManager();
if ~exist(inputFolder,'dir')
    error('Folder does not exist: %s\n',inputFolder);
end
files=sf.fileList('Root',inputFolder);
% Get the structure of a file list as a table
content=split(files,filesep);
%Get the ones that have the same ambulation mode, trial number, date
% This is easy by making a cell array and dropping the sensor column 
content=content(1:end,[1,3:end]);
content=join(content,filesep());
alltrials=table2cell(unique(cell2table(content),'rows'));
alltrials=split(alltrials,filesep);
%%
if (~exist(outputFolder,'dir'))
    mkdir(outputFolder);
end
%%
for i=1:size(alltrials,1)
    p=[];
    p.ambulation=alltrials{i,1};
    p.subject=alltrials{i,2};
    p.date=alltrials{i,3};
    p.trial=alltrials{i,4};    
    files=sf.fileList('Root',inputFolder,'Ambulation',p.ambulation,'Subject',p.subject,'Date',p.date,'Trial',p.trial);
    content=split(files,filesep());
    sensors=content(:,2);    
    files=join([repmat({inputFolder},numel(files),1) files],filesep());
    %These files contain all the sensors for that particular trial
    %Load them and save them as a struct with the sensor name    
    content=multiLoad(files);
    trial=[];
    for j=1:numel(sensors)
        a=fieldnames(content{j});
        if numel(a)==1   %If there is just one element and is a table we just assign its data to sensor
            b=content{j};
            b=b.(char(a));
            if istable(b)
                trial.(sensors{j})=b;
            else % Data is not meant to be the leaf and structure is preserved
                trial.(sensors{j})=content{j}; 
            end
        else
            % Data is not meant to be the leaf and structure is preserved
            trial.(sensors{j})=content{j};             
        end
    end
    file=join(alltrials(i,:),filesep());file=fullfile(outputFolder,file{:});
    [dirname,~,~]=fileparts(file);        
    if ~exist(dirname,'dir')
        mkdir(dirname);
    end
    save(file,'-struct','trial');
end


end

  
  
