function makePCode(root,addhelp)
 
convertDirectoriesToPCode(root,addhelp);
 
function [] = convertDirectoriesToPCode(path_name,addhelp)
mFiles = dir([path_name filesep '*.m']);
if ~isempty(mFiles)
    pcode(path_name,'-inplace')
    if addhelp
        for i=1:numel(mFiles)
            filepath=fullfile(mFiles(i).folder,mFiles(i).name);
            help2file(filepath,filepath);
        end
    else
        delete([path_name filesep '*.m']);
    end
     
end
sub_directories = getDirectories(path_name);
for ii = 1:length(sub_directories)
    subdir_path_name =  [path_name filesep sub_directories(ii).name];
    convertDirectoriesToPCode(subdir_path_name,addhelp);
end
 
 
function directories = getDirectories(path_name)
directories = struct([]);
count = 1;
 
dirPath = dir(path_name);
 
for ii = 1:length(dirPath)
    if dirPath(ii).isdir
        if strcmp(dirPath(ii).name,'.')
        elseif strcmp(dirPath(ii).name,'..')
        else
            directories(count).name = dirPath(ii).name;
            count = count+1;
        end
    end
end
 
 
function help2file(fname,fhelp)
% HELP2FILE  extract the help informations from a MATLAB file and save it separately
%   the help information will be saved with to the file name fhelp.
mhelp = help(fname);
%fname = [strrep(fname,'.m','') '.m'];
%
fid = fopen(fhelp,'w');
fwrite(fid,['%' strrep(mhelp,newline,sprintf('\n%%'))]);
fclose(fid);