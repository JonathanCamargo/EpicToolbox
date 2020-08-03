import os
import numpy as np
import glob

def genList(self,dictData=None):
    '''
    Retrieve the list of files that match the regexp given by Parameter inputs
    according to folder levels.

    This will use the FileManager folderLevels

    Default folders for sensor fusion:
    Options: name value pairs (for sensor fusion folder structure
    ----------------------------------------------
    name    value1/value2/(default)  Description
    ----------------------------------------------
    'Ambulation'  | ('*')         | Ambulation mode
    'Sensor'      | ('*')         |
    'Subject'     | ('*')         |
    'Date'        | ('*')         |
    'Trial'       | ('*')         |
    'Root'        | ('RawMatlab') | Input folder name
    '''
    folderLevels=self.folderLevels
    Root=self.root

    if dictData==None:
        dictData={}    	    	

    n=[]
    for i,level in enumerate(folderLevels):
        if level not in dictData:
            if level not in self.scopeDict:
                dictData[level]=['*']
            else:
                dictData[level]=self.scopeDict[level]
        if not isinstance(dictData[level],list):
            dictData[level]=[dictData[level]]
        n.append(np.arange(0,len(dictData[level])))

    combIdx=np.array(np.meshgrid(*n)).T.reshape(-1,len(folderLevels))
    keyList=[]
    for idx in range(0,len(combIdx)):
        contentIndices=combIdx[idx]
        searchPath=[]
        for i in range(0,len(folderLevels)):
            content=dictData[folderLevels[i]][contentIndices[i]]
            searchPath.append(content)
        searchPath=os.sep.join([Root,*searchPath])
        keyList.append(searchPath)

    return keyList    
