from .topics import Topics
from .topics import Topics
import pandas as pd

def GetData(input,x_options,y_options,combine=True,n_jobs=1,filemanager_scope=None,verbose=0):
    '''% GetData retrieves a table of training and a table of testing data from
    % Input can be either a FileManager instance or a cell array with trials
    % from EpicToolbox.
    %
    % [traindata,testdata]=GetData(input,x_options,y_options,varargin)
    %
    % 'Mode'   (RandomHold) % Randomize the trials and hold a subset for test
    %          (Ordered)    % Keep the same order of the input
    % 'Hold'   (5)      % %of How many trials to reserve from the total
    % 'Combine' (true)  % return the data as a single table or as a cell array by trials
    %
    % Returns traindata, testdata and info of the source of data
    '''

    xsensors=list(x_options.keys())
    ysensors=list(y_options.keys())

    #load all the trials
    if filemanager_scope is None:
        filemanager_scope={}

    if type(input) is list:
        #Trial array
        alltrials=input
    else:
        f=input;
        s={'Sensor':[xsensors,ysensors]}
        s.update(filemanager_scope)
        allfiles=f.fileList(s)
        if verbose>0:
            print("Loading {} files".format(len(allfiles)))
        alltrials=f.EpicToolbox(allfiles,n_jobs=n_jobs)
    
    outtrials_x=list()
    for trial in alltrials:
        topics=list(x_options.keys())
        channels=[x_options[topic] for topic in topics]
        outtrial_x=Topics.select(trial,topics,channels)
        outtrials_x.append(outtrial_x)

    outtrials_y=list()
    for trial in alltrials:
        topics=list(y_options.keys())
        channels=[y_options[topic] for topic in topics]
        outtrial_y=Topics.select(trial,topics,channels)
        outtrials_y.append(outtrial_y)

    #all train
    trainIndices=list(range(0,len(alltrials)))
    testIndices=[]

    xTrainTrials=[None]*len(trainIndices)
    yTrainTrials=[None]*len(trainIndices)
    xTestTrials=[None]*len(testIndices)
    yTestTrials=[None]*len(testIndices)

    for i,loc in enumerate(trainIndices):
        xx=Topics.consolidate(outtrials_x[loc],xsensors)
        yy=Topics.consolidate(outtrials_y[loc],ysensors)
        xTrainTrials[i]=xx
        yTrainTrials[i]=yy

    for i,loc in enumerate(testIndices):
        xx=Topics.consolidate(outtrials_x[loc],xsensors)
        yy=Topics.consolidate(outtrials_y[loc],ysensors)
        xTrainTrials[i]=xx
        yTrainTrials[i]=yy

    traindata={'X':xTrainTrials,'Y':yTrainTrials}
    testdata={'X':xTestTrials,'Y':yTestTrials}

    return traindata,testdata
