function movefiles(source,destination,varargin)
% movefile with support for multiple files 
% Options:
% 'Overwrite' (true)

p=inputParser();
p.addParameter('Overwrite',true,@islogical);

parse(p,varargin{:});

isOverWrite=p.Results.Overwrite;

    for i=1:size(source,1)
        mkdirfile(destination{i});
        if ~isOverWrite
            if ~exist(destination{i},'file')
                movefile(source{i},destination{i});
            end
        else    
                movefile(source{i},destination{i});
        end     
    end
end
