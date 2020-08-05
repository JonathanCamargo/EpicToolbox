import numpy as np
import joblib
from joblib import Parallel, delayed
from scipy import io
import os
from sklearn.base import clone

''' cv helpers
Cross validation helpers to execute training, testing and scoring of models
Models should be compatible with sklearn:
model.fit(X,Y) to train the model
model(X) to predict
'''
def cv_score(model,scorer,X,Y,features=None,cv=None):
    ''' Perform a cross validation scoring
    cvscore(model,scorer,X,Y,cv=None)
    return a tuple containing the average score
    of the cross validation followed by individual cv scores.
    '''
    if features is None:
        features=np.arange(0,X.shape[1])
    X=X[:,features]
    if cv is None:
        modeli = clone(model)
        modeli.fit(X,Y)
        scorei = scorer(modeli,X, Y)
        scores=[scorei]
        other={}
    else:
        scorecvi=[]
        for train, test in cv.split(X):
            modeli = clone(model)
            modeli.fit(X[train, :], Y[train])
            scorecvi.append(scorer(modeli,X[test, :], Y[test]))
        scores=np.mean(scorecvi)
        other={'CVScores':scorecvi}

    return scores,other

def multisubject_cv_score(model,scorer,subjectsX,subjectsY,features=None,cv=None):
    ''' Perform a cross validation scoring for multiple subjects for subject
    dependent models. Calls cvs_core(model,scorer,X,Y,cv=None) on each subject
    and returns the global score (average score across subject) and the within
    subjects within cv scores.
    '''
    if features is None:
        features=np.arange(0,X.shape[1])

    subjectsScores=[]
    subjectsOthers=[]
      
    for i in range(0,len(subjectsX)):
        X=subjectsX[i]
        X=X[:,features]
        #print("Subject{}".format(i))
        #print(X)
        Y=subjectsY[i]
        (subjectScore,subjectOther)=cv_score(model,scorer,X,Y,features=None,cv=cv)
        subjectsScores.append(subjectScore)
        subjectsOthers.append(subjectOther)
    other={'WithinSubjectAvgScore':subjectsScores,'WithinSubjectCVScores':subjectsOthers}
    meanscore=np.mean(subjectsScores)
   
    return (meanscore,other)


