function loadRunSave(fun,matfiles,varargin)
% For a list of mat files run the function fun on the content of each file
% get the output of the function and save it in a file with the same name.
%
% loadRunSave(fun,matfiles,OPTIONAL);
%
% Where fun is a function handle that receives a struct with the mat file
% content and returns a struct containing the processed output.
%
% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'Save'        | (true)/false        | Save the output into mat files
% 'OutputPath'  | 'loadRunSave_output'|  Directory to save the mat files it
% can also be a cell array with the path of the output matfiles.
% 'Parallel' | true/(false)        | Run in parallel
% 'DataType'    | 'type of data'      | Data type loadRunSave should act on
% 'Debug'       | true/(false)        | Print debugging statements
%
% Other not so frequent functionality
% 'PassFileName' | use file name as the second argument of fun
% 'SimultaneousFiles' | make function operate on multiple inputs and fun too

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
% Adding Parameter varagin
p.addParameter('Save',true);
p.addParameter('Parallel',false);
p.addParameter('OutputPath','loadRunSave_output',validStrOrCell);
p.addParameter('DataType','all');
p.addParameter('Debug',false);
p.addParameter('SimultaneousFiles',{});
p.addParameter('PassFileName',false);
p.addParameter('OverwriteFiles',false);
p.parse(varargin{:});

% Get options:
OutputPath=p.Results.OutputPath;
if iscell(OutputPath) && sum(size(OutputPath)~=size(matfiles))
    error('Wrong dimensions for OutputPath');
end
if ischar(OutputPath)
    %Create the list of output paths
    OutputPath=cell(numel(matfiles),1);
    for i=1:numel(matfiles)
        [~,filename,ext]=fileparts(matfiles{i});
        OutputPath{i}=fullfile(p.Results.OutputPath,[filename ext]);
    end
end

% Create directories if they do not exist
for i=1:numel(OutputPath)
    [dirname,~,~]=fileparts(OutputPath{i});
    if ~exist(dirname,'dir')
        mkdir(dirname);
    end
end

simultaneousFiles = p.Results.SimultaneousFiles;
% if ~isempty(simultaneousFiles) && ~iscell(simultaneousFiles{1})
%     simultaneousFiles = {simultaneousFiles};
% end
if ~isempty(simultaneousFiles)
    assert(numel(matfiles) == size(simultaneousFiles, 1),...
        ['Number of simultaneous files to consider does not match the'...
        ' number of input files to apply the function on'])
end

% Save
Save=p.Results.Save;
% Debug
Debug=p.Results.Debug;
% DataType
DataType=p.Results.DataType;
% Pass File Name
PassFileName=p.Results.PassFileName;
% Overwrite output files
OverwriteFiles=p.Results.OverwriteFiles;

if (Debug)
    fprintf('Processing %d files:\n',numel(matfiles));
end

if p.Results.Parallel
    parfor i=1:numel(matfiles)
        if ~exist(OutputPath{i},'file') || OverwriteFiles
            if (exist(matfiles{i},'file') && ...
                    (isempty(simultaneousFiles) || (~isempty(simultaneousFiles)...
                    && exist(simultaneousFiles{1},'file')))) % fix this
                inputdata=load(matfiles{i});
                if ~strcmp(DataType,'all')
                    %InputData
                    indices = structfun(@(s) strcmp(class(s),DataType),inputdata);
                    data = struct2cell(inputdata);
                    names = fieldnames(inputdata);
                    inputdata = cell2struct(data(indices),names(indices));
                end
                if ~isempty(simultaneousFiles)
                    simuldata = [];
                    for f = 1:size(simultaneousFiles, 2)
                        sd = load(simultaneousFiles{i,f});
                        %SimulData
                        indices = structfun(@(s) strcmp(class(s),DataType),sd);
                        data = struct2cell(sd);
                        names = fieldnames(sd);
                        simuldata = [simuldata; cell2struct(data(indices),names(indices))];
                    end
                    outputdata=feval(fun,inputdata,simuldata);
                else
                    if PassFileName
                        outputdata=feval(fun,inputdata,matfiles{i});
                    else
                        outputdata=feval(fun,inputdata);
                    end
                end
                dest=OutputPath{i};
                if(Save)
                    out=[fieldnames(outputdata) struct2cell(outputdata)]';
                    parsave(dest,out{:});
                end
                if(Debug && Save)
                    fprintf('%s >> %s\n',matfiles{i},dest);
                elseif (Debug && ~Save)
                    fprintf('%s\n',matfiles{i});
                end
            end
        end
    end
else
    for i=1:numel(matfiles)
        if ~exist(OutputPath{i},'file') || OverwriteFiles
            if (exist(matfiles{i},'file') && ...
                    (isempty(simultaneousFiles) || (~isempty(simultaneousFiles)...
                    && exist(simultaneousFiles{1},'file'))))
                inputdata=load(matfiles{i});
                
                if ~strcmp(DataType,'all')
                    indices = structfun(@(s) strcmp(class(s),DataType),inputdata);
                    data = struct2cell(inputdata);
                    names = fieldnames(inputdata);
                    inputdata = cell2struct(data(indices),names(indices));
                end
                if ~isempty(simultaneousFiles)
                    simuldata = [];
                    for f = 1:size(simultaneousFiles, 2)
                        sd = load(simultaneousFiles{i,f});
                        %SimulData
                        indices = structfun(@(s) strcmp(class(s),DataType),sd);
                        data = struct2cell(sd);
                        names = fieldnames(sd);
                        simuldata = [simuldata; cell2struct(data(indices),names(indices))];
                    end
                    outputdata=fun(inputdata,simuldata);
                else
                    if PassFileName
                        outputdata=fun(inputdata,matfiles{i});
                    else
                        outputdata=fun(inputdata);
                    end
                end
                dest=OutputPath{i};
                if(Save)
                    fnames=fieldnames(outputdata);
                    data=struct2cell(outputdata);
                    cellinput=cell(1,2*numel(fnames));
                    cellinput(1:2:end)=fnames;
                    cellinput(2:2:end)=data;
                    parsave(dest,cellinput{:});
                end
                if(Debug && Save)
                    fprintf('%s >> %s\n',matfiles{i},dest);
                elseif (Debug && ~Save)
                    fprintf('%s\n',matfiles{i});
                end
            end
        end
    end
end

end
