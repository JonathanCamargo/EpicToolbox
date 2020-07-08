function applyFunction(fun,params)
% Run a function passed as a function handle to every file in the structure
% Save the results of postprocessing in a similar structure of files.
% 
% 
% % params.subject
% ...etc
% params.DATA_PATH : Path were the source data is stored
% params.DEST_PATH : Path were the processed data will be placed
% 
% params.save : (true)/false  Save output of function in individual files


DATA_PATH='';
DEST_PATH='';

checkPaths(params);

params.possible_tags = ReadYaml('tags.yaml');

checkNames(params)
checkDateAndTrials(params)

p=params;
for i = 1:length(p.ambulation)
    for j = 1:length(p.sensors)
            for k = 1:length(p.trial_date)
                 path = fullfile(DATA_PATH,p.ambulation{i},p.sensors{j},...
                   p.subject{k},p.trial_date{k}); % Change this to match file hierarchy if changing file hierarchy            
                 directory = dir(fullfile(path,'*.mat'));
            if (2 == length(directory))
                error([directory(1).folder ' contains no files']);
            end
            if strcmp(p.trials,'all') == 0
                for l = 1:length(p.trials)
                    if isempty(intersect({directory.name}, {p.trials{l}}))
                        error(['Trial ' p.trials{l} ' not contained in ' directory(1).folder]);                    
                    else
                       src_dir=fullfile(DATA_PATH,p.ambulation{i},p.sensors{j},p.subject{k},p.trial_date{k});
                       src=fullfile(src_dir,p.trials{l});
                       dest_dir=fullfile(DEST_PATH,p.ambulation{i},p.sensors{j},p.subject{k},p.trial_date{k});                                                                                                
                       if (~(exist(dest_dir,'dir')))
                           warning('%s directory does not exist, creating...',dest_dir);
                           mkdir(dest_dir);
                       end
                       dest=fullfile(dest_dir,p.trials{l});
                       
                       inputdata=load(src);
                       outputdata=fun(inputdata);
                       save(dest,'-struct','outputdata');                       

                    end
                end            
            else
                 p.trials={directory.name};
                 for l = 1:length(p.trials)
                       src_dir=fullfile(DATA_PATH,p.ambulation{i},p.sensors{j},p.subject{k},p.trial_date{k});
                       src=fullfile(src_dir,p.trials{l});
                       dest_dir=fullfile(DEST_PATH,p.ambulation{i},p.sensors{j},p.subject{k},p.trial_date{k});                                                                                                
                       dest=fullfile(dest_dir,p.trials{l}); 
                       %mkdir(dest_dir);
                       %copyfile(src,dest,'f');
                       if (~(exist(dest_dir,'dir')))
                           warning('%s directory does not exist, creating...',dest_dir);
                           mkdir(dest_dir);
                       end
                       inputdata=load(src);
                       outputdata=fun(inputdata);
                       save(dest,'-struct','outputdata');                      
                       
                 end                       
            end 
            end
    end
end



function checkNames(p)
    %  Check Tags
    % Check sensors
    p.possible_tags
    checkTags(p.sensors, p.possible_tags.sensors, 'sensor');
    % Check ambulation
    %checkTags(p.ambulation, fields(p.possible_tags.ambulation), 'ambulation mode');
    % Check estimation
    %for ambulation_mode = 1:length(p.ambulation)
    %    checkTags(p.estimation, p.possible_tags.ambulation.(p.ambulation{ambulation_mode}), ...
    %        ['estimation mode for ' p.ambulation{ambulation_mode}]);
    %end
end

function checkTags(p_tag, possible_tags, description)
for i = 1:length(p_tag)
    if isempty(intersect(possible_tags, p_tag(i)))
        error([p_tag{i} ' is not a valid ' description '. Please check ' ...
            'whether it is meant to be, and if so, add it to DATASETS/tags.yaml'])
    end
end
end

function checkDateAndTrials(p)
    for i = 1:length(p.ambulation)
        for j = 1:length(p.sensors)
            for k = 1:length(p.trial_date)
                path = fullfile(DATA_PATH,p.ambulation{i},p.sensors{j},...
                    p.subject{k},p.trial_date{k}); % Change this to match file hierarchy if changing file hierarchy
                if (0 == exist(path, 'dir'))
                    error([path ' does not exist']);
                end
                directory = dir(path);
                if (2 == length(directory))
                    error([directory(1).folder ' contains no files']);
                end
                if strcmp(p.trials,'all') == 0
                    for l = 1:length(p.trials)
                        if isempty(intersect({directory.name}, {p.trials{l}}))
                            error(['Trial ' p.trials{l} ' not contained in ' directory(1).folder]);
                        else
                            
                        end
                    end
                end
            end
        end
    end
end

function names = generateNames(p, path, varargin)
all_combinations = allcomb(varargin{:});
names = cell(size(all_combinations,1),1);
for i = 1:size(all_combinations,1)
    names{i} = path;
    for j = 1:size(all_combinations,2)
        names{i} = [names{i} '/' all_combinations{i, j}];
    end
end
end

function checkDimension(description, varargin)
for i = 2:length(varargin)
    if size(varargin{1}) ~= size(varargin{i})
        error(['Size of ' description ' do not match']);
    end
end
end

function checkExtractor(description, sensors, extractor)
checkDimension(description, sensors, extractor);
extractor_sensors = fields(extractor);
for i = 1:length(extractor_sensors)
    if isempty(intersect(sensors, extractor_sensors(i)))
        error(['Mismatch in params.sensors, and params.extractor. Please make sure ' ...
            'that the extractor objects match the sensors listed.']);
    end
end
end

function checkPaths(params)
    %For each file in the structure 
    %folder structures.
    if (isfield(params,'DATA_PATH'))
        folder_path=params.DATA_PATH;
    else
        folder_path='RawMatlab';
    end
    if (~exist(folder_path,'dir'))
     error('Origin folder %s not found',folder_path);
    end
    DATA_PATH=folder_path;

    
    if (isfield(params,'DEST_PATH'))
        folder_path=params.DEST_PATH;
    else
        folder_path='ProcessedData';
    end
    if (~exist(folder_path,'dir'))
        warning('Creating destination folder %s',folder_path);
    end
    DEST_PATH=folder_path;
end
end
