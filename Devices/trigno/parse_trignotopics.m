function [headers,offset] = parse_trignotopics(file_path)
% Read a trigno file and find the channels available
% return the channels as a cell array 
%%
% Reads the trigno file
file=fopen(file_path,'r');

if file == -1
    disp('Error Reading file, check to make sure the path is correct and if file exists')
end

n=0;
while ~feof(file)
    line=fgetl(file);
    n=n+1;
    if startsWith(line,'X [s]')
        offset=n;
        topicnames=returnNames(line);        
        headers=topicnames;
        break;
        %fprintf('%s\n',topicname);
    else
        continue;
    end
end

% From each row 

    function topicnames=returnNames(line)
        result=extractBetween(line,'X [s],','X [s]');
        for i=1:length(result);
            % Asume is the first cell
            topicnames=result{i};
            name=strsplit(topicnames,': ');
            to_cut=regexp(name{end},'\s\d');
            leaf_name=name{end};
            leaf_name=leaf_name(1:to_cut-1);
            leaf_name=strrep(leaf_name,' ','.');
            name{end}=leaf_name;

            topicnames=strjoin(name,'.'); 
            topicnames=strrep(topicnames,' ','_');
            result{i}=strrep(topicnames,' ','_');
        end
        topicnames=result;
    end

end

