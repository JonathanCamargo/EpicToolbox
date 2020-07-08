function replicateValues(values,sensorPath, varargin)
% This function takes in a path to a set of discrete values, and
% a path that the algorithm should replicate. The algorithm should output
% the same file structure as desiredPath, with each file having the same
% height as the files in desiredPath. The total number of values in the mat
% files within the valuePath folders must be the same as teh total number
% of values in desiredPath
%
% replicateValues(valuePath,desiredPath,OPTIONAL);
%
% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'Save'        | (true)/false        | Save the output into mat files
% 'OutputPath'  | 'loadRunSave_output'|  Directory to save the mat files it
% can also be a cell array with the path of the output matfiles.
% 'Debug'       | true/(false)        | Print debugging statements

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
% Adding Parameter varagin
p.addParameter('Save',true);
p.addParameter('OutputPath','replicateValues_output',validStrOrCell);
p.addParameter('Name','replicatedValue',validStrOrCell);
p.addParameter('Debug',false);
p.parse(varargin{:});

% Get options:
OutputPath=p.Results.OutputPath;
if iscell(OutputPath) && sum(size(OutputPath)~=size(sensorPath))
    error('Wrong dimensions for OutputPath');
end
% if ischar(OutputPath)
%     %Create the list of output paths
%     OutputPath=cell(numel(sensorList),1);
%     for i=1:numel(sensorList)
%         [~,filename,ext]=fileparts(sensorList);
%         OutputPath{i}=fullfile(p.Results.OutputPath,[filename ext]);
%     end
% end

% Create directories if they do not exist
if ~exist(fileparts(OutputPath),'dir')
    mkdir(fileparts(OutputPath));
end

% Save
Save=p.Results.Save;
% Debug
Debug=p.Results.Debug;
% Name
Name=p.Results.Name;

if (Debug)
    fprintf('Processing %d values:\n',numel(values));
end


for i=1:numel(values)
    m=matfile(sensorPath);
    dataSize=size(m.data,1);
    replicatedValue.data=table(repelem(values(i),dataSize)','VariableNames',{Name});
    if(Save)
        save(OutputPath,'-struct','replicatedValue');
    end
end

end