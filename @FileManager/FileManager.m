% Class for convenient handling of files in structured directory with
% repetitive patterns.
%
% Since this was first conceived for sensor fusion data that has the structure:
%  STUDY/AMBULATION/SENSOR/SUBJECT/DATE/trialname.ext
% The class operates with that structure by default
%
% Construct a FileManager object and use its member functions
%
% Using default behavior (sensor fusion structure)
% f=FileManager();
%
% Using other folder pattern
% f=FileManager(rootDir,'PathStructure',{'folderLevel1','folderLevel2','folderLevel3'});
% This specifies how the data is nested inside folders
%
% Get a list of files with fileList
%
% see also: FileManager,fileList,modFileList,EpicToolbox

classdef FileManager
    
    
    properties
        folderLevels={};
        root='';
        showRoot=true; % Flag to determine if the user wants to hide or include the root path
        useFullFileList=false;                
    end
    
    properties (Access=public)
        fullFileList={};
        
    end
    
    methods
        function obj=FileManager(root,varargin)
            % Class for convenient handling of files in structured directory with
            % repetitive patterns.
            % FileManager(root)
            % 
            % FileManager(varargin)
            % ----------------------------------------------
            %  name    value1/value2/(default)  Description
            % ----------------------------------------------                        
            % 'PathStructure'       |
            % ({'Ambulation','Sensor','Subject','Date','Trial'})    | Structure of how files are saved
            % 'ShowRoot'            | (false)                       | Treat the files as absolute path by always prepending the root
            % 'FullFileList'        | ({})                          | An internal representation of all the files to eliminate the amount of disk readings.
            narginchk(0,6);
            %Default constructor (empty)
            
            defaultPathStructure={'File'};
            p=inputParser();
            p.addRequired('Root',@(x)isValidRootDir(x));
            p.addParameter('PathStructure',defaultPathStructure,@isValidPathStructure);
            p.addParameter('ShowRoot',true,@islogical);
            p.addParameter('FullFileList',{},@iscell);                        
            
            p.parse(root,varargin{:});
            
            rootDir=p.Results.Root;
            if rootDir(end)==filesep
                rootDir=rootDir(1:end-1);
            end
            
            pathStructure=p.Results.PathStructure;
            %Make rootDir full path
            
            if exist(rootDir,'dir')
                a=dir(rootDir);
                rootDir=a(1).folder;
            end
            
            % Assign properties
            obj.root=rootDir;
            obj.folderLevels=pathStructure;
            obj.showRoot=p.Results.ShowRoot;
            obj.fullFileList=p.Results.FullFileList;
            
            if ~isempty(obj.fullFileList)
                obj.useFullFileList=true;
            else
                obj.useFullFileList=false;
            end
            
            
            function isvalid=isValidRootDir(rootDir)
                isvalid=true;
                if ~ischar(rootDir)
                    isvalid=false;
                    return
                end
                if strcmpi(rootDir,'PathStructure')
                    isvalid=false;
                end
                
            end
            
            function isvalid=isValidPathStructure(pathStructure)
                isvalid=true;
                if any(strcmp(pathStructure,'Ext'))                    
                    error('Ext is reserved, can not be used a path structure level');
                end                
            end
                        
        end
        
        function varargout=getFields(obj,fileList,varargin)
            % From a fileList, retrieve a field based on the pathStructure            
            % getFields(obj,fileList,pathStructureField1,pathStructureField2,...)
            % fileList is a list of files as obtained from fileList
            % function. 
            % pathStructureField is a char of the field that you want to 
            % retrieve.
            % 
            % Example: f=FileManager(); 
            %          filelist=f.fileList();
            %          f.getFields(fileList,'Trial'); % Retrieves the trial name
            % See also fileList
            
            folderLevel=varargin;            
            
            if isempty(folderLevel)
                folderLevel=obj.folderLevels;
                structOutput=true;
            else
                structOutput=false;
            end
            
            if isempty(fileList)
                error('empty fileList provided');
            end
            % Divide the cell arrays by file separator
            a=split(fileList,filesep);
            if size(a,2)==1
                a=a';
            end
            
            ncols=size(a,2);            
            
            [~,pos]=ismember(folderLevel,obj.folderLevels);
            nlevels=numel(obj.folderLevels);
            
            if any(pos==0)
                badfields=strjoin(folderLevel(pos==0),',');
                error_msg='Folder levels do not exist in file manager:';
                error_msg=[error_msg sprintf('%s\n',badfields) sprintf('\n Available Levels are: %s',strjoin(obj.folderLevels,','))];
                error(error_msg);
            end
            
            field=a(:,(ncols-nlevels)+pos);
                        
            varargout=cell(numel(pos),1);
            for i=1:numel(pos)
                varargout{i}=field(:,i);
            end
            
            if structOutput
               varargout={cell2struct(varargout,obj.folderLevels)};
            end
            
            
            
        end
         
        function keyList=genList(obj,varargin)
            % For a file manager object, produce a list of files that can be created as a combination 
            % of given fields in the path structure according to folder levels.
            %
            % e.g. fileList=genList('Sensor',{'emg','fsr'})
            % fileList=  
            %            '<root>/*/emg/*/*/*',
            %            '<root>/*/fsr/*/*/*'
            %
            %
            % This will use the FileManager folderLevels
            %
            % Default folders for sensor fusion:
            % Options: name value pairs (for sensor fusion folder structure
            % ----------------------------------------------
            %  name    value1/value2/(default)  Description
            % ----------------------------------------------
            % 'Ambulation'  | ('*')         | Ambulation mode
            % 'Sensor'      | ('*')         |
            % 'Subject'     | ('*')         |
            % 'Date'        | ('*')         |
            % 'Trial'       | ('*')         |
            % 'Root'        | ('RawMatlab') | Input folder name
            folderLevels=obj.folderLevels;

            p=inputParser;
            % Validations
            validStrOrCell=@(x) iscell(x) || ischar(x);
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
                if obj.showRoot
                    Root=obj.root;
                else
                    Root='';
                end              
            else
                %using full file list probably means data is from dropbox so filesep should
                %be linux.
                filesep_='/';
            end

            N=zeros(numel(folderLevels),1);
            combIdx=cell(numel(folderLevels),1);

            folderItems=[];
            for i=1:numel(folderLevels)
                folderItems.(folderLevels{i})=str2cell(p.Results.(folderLevels{i}));
                N(i)=numel(folderItems.(folderLevels{i}));    
                combIdx{i}=1:N(i);
            end
            keyList=cell(prod(N),1);

            % All the combinations of folder level values
            combinationsIdx=combvec(combIdx{:})';
            combinations={};
            for i=1:numel(folderLevels)    
                leveli=folderItems.(folderLevels{i});
                a=combinationsIdx(:,i);
                selections=leveli(a);
                if size(selections,2)>size(selections(a),1)
                    selections=selections';
                end
                combinations=[combinations selections];
            end
            if ~strcmp(Root,'')
                a=[repmat({Root},size(keyList,1),1) combinations];
            else
                a=combinations;
            end
            keyList=join(a,filesep_);
            
            
            function out=str2cell(x)
                if (ischar(x))
                    out={x};
                end
                if (iscell(x))
                    out=x;
                end
            end


        end
            
            
            
       
        
        fileList=fileList(obj,varargin);
        fileList=modFileList(obj,fileList,varargin);
        trialData=EpicToolbox(obj, fileList);
    end
    
    
    
    methods (Static)
        
        % Todo Are this updated?
        %combine(matfiles,varargin);
                
        %download(params);
        
        %export2EpicToolbox(inputFolder,outputFolder);
        
        
        
        %fun(fun,params);
        
        %post();
        
        
        
        
        
    end
    
    
end