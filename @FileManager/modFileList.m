function fileList=modFileList(obj,fileList,varargin)
% Modify a file list to replace specific entries
% This will use the FileManager folderLevels
%
%
% Default folders for sensor fusion:
% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'Ambulation'  |  []             | Rename ambulation mode
% 'Sensor'      |  []             | Rename sensor
% 'Subject'     |  []             | Rename subject
% 'Date'        |  []             | Rename data
% 'Root'        |  []             | Prepend root path
% 'Ext'         |  []             | Rename file extension


folderLevels=obj.folderLevels;

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
% Adding Parameter varagin
for i=1:(numel(folderLevels))
    p.addParameter(folderLevels{i},[],validStrOrCell);        
end 
p.addParameter('Root',{},validStrOrCell);        
p.addParameter('Ext',{},validStrOrCell);
p.parse(varargin{:});

a=split(fileList,filesep);
if size(a,2)==1
    a=a';
end

%Replace columns with new values
N=numel(folderLevels);
for i=1:N
   content=p.Results.(folderLevels{i});
   if ~iscell(content)
       content = {content};
   end
   if ~(isempty(content{1}))
       s = size(a, 1);
       if (length(content)==1)
           c=repmat(content,s,1);
       elseif (length(content)~=s)
           error('Number of entries for %s do not match the list of files',folderLevels{i});
       else
           c=content;
       end       
            a(:,end-N+i)=c;
   end    
end


if ischar(p.Results.Root)
    if ~isempty(p.Results.Root)
        Root=str2cell(p.Results.Root);
        a=[repmat(Root,size(a,1),1) a(:,end-N+1:end)];
    else
        a=a(:,end-N+1:end);
    end
end

fileList=join(a,filesep);

a=split(fileList,'.');
if size(a,2)==1
    a=a';
end
if ~(isempty(p.Results.Ext))
    Ext=str2cell(p.Results.Ext);
    a=[a(:,1:end-1) repmat(Ext,size(a,1),1)];
end

fileList=join(a,'.');

end
 function out=str2cell(x)
        if (ischar(x))
            out={x};
        end
        if (iscell(x))
            out=x;
        end
    end
