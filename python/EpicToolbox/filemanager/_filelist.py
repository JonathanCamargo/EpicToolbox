import os
import numpy as np
import glob

def fileList(self,dictData=None):
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

    keyList=self.genList(dictData)

    allPaths=[]
    for idx in range(0,len(keyList)):
        a=glob.glob(keyList[idx],recursive=True)
        allPaths=allPaths+a        

    if self.showRoot==False:
        for idx in range(0,len(allPaths)):
            a=allPaths[idx].split(os.sep)
            allPaths[idx]=os.sep.join(a[-len(folderLevels):])

    #print(allPaths)
    return allPaths
