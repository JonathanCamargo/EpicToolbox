import pandas as pd
import logging

class Topics():

    # Not sure if we want this to be a tuple (immutable), #TODO add any other relevant topics needing to be processed by default (*must include a header)
    defaultTopics=['/ankle/joint_state', '/knee/joint_state', '/wrench', '/fsm/State', '/fsm/wrench', '/fsm/ankle/joint_state', '/fsm/knee/joint_state',
    '/imu/foot/Accel', '/imu/foot/Gyro', '/imu/shank/Accel', '/imu/shank/Gyro', '/imu/thigh/Accel', '/imu/thigh/Gyro',
    '/ankle/scaled_params', '/knee/scaled_params']

    selectTopics = ['/ankle/joint_state']

    @staticmethod
    def topics(trialdata):
        ''' Get all the topic names within a trialdata'''
        for i in fields(trialdata):
            thisbranch=trialdata[i]
            if thisbranch is pd.Dataframe:
                '''This is a topic'''
                topics.append(i)
            elif thisbranch is dict:
                '''This is a branch'''
                topics.append(i)
        return topics

    @staticmethod
    def chooseTopics(topics):
        if topics is None:
                topics=Topics.defaultTopics
        if not type(topics) is list:
                topics=[topics]
        return topics

    @staticmethod
    def processFunc(trialdata,lambdafun,topics=None):
        '''Process multiple topics by a given function lambdafun'''
        topics=Topics.chooseTopics(topics)
        out=trialdata.copy()
        for i in range(len(topics)):
            try:
                # print(topics[i])
                out[topics[i]]=lambdafun(out[topics[i]])
            except:
                print(topics[i]+' can''t be processed with function'+str(lambdafun))
        # for topic in topics:
        #     print(topics)
        #     trialdata[topic]=lambdafun(trialdata[topic])
        return out

    @staticmethod
    def consolidate(trialdata,topics=None):
        ''' Consolidates different topics into the same dataframe'''
        topics=Topics.chooseTopics(topics)
        firstopic=topics[0]
        alltables=[trialdata[firstopic],]
        for topic in topics[1:]:
            if 'Header' in trialdata[topic].columns:
                tbl=trialdata[topic].drop('Header',axis='columns')
            else:
                tbl=trialdata[topic]
            alltables.append(tbl)
        out=pd.concat(alltables,sort=True,axis=1)
        return out

    @staticmethod
    def cut(trialdata,tinitial,tfinal,topics=None):
        ''' Cuts the trial data from an initial time (tinitial)
        to a final time (tfinal).
        '''
        topics=Topics.chooseTopics(topics)

        cutFcn = lambda d: d[(d.header>=tinitial) & (d.header<=tfinal)]
        cutData = Topics.processFunc(trialdata,cutFcn,topics)

        return cutData

    @staticmethod
    def findShiftTime(trialdata,topics=None):
        ''' Find the latest message across the first messages in the
        trial topics'''

        #loop over topics and collect the first header time
        topics = Topics.chooseTopics(topics)
        findFirstTimeFun=lambda d : d.header.iloc[0]

        s = Topics.processFunc(trialdata,findFirstTimeFun,topics)
        times=[]

        for topic in topics:
            if not topic in s:
                logging.warn('Topic '+topic+' not in trial data') # TODO nicer warnings
            else:
                times.append(s[topic])

        # find the maximum
        maxHeader=max(times)

        return maxHeader

    @staticmethod
    def findLastTime(trialdata,topics=None):
        ''' Find the earliest message across the last messages in the
        trial topics'''

        #loop over topics and collect the first header time
        topics = Topics.chooseTopics(topics)

        findLastTimeFun=lambda d : d.header.iloc[-1]

        s = Topics.processFunc(trialdata,findLastTimeFun,topics)
        times=[]

        for topic in topics:
            if not topic in s:
                logging.warn('Topic '+topic+' not in trial data') # TODO nicer warnings
            else:
                times.appendS(s[topic])

        # find the maximum
        minHeader=min(times)

        return minHeader

    @staticmethod
    def select(trialdata,topics=None,channels=None):
        ''' Select some specific and channels topics from the trial'''
        topics = Topics.chooseTopics(topics)

        if channels is None:
            channels=[['.']]*len(topics)

        if not (type(channels) is list):
            #channel is just string, repeat as many topics we have
            channels=[[channels]]*len(topics)
        elif not (type(channels[0]) is list):
            #Only one channel and user was lazy to add extra bracket
            channels=[channels]*len(topics)

        if not len(channels)==len(topics):
            Exception('Wrong size of arguments, channels should have the same elements as topics')

        z={}
        for (topic,topicchannels) in zip(topics,channels):
            if topic in trialdata:
                #Get the channels for that topic
                thisChannels=trialdata[topic].columns
                boolSelector=pd.Series([False]*len(thisChannels))
                for channel in topicchannels:
                    boolSelector=boolSelector | thisChannels.str.contains(pat=channel)

                selectedColumns=trialdata[topic].columns[boolSelector]
                z[topic]=trialdata[topic][selectedColumns]
        return z

    @staticmethod
    def segment(trialdata, times, topics = None):
        ''' Segment data based of a pair of time inputs (i.e. [1.0, 2.0])
        test = Topics.segment(trial, [[5, 10],[10, 15]])
        print(test[0])
        print(test[1])
        '''

        segments=[]
        for section in times:
            start=section[0]
            end=section[1]
            z=Topics.cut(trialdata,start,end)
            segments.append(z)

        return segments

    @staticmethod
    def plot(trialdata, topics=None, channels=None):
        pass
        #General function that allows one to plot any topic inside our list of all topics
        #TODO plot data similar to postLook.m

        # Example of actual use of function
        # Topics.plot(z,'/ankle/joint_state',['theta'])

    @staticmethod
    def normalizeData(trialdata, factor, topics = None, channels = None):
        ''' normalizeData processes a topics with some basic operation which include:
    1.  TODO EXPLAIN
    2.
    3.
    Factor is the normalization vector that contains min/max for each topic from baseline condition (i.e. LW trial)

    '''

        return n
