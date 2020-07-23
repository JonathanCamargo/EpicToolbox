import os

def getFields(self,fileList,folderLevel):
    '''% From a fileList, retrieve a field based on the pathStructure
    % getFields(obj,fileList,pathStructureField)
    % fileList is a list of files as obtained from fileList
    % function.
    % pathStructureField is a char of the field that you want to
    % retrieve.
    %
    % Example: f=FileManager();
    %          filelist=f.fileList();
    %          f.getFields(fileList,'Trial'); % Retrieves the trial name
    % See also fileList'''


    pos=self.folderLevels.index(folderLevel)
    nlevels=len(self.folderLevels)
    if pos==-1:
        raise(Exception('folderLevel','Folder level '+folderLevel+' not found'))

    # Divide the cell arrays by file separator
    vals=list()
    for file in fileList:
        fields=file.split(os.path.sep)
        ncols=len(fields)
        vals.append(fields[ncols-nlevels+pos])

    return vals