class SequentialFeatureSelection:
    ''' Sequential Feature Selection

    A class to do sequential feature selection with open input to evaluation functions and
    progress checkpoint saving.

    #ONLY SUPPORTS FORWARD Right now#

    #How to use:
    # Create a SequentialFeatureSelection object
    SequentialFeatureSelection(criterion_function,total_features,keepin=None,n_jobs=1)

    criterion_fun: function to run and compute the score metric.
    The function must be of form criterion_fun(features). This function must return
    a tuple pair where the first value is a scalar score and the second value a dictionary
    with other outputs to be saved.

    keepin: is a list of feature indices to always keep in the selection

    n_jobs: parallelize to n_jobs


    '''
    def __init__(self,fun,total_features,keepin=None,n_jobs=1,verbose=0):

        self.total_features=total_features #Total number of features

        self.allfeatures=set(range(0,self.total_features))
        self.n_jobs=n_jobs
        self._fun=fun
        self.verbose=verbose
        #self._isready=False #To tell if the object is ready to run the sequential selection

        self._iterations=0 #Number of iterations (both forward or backward increment this)
        self._results={} #List of results (one per iteration)

        # Included is a list of feature indices that went into the selected pool
        if keepin is not None:
            self.included=keepin
        else:
            self.included=[]

    def _funHelper(self,iteration,input):
        out=self._fun(input)
        #return iteration,input,out
        return iteration,out


    def _inclusion(self,included):
        ''' Select one new feature by testing from all the features that have not been
        included by testing the fun with each one of them added

        _inclusion(self,included)

        included is a set of features. Returns bestfeature, bestscore and bestresults
        '''

        if self.verbose>0:
            print("Running inclusion to find features {} + ?".format(included))

        remaining=self.allfeatures - included

        # Use joblib to run the scores in parallel to find the scores for
        # each remaining feature
        if remaining:
            features = len(remaining)
            n_jobs = min(self.n_jobs, features)
            parallel = Parallel(n_jobs=n_jobs, verbose=self.verbose)
            work = parallel(delayed(self._funHelper)
                            (i,tuple(set(included) | {feature}))
                            for i,feature in enumerate(remaining))

            #import pickle
            #filename='/nv/hp22/jcamargoleyva3/data/mierdalast.pck'
            #filehandler = open(filename, 'wb')
            #pickle.dump(work,filehandler)

            #Sort work from index
            index=[a[0] for a in work]
            work=[a[1] for a in work]
            work=[a for _,a in sorted(zip(index,work))]

            allres = np.array(work)
            featscores=[res[0] for res in work]
            other=[res[1] for res in work]

            # Find the new best feature
            idx = np.argmax(featscores)
            bestfeature = list(remaining)[idx]
            bestscore = featscores[idx]
            bestresults = other[idx]

            if self.verbose>0:
                print("Best feature {} added with score {}".format(bestfeature,bestscore))

        return bestfeature, bestscore, bestresults

    def _exclusion(self,included):
        ''' Deselect one new feature by testing from all the features that have been
        makes the best performance.

        _exclusion(self,included)

        included is a set of features. Returns bestfeature, bestscore and bestresults
        '''

        remaining= included

        # Use joblib to run the scores in parallel to find the scores for
        # each remaining feature
        if remaining:
            features = len(remaining)
            n_jobs = min(self.n_jobs, features)
            parallel = Parallel(n_jobs=n_jobs, verbose=self.verbose)
            work = parallel(delayed(self._fun)
                            (tuple(set(self.included) - {feature}))
                            for feature in remaining)

            allres = np.array(work)

            featscores=[res[0] for res in work]
            other=[res[1] for res in work]

            #import pickle
            #filename='/home/ossip/scratch/mierdacasera.pck'
            #filehandler = open(filename, 'wb')
            #pickle.dump(work,filehandler)



            # Find the new best feature
            idx = np.argmax(featscores)
            bestfeature = list(remaining)[idx]
            bestscore = featscores[idx]
            bestresults = other[idx]
        return bestfeature, bestscore, bestresults



    def forward(self,nsteps):
        ''' Run a forward selection process for nsteps'''

        nIncluded=len(self.included)
        # Add nsteps more features
        if len(self.included)<self.total_features:
            if nsteps>self.total_features-nIncluded:
                nsteps=self.total_features-nIncluded

            print("running forward for {} nsteps".format(nsteps))
            for i in range(0,nsteps):
                (bestfeature,bestscore,bestresults)=self._inclusion(set(self.included))
                self.included=list(set(self.included) | set([bestfeature]))
                inclusion_results={'FeaturesIn': self.included,
                              'Score': bestscore,
                              'Other': bestresults}
                self._results[self._iterations]=inclusion_results
                self._iterations=self._iterations+1

        else:
            print("No more features left skipping forward")


    def backward(self,nsteps):
        ''' Run a backward selection (elimination) process for nsteps'''
        nIncluded=len(self.included)
        # Add nsteps more features
        if len(self.included)>0:
            if nIncluded-nsteps<1:
                nsteps=nIncluded+1
                print("bestfeature {}".format(bestfeature))
                print("bestscore {}".format(bestscore))

            print("running forward for {} nsteps".format(nsteps))
            for i in range(0,nsteps):
                (bestfeature,bestscore,bestresults)=self._exclusion(set(self.included))
                #included by testing the fun with each one of them removed and see which one
                self.included=list(set(self.included) - set([bestfeature]))
                exclusion_results={'FeaturesIn': self.included,
                              'Score': bestscore,
                              'Other': bestresults}
                self._results[self._iterations]=exclusion_results
                self._iterations=self._iterations+1


        else:
            print("No more features left skipping forward")




    def load(self,filename):
        ''' Load data from HDF5 file'''
        if not os.path.isfile(filename):
            print('File does not exist'+ filename)
        else:
            try:
                data=io.loadmat(filename,squeeze_me=True)
                print('Previous results file found: ' + filename)
                self._iterations=len(data['FeaturesIn'])
                self.included=data['FeaturesIn'][self._iterations-1]
                for i in range(0,self._iterations):
                    results_dict={'FeaturesIn':data['FeaturesIn'][i],
                                 'Score':data['Score'][i],
                                 'Other':data['Other'][i]}
                    self._results[i]=results_dict


            except Exception as e:
                print("mierda")
                print(e)


    def save(self,filename):
        ''' Save data to HDF5 file
        The results are saved to a mat file containing the variables:
        FeaturesIn: a cell array size N,1 N=number of iterations of the process.
        Score: a cell array with the corresponding scores of each iteration.
        Other: a cell array with the other results collected per iteration.
        '''

        #self.results[i] is the ith iteration of results to be saved it is a
        #dictionary containing FeaturesIn, Score and Other

        featuresIn=[self._results[i]['FeaturesIn'] for i in range(0,self._iterations)]
        score=[self._results[i]['Score'] for i in range(0,self._iterations)]
        other=[self._results[i]['Other'] for i in range(0,self._iterations)]

        results={'FeaturesIn':featuresIn,
                 'Score':score,
                 'Other':other}
        io.savemat(filename,results)

    def __str__(self):
        strmsg='Sequential Feature Selection\n'
        strmsg=strmsg+'Iterations completed: {}\n'.format(self._iterations)
        strmsg=strmsg+'Total possible features: {}\n'.format(self.total_features)
        strmsg=strmsg+'Features In: {}\n'.format(self.included)
        return strmsg
