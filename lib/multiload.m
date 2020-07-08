function data=multiload(fileList)
% Load multiple mat files as a cell array
% multiLoad(fileList)

data=cell(numel(fileList),1);

for i=1:numel(fileList)
    data{i}=load(fileList{i});
end

end

