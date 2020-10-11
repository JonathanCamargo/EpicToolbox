function fileList=fileList(obj,varargin)
% Retrieve the list of files that match the regexp given by Parameter inputs
% according to folder levels.
%
% This will use the FileManager folderLevels
%
%e.g. f = FileManager('Root', 'C:\Users\<name>\Dropbox (GaTech)\data', 'PathStructure', {'Mode', 'Sensor', 'Subject', 'Date', 'Trial'});
%files = f.fileList('Mode', 'stairascent', 'Sensor', 'imu'); 
%files is a cell array with the addresses of each file that meets the
%conditions in fileList's input

folderLevels=obj.folderLevels;

p=inputParser;
% Validations
validStrOrCell=@(x) isstruct(x) || iscell(x) || ischar(x);
% Adding Parameter varagin
for i=1:(numel(folderLevels))
    p.addParameter(folderLevels{i},{'*'},validStrOrCell);
end 
p.addParameter('Root',obj.root)

p.parse(varargin{:});

Root = p.Results.Root;

filesep_=filesep;

% Get the real path of Root:
if ~obj.useFullFileList
assert(isfolder(Root),'Root folder not found');
a=dir(Root);
Root=a(1).folder;
else
    %using full file list probably means data is from dropbox so filesep should
    %be linux.
    filesep_='/';
end

fieldlist=varargin;

keyList=obj.genList(fieldlist{:});

list=[];

if ~obj.useFullFileList
    for i=1:numel(keyList)
        found=dir(keyList{i});
        a=[{found.folder}' {found.name}'];
        list=[list;a];    
    end
else
    keyList=strrep(keyList,'*','.*'); % Use this to replace wildcard and use regexp
    for i=1:numel(keyList)
        isFound=~cellfun(@isempty,regexp(obj.fullFileList,keyList{i}));
        found=obj.fullFileList(isFound);
        folders=cell(numel(found),1);
        names=cell(numel(found),1);
        extensions=cell(numel(found),1);

        if ~any(isFound)
            continue
        end
        
        for j=1:numel(found)
            [folders{j},names{j},extensions{j}]=fileparts(found{j});
        end

        a=[folders join([names,extensions],'')];
        list=[list;a];    
    end        
end

%Merge folder and file name in fileList
fileList=cell(size(list,1),1);
isFolder=false(size(list,1),1);
for i=1:size(list,1)
    if isfolder(fullfile(list{i,1}, list{i,2}))
        isFolder(i)=true;
    end
    %Remove folder path before root
    if ~(obj.showRoot)
        a=split(fullfile(list{i,1}, list{i,2}),[Root,filesep_]);    
        fileList{i}=a{2};   
    else
        fileList{i}=fullfile(list{i,1}, list{i,2});
    end
end

if filesep_~=filesep
    fileList=strrep(fileList,filesep,filesep_);
end

fileList=fileList(~isFolder);
fileList=unique(fileList,'stable');

end

function out=str2cell(x)
    if (ischar(x))
        out={x};
    end
    if (iscell(x))
        out=x;
    end
end


