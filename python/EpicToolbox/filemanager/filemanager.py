import os
import numpy as np
import glob
import warnings

class FileManager:

    def __init__(self,Root=None,PathStructure=None,Ext=None,ShowRoot=True,ScopeDict=None,verbose=0):
        '''
        Optional arguments
        ----------------------------
        'Root': root directory where files are stored
                e.g. '/home/user/data'
        'PathStructure': Levels that describe the structure of how files are stored
                e.g. ['Date','Trial']
        'Ext': if you want to limit file manager to  given file extension
                e.g. 'csv'
        'ShowRoot': include the root path when generating results
        '''
        defaultRoot='RawMatlab'
        defaultPathStructure=['File']

        self.folderLevels=None
        self.root=None
        self.ext=None
        self.showRoot=True
        self.scopeDict={}
        self.verbose=verbose

        if Root==None:
            self.root=defaultRoot
        else:
            self.root=Root

        #Check if root exists or error
        if not os.path.isdir(self.root):
            warnings.warn('Root not existent: '+self.root)

        if PathStructure==None:
            self.folderLevels=defaultPathStructure
        else:
            self.folderLevels=PathStructure
        if Ext==None:
            self.ext='*'
        else:
            self.ext=Ext
        if ScopeDict is not None:
            self.scopeDict=ScopeDict
        else:
            self.scopeDict={}

        self.showRoot=ShowRoot


    from ._filelist import fileList
    from ._modfilelist import modFileList
    from ._genlist import genList

    from ._epictoolbox import EpicToolbox
    from ._getfields import getFields


    def __str__(self):
        a=os.sep.join(self.folderLevels)
        a=os.sep.join([self.root,a])
        a='.'.join([a,self.ext])
        a='\n'.join([a,'Looking for files with scope:'+str(self.scopeDict)])
        return str('FileManager for files in:\n'+a)
