import os
def modFileList(self,fileList,dictData=None):
    '''
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
    % 'ext'         |  []             | Modify extension
    '''
    splitFileList=[];

    if dictData==None:
        dictData={}

    folderLevels=self.folderLevels
    #print(fileList)

    newfileList=fileList.copy()

    for i in range(0,len(newfileList)):
        a=newfileList[i].split(os.sep)
        splitFileList.append(a)

    #print(splitFileList)
    n=len(folderLevels)
    for levelIdx,level in enumerate(folderLevels):
        if level in dictData:
            for i in range(0,len(newfileList)):
                splitFileList[i][-n+levelIdx]=dictData[level]

    for i in range(0,len(newfileList)):
        a=os.sep.join(splitFileList[i])
        newfileList[i]=a

    if 'Root' in dictData:
        for i in range(0,len(newfileList)):
            a=newfileList[i]            
            a=a.replace(self.root,dictData['Root'])
            newfileList[i]=a        
        

    if 'ext' in dictData:
        for i in range(0,len(newfileList)):
            a=os.path.splitext(newfileList[i])[0]
            a='.'.join([a,dictData['ext']])
            newfileList[i]=a

    return newfileList
