function save_sfpost(EpicToolboxStruct,varargin)
% save_sfpost(EpicToolboxStruct,varargin)
% For a cell array of structs formated for EpicToolbox, save .mat files
% for each sensor present for usage with sf_post. 
%
% Inputs:
%       EpicToolboxStruct: struct outputted by the EpicToolbox function.
%           If the struct contains the info field it will be used for generating directory names.
%	    otherwise it will use a numeric sequence.
%
% Optional:
%       'FileManager' obj: FileManager object, containing the root and path structure to 
%                          save to. If using this option the
%                          EpicToolboxStruct must contain an 'info' field
%                          with subfields per each pathlevel in the file
%                          manager. This info will be used to create the
%                          folder paths for sfpost.
%       'OverWrite'  (true)/false 
%       'hdf5'       true/(false)  save as hdf5 format to load in python
%       'SplitTopics' true/(false) For topics that share the same branch
%                                  save in different sensor folders instead
%                                  of a struct.
      
narginchk(0,6);
p=inputParser();
p.addParameter('FileManager',[],@(x)isa(x,'FileManager'));
p.addParameter('hdf5',false,@islogical);
p.addParameter('Overwrite',true,@islogical);
p.addParameter('SplitTopics',false,@islogical);

p.parse(varargin{:});
f=p.Results.FileManager;

Overwrite=p.Results.Overwrite;
isHDF5=p.Results.hdf5;
SplitTopics=p.Results.SplitTopics;

% List of files to be written to.
allFiles = {};

if ~iscell(EpicToolboxStruct)
    EpicToolboxStruct={EpicToolboxStruct};
end
n=numel(EpicToolboxStruct);

if isfield(EpicToolboxStruct{1},'info')
   fields=fieldnames(EpicToolboxStruct{1}.info);
else
   fields={};
end

% Create a destination file manager if no file manager was given
if isempty(f)
   % Get the info field from the struct or default to a 'Sensor'/'Trial' file manager
   if isfield(EpicToolboxStruct{1},'info')
	   contents=struct2cell(EpicToolboxStruct{1}.info);
	   contents=[contents{:}];
       fnameFieldIdx=find(contains(contents,'.mat'),1);
 	   assert(~isempty(fnameFieldIdx),'Problem finding the file name in the info field');
	   fnameField=fields(fnameFieldIdx);
       otherfields=setdiff(fields,fields(fnameFieldIdx));
       % Use Trial as the last element 
	   f=FileManager('Root',pwd,'PathStructure',vertcat('Sensor', otherfields, fnameField));
   else
	   fnameField='Trial';
	   f=FileManager('Root',pwd,'PathStructure',{'Sensor',fnameField});
	   %Create an artificial Trial name based on index
	   ndigits=ceil(log10(n))+1; 
	   for i = 1:length(EpicToolboxStruct)
	       a=sprintf(['%0',sprintf('%d',ndigits),'d'],i);
	       EpicToolboxStruct{i}.info=[];
	       EpicToolboxStruct{i}.info.Trial=a;
	   end
   end      
end



fnameField=f.folderLevels{end};
uc=any(ismember(f.folderLevels,'Sensor')); lc=any(ismember(f.folderLevels,'sensor'));
if ~(uc || lc)
    error('FileManager object must have a sensor folderlevel in its pathstruct');
elseif uc
    sensorlevel='Sensor';
elseif lc
    sensorlevel='sensor';
end
    


% Create a table for the fields 

otherFields=setdiff(fields,f.folderLevels);
otherFieldsTbl=cell2table(cell(n,numel(otherFields)),'VariableNames',otherFields);

% Fill in the tables with data form info
levels=setdiff(f.folderLevels,sensorlevel);
trialFieldsTbl=cell2table(cell(n,numel(levels)),'VariableNames',levels);

for i = 1:numel(levels)
    field=levels{i};
    content=cellfun(@(x)(x.info.(field)),EpicToolboxStruct,'Uni',0);
    trialFieldsTbl.(field)=content;
end

for i = 1:numel(otherFields)
    field=otherFields{i};
    content=cellfun(@(x)(x.info.(field)),EpicToolboxStruct,'Uni',0);
    otherFieldsTbl.(field)=content;
end

% Combine Otherfields in a single label
if ~isempty(otherFieldsTbl)
    otherFieldsCell=join(otherFieldsTbl.Variables,'_',2);
else
    otherFieldsCell={};
end

% Change the names of last column in trialFields (trial name) to include
% otherFields and make sure nothing is repeated.
trialnames=trialFieldsTbl{:,end};
if ~isempty(otherFieldsCell)
    trialnames=join(horzcat(otherFieldsCell,trialnames),'_',2);
end
trialFieldsTbl{:,end}=trialnames;
[unique_trialnames,unique_trialnamesCnt,unique_trialnamesIdx]=unique(trialnames);


% Save the files

arguments=cell(1,2*numel(levels));
for i=1:numel(EpicToolboxStruct)
	arguments(1:2:end)=levels;
	arguments(2:2:end)=trialFieldsTbl{i,:};
    
    % Save files for topics with tables
    sensors=Topics.topics(EpicToolboxStruct{i},'Recursive',SplitTopics);            
    for j=1:numel(sensors)
        outfile=f.genList(arguments{:},sensorlevel,sensors{j});
        [~,~,ext]=fileparts(outfile{1});
        if ~strcmp(ext,'.mat')
            outfile{1}=[outfile{1} '.mat'];
        end
        mkdirfile(outfile{1});
        if (Overwrite || ~exist(outfile{1},'file'))
            data=eval(sprintf('EpicToolboxStruct{i}.%s',sensors{j}));
            if ~isHDF5
                save(outfile{1},'data');    
            else
            	table2hdf5(data,outfile{1});
            end
        end
    end
    
    % Save files for other topics
    allsensors=Topics.topics(rmfield(EpicToolboxStruct{i},'info'),...
        'Header',false,'Recursive',SplitTopics);
    othersensors=setdiff(allsensors,sensors); 
    for j=1:numel(othersensors)
        othersensor=othersensors{j};
        othersensor=split(othersensor,'.');       
        othersensor=othersensor{1};
        outfile=f.genList(arguments{:},sensorlevel,othersensor);
        [~,~,ext]=fileparts(outfile{1});
        if ~strcmp(ext,'.mat')
            outfile{1}=[outfile{1} '.mat'];
        end
        mkdirfile(outfile{1});
        if (Overwrite || ~exist(outfile{1},'file'))
            a=strsplit(othersensor,'.');
            data=getfield(EpicToolboxStruct{i},a{:}); 
            if isstruct(data)
                save(outfile{1},'-struct','data');
            else
                save(outfile{1},'data');
            end
        end
    end
end




end

%{

%% sf_post/SF2018 structure:
trialType/sensor/subject/date/(.mat file)

%% Epic Toolbox structure:
cell array containing structures, each with fields of tables of the extracted
sensors, and a struct "info" that contains information regarding the trial
%}

