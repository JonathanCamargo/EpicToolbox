function combine(matfiles,varargin)
% For a list of mat files, combine the data into a single mat file.
%
% combine(matfiles,OPTIONAL)
%
% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'Direction    | 'vertical'/'horizontal'/('auto')  | Which direction to concatentae data
% 'Save'        | (true)/false                      | Save the output into mat files
% 'OutputPath'  | 'loadRunSave_output'              | Directory to save the mat files
% 'OutputName'  | 'combined_data'                   | File Name
% 'Debug'       | true/(false)                      | Print debugging statements

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
% Adding Parameter varagin
p.addParameter('Direction','auto',validStrOrCell);
p.addParameter('Save',true);
p.addParameter('OutputPath','combine_output',validStrOrCell);
p.addParameter('OutputName','combined_data',validStrOrCell);
p.addParameter('Debug',false);
p.parse(varargin{:});

% Get options:
OutputPath=p.Results.OutputPath;

if ischar(OutputPath)
    %Create the list of output paths
    OutputPath=fullfile(p.Results.OutputPath, p.Results.OutputName);
    %Create directories if they do not exist
    [dirname,~,~]=fileparts(OutputPath);
    if ~exist(dirname,'dir')
        mkdir(dirname);
    end
else
    error('Output Path %s not valid', OutputPath);
end

% Save
Save=p.Results.Save;
% Debug
Debug=p.Results.Debug;
% Direction
if(strcmp(p.Results.Direction,'horizontal'))
    Direction=2;
elseif(strcmp(p.Results.Direction , 'vertical'))
    Direction=1;
elseif(strcmp(p.Results.Direction, 'auto'))
    Direction=-1;
else
    error('Directon %s not valid.', p.Results.Direction) ;
end


if (Debug)
    fprintf('Processing %d files:\n',numel(matfiles));
end

combined_data=[];

if Direction > 0
    for i=1:numel(matfiles)
        inputdata=load(matfiles{i});
        in = fieldnames(inputdata);
        inputdata = inputdata.(in{1});
        % Check to see if the dimension of the data matches in the direction
        % that they are not being concatenated in. i.e. The width should match
        % for two tables being vertically concatenated. Can increase this
        % to work in three or more dimensions but right now that
        % functionality is not needed.
        if(size(inputdata,mod(Direction,2)+1) ~= size(combined_data,mod(Direction,2)+1) && i ~= 1)
            warning('Size of files is not consistent')
            if(Debug)
                fprintf('File causing trouble is: %s', matfiles{i});
            end
        end
        
        if(i==1)
            combined_data=inputdata;
        else
            combined_data=cat(Direction,combined_data, inputdata);
        end
    end
    combined_data = {combined_data};%quick fix for 'alldata = combined_data{1};'
else
    j = 1;
    combined_data{j} = [];
    % Intelligent combination of data.
    %Can make this more intelligent. If the headers match, then the user wants
    %to concatenate them verically, but if not, then the user wants to
    %concatenate them horizontally. Makes lists separately and then
    %concatenates them before it gives them back. Throws errors if sizes are
    %not consistent. Can add this as an option. Direction:
    %vertical/horizontal/auto.
    first_data = true;
    for i=1:numel(matfiles)
        found = false;
        inputdata=load(matfiles{i});
        in = fieldnames(inputdata);
        inputdata = inputdata.(in{1});
        if ~isempty(inputdata)
            while(1)
                if(first_data)
                    combined_data{j} = inputdata;
                    first_data = false;
                    break;
                end
                if(strcmp(cell2mat(combined_data{j}.Properties.VariableNames), cell2mat(inputdata.Properties.VariableNames)))
                    combined_data{j}=cat(1,combined_data{j}, inputdata);
                    break;
                else
                    j=j+1;
                    for k=1:length(combined_data)
                        if(strcmp(cell2mat(combined_data{k}.Properties.VariableNames), cell2mat(inputdata.Properties.VariableNames)))
                            j=k;
                            break;
                        end
                    end
                    if j>length(combined_data)
                        first_data = true;
                    end
                end
            end
        end
    end
end

alldata = combined_data{1};

for i=2:length(combined_data)
    if(size(combined_data{i},1)~=size(alldata,1))
        warning('Size of files is not consistent')
        if(Debug)
            fprintf('File causing trouble is: %s', matfiles{i});
        end
    end
    if isempty(intersect(alldata.Properties.VariableNames, combined_data{i}.Properties.VariableNames))
        
        alldata = [alldata, combined_data{i}];
    else
        tmp = innerjoin(alldata, combined_data{i});
        alldata = tmp;
    end
end

dest=OutputPath;
if ~(exist(fileparts(dest),'dir')==2)
    mkdir(fileparts(dest));
end
if(Save)
    save(dest,'alldata');
end

end


