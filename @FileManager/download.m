function download(input)
% Load a dataset from the Database
% 
% input can be a parameters struct or a list of files obtained from
% fileList
% params should contain ambulation,sensor,subject,trial_date
%
% e.g 
% params.study='SF_Study_f2018'
% params.ambulation='Treadmill';
% params.subject={'AB01','AB02'};
% sf_download(params);
% see also: fileList
% 
%
%
%

% This will download the files into a RawMatlab folder inside pwd

%% DATA_PATH for our repository of experiment data
DATA_PATH=getenv('SF_POST_DATA');
if (isempty(DATA_PATH))
    DATA_PATH='~/Dropbox/EPIC_DATASETS/sf_post_data/'; 
    msg=['Using default origin of sf_post_data:',DATA_PATH];
    warning(msg);
end
if ~(exist(DATA_PATH,'dir'))
        error('sf_post_data not found');  
end
%%
if isstruct(input)
    params=input;
    % Extract params and run the functions with arguments    
    Study=isfieldOrStar(params,'study');
    Sensor=isfieldOrStar(params,'sensor');
    Subject=isfieldOrStar(params,'subject');
    Ambulation=isfieldOrStar(params,'ambulation');
    Date=isfieldOrStar(params,'trial_date');
    DATA_PATH=[DATA_PATH filesep Study];
    % Get the list of files that match the desired download
    fileList=FileManager.fileList('Root',DATA_PATH,'Ambulation',Ambulation,'Sensor',Sensor,'Subject',Subject,'Date',Date);
    % Copy files from Root folder to the destination folder
elseif iscell(input)
    fileList=input;
else
    error('Wrong input');
end

%For each sensor/subject/ take the data from sf_post_data and create the
%folder structures.
folder_path='RawMatlab';
if (~exist(folder_path,'dir'))
    mkdir(folder_path);
end
DEST_PATH=fullfile(pwd,folder_path);


for i=1:numel(fileList)
    % Create directory if does not exist
    outfile=fullfile(DEST_PATH,fileList{i});
    fprintf('%s\n',outfile);
    [dirname,~,~]=fileparts(outfile);    
    if ~exist(dirname,'dir')
        mkdir(dirname);
    end
    copyfile(fullfile(DATA_PATH,fileList{i}),outfile);
end


function out=isfieldOrStar(params,field)
    if (isfield(params,field))
        out=params.(field);
    else
        out='*';
    end
end
end