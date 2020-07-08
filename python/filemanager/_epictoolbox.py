import pandas as pd
import h5py
import numpy as np
from joblib import Parallel, delayed
import os

def loadhdf(hdf5file,dataframe=True):
    '''Read data stored on hdf5 file data should
    contain a key 'data' and a field 'names' for the header'''

    with h5py.File(hdf5file, 'r') as f:
        #Read data and names and construct only dataframe
        out_data=f['data'][:]
        out_names_refs=f['names'][:]
        a=[f[obj[0]][:] for obj in out_names_refs]
        names=[''.join([chr(c) for c in b]) for b in a]
        #names=[''.join(chr(c) for c in f[obj[0]]) for obj in out_names_refs]

        if dataframe:
            out=pd.DataFrame(data=np.transpose(out_data),columns=names)
        else:
            out=out_data
    return out


def EpicToolbox(self,fileList,n_jobs=1):
    '''For an list of files from sf_post combine all the sensors
    of the same trial into a mat file matching the structure for usage with
    EpicToolbox. Intended to retrieve data in small chunks without writing
    files.

    trialData=EpicToolbox(fileList)
    Transform data for EpicToolbox

    Combine data from different sensors into one struct
    '''

    pathfields=self.folderLevels
    lastfield=self.folderLevels[-1]

    tolook=[level for level in pathfields[0:-1] if ((level is not 'Sensor') and (level is not 'sensor'))]

    trials=self.getFields(fileList,lastfield)

    if 'Sensor' in pathfields:
        sensors=self.getFields(fileList,'Sensor')
    else:
        sensors=self.getFields(fileList,'sensor')

    individualtrialstbl=pd.DataFrame()
    for field in tolook:
        if field in pathfields:
            vals=pd.Series(self.getFields(fileList,field),name=field)
            individualtrialstbl=pd.concat([individualtrialstbl,vals],axis=1)

    individualtrialstbl=pd.concat([individualtrialstbl,pd.Series(trials,name=lastfield)],axis=1)
    #individualtrialstbl.drop_duplicates()

    combined=individualtrialstbl.apply(lambda x: os.path.sep.join(x), axis=1)
    uniquetrials,uniqueidx=np.unique(combined,return_inverse=True)

    trialdata=[None]*len(uniquetrials)

    alldfs=Parallel(n_jobs=n_jobs)(delayed(loadhdf)(file) for file in fileList)
    #alldfs=[loadhdf(file) for file in fileList]

    for i,df in enumerate(alldfs):
        if trialdata[uniqueidx[i]] is None:
            trialdata[uniqueidx[i]]=dict()
        trialdata[uniqueidx[i]][sensors[i]]=df.copy()
        trialdata[uniqueidx[i]]['info']=individualtrialstbl.loc[uniqueidx[i],:].copy()

    return trialdata
