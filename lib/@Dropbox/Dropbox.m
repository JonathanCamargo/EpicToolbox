classdef Dropbox < handle
% A class to use Dropbox API
%
% 
% See also Dropbox, download, fileList

properties (Access=private)
    AuthToken='';
end

properties (Access=public)
    %localPath='';
    %remotePath='';
end

methods (Access=public)
	
    
    %fileList=fileList(obj,folderName)
    %download(obj,fileNames,varargin)

    function obj=Dropbox(token)
        % Dropbox(token)
        % Create a dropbox object with a given token value
        % obj=Dropbox(token)
        obj.AuthToken=token;
    end
        
	function obj=token(obj,token)
        
		obj.AuthToken=token;
    end	
    
    %%%%%%%%%%%%%%%%%%%%% MAIN METHODS
    
    function files=fileList(obj,folderName)
% fileList provides a list of files under a dropbox folder
% a dropbox api (with App folder type access).
%
% files=fileList(obj,folderName)
%
% folder name is a path with respect to the app folder in the dropbox.
% 
% Download path to the files is set to workspace location 
% by default but can also specified as a third parameter
% 
% To generate a Dropbox access token
% * Go to www.dropbox.com/developers/apps in a web browser
% * Click on "Create app"
% * Select "Dropbox API" and "App folder" for options (1) and (2)
% * Specify the name of the folder you want your files to show up in
% * Click on the "Generate Access Token" on the page and note down the access token

    folderName=strrep(folderName,'\','/'); % Make the filesep linux
    dropboxAccessToken=obj.AuthToken;
    % Generate the custom header
    headerFields = {'Authorization', ['Bearer ', dropboxAccessToken]};    
    headerFields{2,1} = 'Content-Type';
    headerFields{2,2} = 'application/json';
    headerFields = string(headerFields);

    % Set the options for WEBREAD
    opt = weboptions;
    opt.MediaType = 'application/json';
    opt.CharacterEncoding = 'ISO-8859-1';
    opt.RequestMethod = 'post';
    opt.HeaderFields = headerFields;
    opt.Timeout=30;
    files={};
    % Check the file path
    try
        rawData = webwrite('https://api.dropboxapi.com/2/files/list_folder', (sprintf('{"path": "/%s","recursive": true}',folderName)),opt);                           
        entries=rawData.entries;
        if ~iscell(entries)
                entries=num2cell(entries);
        end            
        for i=1:numel(entries)
            if strcmp(entries{i}.x_tag,'file')
                files=[files; entries{i}.path_display];
            end
        end       
        while rawData.has_more
            cursor = rawData.cursor;
            rawData = webwrite('https://api.dropboxapi.com/2/files/list_folder/continue', (sprintf('{"cursor": "%s"}',cursor)),opt);
            entries=rawData.entries;
            if ~iscell(entries)
                entries=num2cell(entries);
            end
            for i=1:numel(entries)
                if strcmp(entries{i}.x_tag,'file')
                   files=[files; entries{i}.path_display];
                end
            end
            
        end
        
    catch someException
        throw(addCause(MException('downloadFromDropbox:unableToDownloadFile',strcat('Unable to find folder:',folderName)),someException));
    end

end


function download(obj,fileNames,varargin)
%
% download(fileNames,varargin)
%
% downloadFromDropbox uses the dropboxAccessToken to download files from
% a dropbox api (with App folder type access).  
% % 
% fileNames is a cell array of filenames to be downloaded  
% The filenames' path is with respect to the app folder in the dropbox.


% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'DownloadPath' | (pwd) |  Path of where to download the files
% 'RepRoot'      | ({})  |  Origin and dest replacement pair to substitute the root of the download path before downloading.
% 
% To generate a Dropbox access token
% * Go to www.dropbox.com/developers/apps in a web browser
% * Click on "Create app"
% * Select "Dropbox API" and "App folder" for options (1) and (2)
% * Specify the name of the folder you want your files to show up in
% * Click on the "Generate Access Token" on the page and note down the access token

% Copyright 2018 The MathWorks, Inc

% Check to input arguments
narginchk(1,4);

p=inputParser();
p.addParameter('DownloadPath',pwd,@(x)(exist(x,'dir')));
p.addParameter('Overwrite',false,@islogical);
p.addParameter('RepRoot',{},@iscell);
p.parse(varargin{:});

downloadPath=p.Results.DownloadPath;
overwrite=p.Results.Overwrite;
repRoot=p.Results.RepRoot;

isRepRoot=false;
if numel(repRoot)==2
    oldPrefix=repRoot{1};
    newPrefix=repRoot{2};
    isRepRoot=true;
    if numel(newPrefix)>1
        if (oldPrefix(1)==filesep) && (newPrefix(1)~=filesep)
            newPrefix=[filesep newPrefix];
        elseif (oldPrefix(end)==filesep) && (newPrefix(end)~=filesep)
            newPrefix=[newPrefix filesep];
        elseif (oldPrefix(1)~=filesep) && (newPrefix(1)==filesep)
            newPrefix=newPrefix(2:end);
        elseif (oldPrefix(end)~=filesep) && (newPrefix(end)==filesep)
            newPrefix=newPrefix(1:end-1);
        end
    else
        newPrefix='';        
    end
end
    

dropboxAccessToken=obj.AuthToken;

waitbar_0 = waitbar(0,'Please wait...');
for i = 1:length(fileNames)
    fileName=fileNames{i};
    if isRepRoot
        fileName=strrep(fileName,oldPrefix,newPrefix);
    end
    fullPath = fullfile(downloadPath, fileName);
      
    if (exist(fullPath,'file') && ~overwrite)
        continue;
    end
    
    % Generate the custom header
    headerFields = {'Authorization', ['Bearer ', dropboxAccessToken]};
    headerFields{2,1} = 'Dropbox-API-Arg';
    headerFields{2,2} = sprintf('{"path": "%s"}',fileNames{i});
    headerFields{3,1} = 'Content-Type';
    headerFields{3,2} = 'application/octet-stream';
    headerFields = string(headerFields);

    % Set the options for WEBREAD
    opt = weboptions;
    opt.MediaType = 'application/octet-stream';
    opt.CharacterEncoding = 'ISO-8859-1';
    opt.RequestMethod = 'post';
    opt.HeaderFields = headerFields;
    opt.Timeout = 30;
    % Download the file
    try
        rawData = webread('https://content.dropboxapi.com/2/files/download', opt);
    catch someException
        waitbar(0,waitbar_0,'Authentication error');
        throw(addCause(MException('downloadFromDropbox:unableToDownloadFile',strcat('Unable to download file:',fileNames{i})),someException));
    end
   
    %Decode the files and save in the downloadPath
    try
        if ~exist(fileparts(fullPath),'dir')
            mkdir(fileparts(fullPath));
        end
        fileID = fopen(fullPath,'w');
        fwrite(fileID,rawData);
        fclose(fileID);
    catch someException
        throw(addCause(MException('downloadFromDropbox:unableToSaveFile', sprintf('Unable to save downloaded file %s in the downloadPath %s',fileNames{i},fullPath)),someException));
    end
    
    %Show wait bar
    completed=i/length(fileNames);
    waitbar(completed,waitbar_0,'Downloading data');

end
close(waitbar_0);              
    
end



function upload(obj,localFileNames,databaseFileNames,varargin)
%
% upload(localFileNames,databaseFileNames,varargin)
%
% upload uses the dropboxAccessToken to upload files from
% a dropbox api (with App folder type access).  
% % 
% fileNames are a cell arrays of filenames to be uploaded
% localFileNames are paths on the computer (source) and databaseFileNames paths on
% the cloud (destination).


% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
%
% 
% To generate a Dropbox access token
% * Go to www.dropbox.com/developers/apps in a web browser
% * Click on "Create app"
% * Select "Dropbox API" and "App folder" for options (1) and (2)
% * Specify the name of the folder you want your files to show up in
% * Click on the "Generate Access Token" on the page and note down the access token


% Check to input arguments
narginchk(1,4);

tries=3;

if ~iscell(localFileNames)
   localFileNames={localFileNames}; 
end


p=inputParser();
%p.addParameter('RepRoot',{},@iscell);
p.parse(varargin{:});


srcFileNames=localFileNames; % location of the files local to the computer

% replace windows fileseparators
for i=1:numel(databaseFileNames)
   databaseFileNames{i}=strrep(databaseFileNames{i}, '\','/');
end

dropboxAccessToken=obj.AuthToken;

waitbar_0 = waitbar(0,'Please wait...');
for i = 1:length(srcFileNames)    
    srcFileName=srcFileNames{i};  
    databaseFileName=databaseFileNames{i};
    
    % Generate the custom header
    headerFields = {'Authorization', ['Bearer ', dropboxAccessToken]};
    headerFields{2,1} = 'Dropbox-API-Arg';
    headerFields{2,2} = sprintf('{"path": "%s", "mode": "add", "autorename": true, "mute": false, "strict_conflict": false}',databaseFileName);    
    headerFields{3,1} = 'Content-Type';
    headerFields{3,2} = 'application/octet-stream';
    headerFields = string(headerFields);

    % Set the options for WEBREAD
    opt = weboptions;
    opt.MediaType = 'application/octet-stream';
    opt.CharacterEncoding = 'ISO-8859-1';
    opt.RequestMethod = 'post';
    opt.HeaderFields = headerFields;
    opt.Timeout = 60;
    % Upload the file 
    fileID = fopen(srcFileName,'r');
    data = char(fread(fileID)');
    fclose(fileID);
    goodUpload=false;
    theException=false;
    for j=1:numel(tries)
        try
            rawData = webwrite('https://content.dropboxapi.com/2/files/upload',data, opt);   
            goodUpload=true;
            break;
        catch someException
            theException=someException;
            continue;
        end
        pause(0.5);
    end
    
    if ~goodUpload
            waitbar(0,waitbar_0,'Authentication error');
            throw(addCause(MException('uploadToDropbox:unableToUploadFile',strcat('Unable to upload file:',databaseFileNames{i})),theException));
    end
    
    %Show wait bar
    completed=i/length(databaseFileNames);
    msg=sprintf('Uploading data %d/%d',i,length(databaseFileNames));
    waitbar(completed,waitbar_0,msg);

end
close(waitbar_0);              
    
end




end
end
