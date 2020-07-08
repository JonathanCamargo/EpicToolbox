function sf_post(EpicToolboxStruct,varargin)
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
      
warning('This function will be renamed to save_sfpost on the next release');
narginchk(0,6);
p=inputParser();
p.addParameter('FileManager',[],@(x)isa(x,'FileManager'));

p.parse(varargin{:});
f=p.Results.FileManager;


% Always save the files but for debugging have this flag to disable/enable
SAVE = true;

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

% Create a table for the fields 

otherFields=setdiff(fields,f.folderLevels);
otherFieldsTbl=cell2table(cell(n,numel(otherFields)),'VariableNames',otherFields);

% Fill in the tables with data form info
levels=setdiff(f.folderLevels,'Sensor');
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
    sensors=Topics.topics(EpicToolboxStruct{i});
    for j=1:numel(sensors)
        outfile=f.genList(arguments{:},'Sensor',sensors{j});
        mkdirfile(outfile{1});
        data=eval(sprintf('EpicToolboxStruct{i}.%s',sensors{j}));
        save(outfile{1},'data');
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

