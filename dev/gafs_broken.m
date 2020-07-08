function [in,history] = gafs(fun,varargin)
%gafs Sequential feature selection.
%
%   INMODEL = GAFS(FUN,X,Y) selects a subset of features from X
%   that best predict the data in Y, by using genetic algorithms for selecting features
%   until there is no improvement in prediction.  X is a data matrix whose
%   rows correspond to points (or observations) and whose columns
%   correspond to features (or predictor variables). Y is a column vector
%   of response values or class labels for each observations in X.  X and Y
%   must have the same number of rows.  FUN is a function handle, created
%   using @, that defines the criterion that gafs uses to select
%   features and to determine when to stop. gafs returns INMODEL, a
%   logical vector indicating which features are finally chosen.
%
%   Starting from an empty feature set, gafs creates candidate
%   feature subsets by adding in each of the features not yet selected. For
%   each candidate feature subset, GAFS performs 10-fold
%   cross-validation by repeatedly calling FUN with different training and
%   test subsets of X and Y, as follows:
%
%      CRITERION = FUN(XTRAIN,YTRAIN,XTEST,YTEST)
%
%   XTRAIN and YTRAIN contain the same subset of rows of X and Y, while
%   XTEST and YTEST contain the complementary subset of rows.  XTRAIN and
%   XTEST contain the data taken from the columns of X that correspond to
%   the current candidate feature set.
%
%   Each time it is called, FUN must return a scalar value CRITERION.
%   Typically, FUN uses XTRAIN and YTRAIN to train or fit a model, then
%   predicts values for XTEST using that model, and finally returns some
%   measure of distance or loss of those predicted values from YTEST. In
%   the cross-validation calculation for a given candidate feature set,
%   GAFS sums the values returned by FUN across all test sets, and
%   divides that sum by the total number of test observations. It then uses
%   that mean value to evaluate each candidate feature subset. Two commonly
%   used loss measures for FUN are the sum of squared errors for regression
%   models (GAFS computes the mean squared error in this case), and
%   the number of misclassified observations for classification models
%   (GAFS computes the misclassification rate in this case).
%
%   Note: GAFS divides the sum of the values returned by FUN across
%   all test sets by the total number of test observations, therefore FUN
%   should not divide its output value by the number of test observations.
%   At this time, GAFS does not accept 'table' as input.
%
%   Given the mean CRITERION values for each candidate feature subset,
%   GAFS chooses the one that minimizes the mean CRITERION value.
%   This process continues until adding more features does not decrease the
%   criterion.
%
%   [INMODEL,HISTORY] = GAFS(FUN,X,...) returns information on
%   which feature is chosen in each step.  HISTORY is a scalar structure
%   with the following fields:
%
%         Crit   A vector containing the criterion values computed at each
%                step. 
%         In     A logical matrix in which row I indicates which features
%                are included at step I.
%
%   [...] = GAFS(..., 'PARAM1',val1, 'PARAM2',val2, ...) specifies
%   one or more of the following name/value pairs:
%
%   'CV'        The validation method used to compute the criterion for
%               each candidate feature subset.  Choices are:
%               a positive integer K - Use K-fold cross-validation (without
%                                      stratification). K should be greater
%                                      than one.
%               a CVPARTITION object - Perform cross-validation specified
%                                      by the CVPARTITION object.
%               'resubstitution'     - Use resubstitution, i.e., the
%                                      original data are passed
%                                      to FUN as both the training and test
%                                      data to compute the criterion. 
%               'none'               - Call FUN as CRITERION =
%                                      FUN(X,Y,Z,...), without separating
%                                      test and training sets.  
%               The default value of 'CV' is 10, i.e., 10-fold
%               cross-validation (without stratification).
%
%               So-called "wrapper" methods use a function FUN that
%               implements a learning algorithm. These methods usually
%               apply cross-validation to select features. So-called
%               "filter" methods use a function that measures the
%               characteristics (such as correlation) of the data to select
%               features.
%
%   'MCReps'    A positive integer indicating the number of Monte-Carlo
%               repetitions for cross-validation.  The default value is 1.
%               'MCReps' must be 1 if 'CV' is 'none' or 'resubstitution'.
%
%   'Direction' The direction in which to perform the sequential search.
%               The default is 'forward'.  If 'Direction' is 'backward',
%               GAFS begins with a feature set including all
%               features and removes features sequentially until the
%               criterion increases.
%
%   'KeepIn'    A logical vector, or a vector of column numbers, specifying a
%               set of features which must be included.  The default is
%               empty.
%
%   'KeepOut'   A logical vector, or a vector of column numbers, specifying a
%               set of features which must be excluded.  The default is
%               empty.
%
%   'NFeatures' The number of features at which GAFS should stop.
%               INMODEL includes exactly this many features.  The default
%               value is empty, indicating that GAFS should stop
%               when a local minimum of the criterion is found.  A
%               non-empty value for 'NFeatures' overrides 'MaxIter' and
%               'TolFun' in 'Options'.
%
%   'NullModel' A logical value, indicating whether or not the null model
%               (containing no features from X) should be included in the
%               feature selection procedure and in the HISTORY output.  The
%               default is FALSE.
%
%   'Options'   Options structure for the iterative sequential search
%               algorithm, as created by STATSET.  GAFS uses the
%               following fields:
%
%        'Display'       Level of display output.  Choices are 'off' (the
%                        default), 'final', and 'iter'.
%        'MaxIter'       Maximum number of steps allowed.  The default is
%                        Inf. 
%        'TolFun'        Positive number giving the termination tolerance
%                        for the criterion.  The default is 1e-6 if
%                        'Direction' is 'forward', or 0 if 'Direction' is
%                        'backward'.
%        'TolTypeFun'    'abs', to use 'TolFun' as an absolute tolerance, or
%                        'rel', to use it as a relative tolerance. The
%                        default is 'rel'.
%        'UseParallel'
%        'UseSubstreams'
%        'Streams'       These fields specify whether to perform cross-
%                        validation computations in parallel, and how to use 
%                        random numbers during cross-validation. 
%                        For information on these fields see PARALLELSTATS.
%                        NOTE: If supplied, 'Streams' must be of length one.
%
%   Examples:
%      % Perform sequential feature selection for CLASSIFY on iris data with
%      % noisy features and see which non-noise features are important
%      load('fisheriris');
%      X = randn(150,10);
%      X(:,[1 3 5 7 ])= meas;
%      y = species;
%      opt = statset('display','iter');
%      % Generating a stratified partition is usually preferred to
%      % evaluate classification algorithms.
%      cvp = cvpartition(y,'k',10); 
%      [fs,history] = GAFS(@classf,X,y,'cv',cvp,'options',opt);
% 
%      where CLASSF is a MATLAB function such as:
%      function err = classf(xtrain,ytrain,xtest,ytest)
%        yfit = classify(xtest,xtrain,ytrain,'quadratic');
%        err = sum(~strcmp(ytest,yfit));
%
%   See also CVPARTITION, CROSSVAL, STEPWISEFIT, PARALLELSTATS.

% References:
%   [1] John G. Kohavi R. (1997) Wrappers for feature subset selection,
%   Artificial Intelligence, Vol. 97, No. 1-2, pp. 272-324

% Copyright 2008-2012 The MathWorks, Inc.


if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(2,Inf);

if ~isa(fun,'function_handle')
    error(message('stats:gafs:BadFun'));
end

n = size(varargin{1},1);
if n < 2
    error(message('stats:gafs:TooFewDataRows'));
end
X = varargin{1};
nData = length(varargin);
if isa(X, 'table')
    error(message('stats:gafs:InvalidTableInput'));
end
for i = 2:length(varargin)
    if ~(ischar(varargin{i}) && size(varargin{i},1) ==1 )
        if size(varargin{i},1) ~= n
            error(message('stats:gafs:MismatchedDataRows'));
        end
        if isa(varargin{i}, 'table')
            error(message('stats:gafs:InvalidTableInput'));
        end
    else
        nData = i-1;
        break;
    end
end
other_data = cell(0);
if nData > 1
    other_data = varargin(2:nData);
end
varargin(1:nData)= [];

% parse input and error check
okargs = {'direction' 'keepin' 'keepout'  'options'   'cv' 'mcreps' 'nfeatures' 'nullmodel'};
defaults = {'forward'   []        []         []       10   1       []            false};
[direction,keepin,keepout,options,cv,mcreps,nfs,nullmodel] = ...
    internal.stats.parseArgs(okargs,defaults,varargin{:});

direction = internal.stats.getParamVal(direction,{'forward', 'backward'},'''Direction''');

% Organize UseParallel, UseSubstreams and Stream options 
% to be passed to CROSSVAL. These are also used when/if gafs
% creates a K-fold type CVPARTITION.
%
defaultOptions = statset();
defaultOptions.MaxIter = Inf;
defaultOptions.TolTypeFun = 'rel';
defaultOptions.UseParallel = false;
                defaultOptions.UseSubstreams = false;
                defaultOptions.Streams = {};

options = statset(defaultOptions, options);
options.Display = find(strcmpi(options.Display, {'off','notify','final','iter'})) - 1; % already validated by statset
%0-off; 1-notify; 2-final;3-iter.

ParOptions = statset('crossval');
ParOptions.UseParallel   = options.UseParallel;
ParOptions.UseSubstreams = options.UseSubstreams;
ParOptions.Streams       = options.Streams;

% Set the default value of TolFun
if isempty(options.TolFun)
    if strcmp(direction,'forward')
        options.TolFun = 1e-6;
    else
        options.TolFun = 0;
    end
end

p = size(X,2);
keepin = checkkeepvec(keepin,p,'Keepin');
keepout = checkkeepvec(keepout,p,'Keepout');
if any(keepin & keepout)
    error(message('stats:gafs:KeepInOutConflict'));
end

if ~( isnumeric(mcreps) && isscalar(mcreps) && mcreps == round(mcreps)...
        && mcreps >= 1)
    error(message('stats:gafs:BadMcreps'));
end

if isnumeric(cv)
    if isscalar(cv) && cv > 2 && round(cv) == cv %K-fold
        % This is a valid K-fold value.
        % If the command line passed UseSubstreams and/or Stream options,
        % we must create a cvpartition consistent with those options.
        [~, RNGscheme, ~] = ... % [useParallel, RNGscheme, poolsz]
            internal.stats.parallel.processParallelAndStreamOptions(options,false);
        if ~isempty(RNGscheme.streams)
            S = RNGscheme.streams{1};
            cv = cvpartition(n,'kfold',cv,S);
            if RNGscheme.useSubstreams
                S.Substream = S.Substream+1;
            end
        else
            cv = cvpartition(n,'kfold',cv);
        end
    else
        error(message('stats:gafs:Badcv'));
    end
elseif ischar(cv)
    cvNames = {'resubstitution','none',};
    j = find(strncmpi(cv, cvNames, length(cv)));
    if isempty(j)
        error(message('stats:gafs:Badcv'));
    end
    if mcreps ~= 1
        warning(message('stats:gafs:CVMcrepsMismatched'));
        mcreps =  1;
    end
    if j == 1
        cv = cvpartition(n,'resubstitution');
    end

else
    if ~isa(cv,'cvpartition')
        error(message('stats:gafs:Badcv'));
    elseif  mcreps > 1 && (strcmp(cv.Type,'resubstitution') ...
            || strcmp(cv.Type,'leaveout'))
        mcreps = 1;
        warning(message('stats:gafs:InvalidMcreps'));
    end
end

if ~isempty(nfs)
    if ~isnumeric(nfs) || ~isscalar(nfs) || round(nfs) ~= nfs ||...
            nfs < 0 || nfs > p
        error(message('stats:gafs:BadNfs'));
    else
        if any(keepin) && sum(keepin) > nfs
            error(message('stats:gafs:InvalidNfsTooSmall'));
        end
        if  any(keepout) && p-sum(keepout) < nfs
            error(message('stats:gafs:InvalidNfsTooLarge'));
        end

    end
end

history.In = false(0,0);
history.Crit = [];
switch direction
    case 'forward'
        % Sequential forward selection
        in = keepin;
        if  ~isempty(find(in,1)) || nullmodel 
            %evaluate the initial model
            x = X(:,in);
            initCrit = callfun(fun,x,other_data,cv,mcreps,ParOptions);
            history.In = [history.In; in];
            history.Crit = [history.Crit, initCrit];
        end

        if options.Display > 1
            disp(getString(message('stats:gafs:StartForward')));
            fprintf('%s',getString(message('stats:gafs:InitialColumns',makeColText(keepin,p))));
            fprintf('%s',getString(message('stats:gafs:ColumnsNotBeIncluded',makeColText(keepout,p))));
            if ~isempty(find(in,1)) || nullmodel
                fprintf('%s',getString(message('stats:gafs:Step1InitialColumnsCriterion',sprintf('%g',history.Crit(end)))));
            end
             
        end

        nStart = sum(~in & ~keepout);
        for j = 1:nStart
            if  ~isempty(nfs)
                if sum(in) >= nfs
                    break;
                end
            elseif j > options.MaxIter
                break;
            end

            x = [X(:,in), zeros(n,1)];
            available = find(~in & ~keepout);
            numAvailable = length(available);
            % select next one from all the remaining features
            crit = zeros(1,numAvailable);

            for k = 1:numAvailable
                x(:,end) = X(:,available(k));
                crit(k) = callfun(fun,x,other_data,cv,mcreps,ParOptions);
            end
            [bestCrit,idx] = min(crit);  % minimize the cost.

            if ~isempty(history.Crit) && isempty(nfs)
                if checkstop(history.Crit(end), bestCrit,options)
                    break
                end
            end

            nextOne = available(idx);
            in(nextOne) = true;         % move the selected features in
            history.In = [history.In; in];
            history.Crit = [history.Crit, bestCrit];
            if options.Display > 2 %iter
                fprintf('%s',getString(message('stats:gafs:AddedColumnCriteri',...
                    length(history.Crit),nextOne,sprintf('%g',bestCrit)) ));
            end            
        end
        if options.Display > 1 % final or iter
            fprintf('%s',getString(message('stats:gafs:FinalColumnsIncluded',makeColText(in,p))));
        end

    case 'backward'

        in = ~keepout;
        if  ~isempty(find(in,1)) || nullmodel
            %evaluate the initial model
            x = X(:,in);
            initCrit = callfun(fun,x,other_data,cv,mcreps,ParOptions);
            history.In = [history.In; in];
            history.Crit = [history.Crit, initCrit];
        end
        if options.Display >1
            fprintf(getString(message('stats:gafs:StartBackward')));
            fprintf('%s',getString(message('stats:gafs:InitialColumns',makeColText(~keepout,p))));
            fprintf('%s',getString(message('stats:gafs:ColumnsMustBeIncluded',makeColText(keepin,p))));
            if ~isempty(find(in,1)) || nullmodel
               fprintf('%s',getString(message('stats:gafs:Step1InitialColumnsCriterion',sprintf('%g',history.Crit(end)))));
            end         
        end

        nin_start = sum(in & ~keepin);
        if ~any(keepin) && ~nullmodel
            nin_start = nin_start-1; %at least one feature should remain in
        end
        for j = 1:nin_start
            if  ~isempty(nfs)
                if sum(in) <= nfs
                    break;
                end
            elseif j > options.MaxIter
                break;
            end

            inlist = find(in);
            numIn = length(inlist);
            crit = inf(1,numIn);

            for k = 1:numIn
                if keepin(inlist(k))
                    continue;
                end
                x = X(:,in);
                x(:,k) = [];
                crit(k) = callfun(fun,x,other_data,cv,mcreps,ParOptions);
            end
            [bestCrit,idx] = min(crit);  % minimize crit

            if ~isempty(history.Crit) && isempty(nfs)
                if checkstop(history.Crit(end), bestCrit,options)
                    break
                end
            end
            nextOne = inlist(idx);
            in(nextOne) = false; %remove nextOne
            history.In = [history.In; in];
            history.Crit = [history.Crit, bestCrit];
            if options.Display > 2 %iter
                fprintf('%s',getString(message('stats:gafs:RemovedColumnCrite',...
                    length(history.Crit),nextOne,sprintf('%g',bestCrit))));
            end
            

        end
        if options.Display > 1 % final or iter
            fprintf('%s',getString(message('stats:gafs:FinalColumnsIncluded',makeColText(in,p))));
        end

end
end

%----------------------
%check if keepin and keepout are valid
function keepVec = checkkeepvec(keepVec,p,name)
if isempty(keepVec)
    keepVec = false(1,p);
else
    if ~isvector(keepVec)
        error(message('stats:gafs:Badkeep', name));
    end
    if islogical(keepVec)
        if length(keepVec) ~= p
            error(message('stats:gafs:Badkeep', name));
        end
    else
        if ~isnumeric(keepVec) || any(~round(keepVec) == keepVec) ||...
                any(~ismember(keepVec,1:p))
            error(message('stats:gafs:Badkeep', name));
        else
            temp = false(1,p);
            temp(keepVec) = true;
            keepVec = temp;
        end
    end
end
end

%-----------------------------------
function coltext = makeColText(vec,p)
if ~any(vec)
    coltext = 'none';
elseif sum(vec) == p
    coltext = 'all';
else
    coltext = sprintf('%d ',find(vec));
end
end

%-----------------------------------
function crit = callfun(fun,x,other_data,cv,mcreps,ParOptions)
if isa(cv,'cvpartition')
    funResult = crossval(fun,x,other_data{:},...
        'partition',cv,'Mcreps',mcreps,'Options',ParOptions);
    if size(funResult,2) ~= 1
        error(message('stats:gafs:FunOutNotScalar'));
    end
    crit = sum(funResult)/ (mcreps * sum(cv.TestSize));
else
    try
        crit = fun(x,other_data{:});
    catch ME
        if strcmp('MATLAB:UndefinedFunction', ME.identifier) ...
                && ~isempty(strfind(ME.message, func2str(fun)))
            error(message('stats:gafs:FunNotFound', func2str( fun )));
        else
            m = message('stats:gafs:FunError',func2str(fun));
            throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
        end
    end
    if size(crit,2) ~= 1
        error(message('stats:gafs:FunOutNotScalar'));
    end
end
end

%-----------------------------------
%check whether it should stop
function stop = checkstop(oldCrit,newCrit,options)
stop = false;
if strcmp(options.TolTypeFun,'rel')
    critTh = oldCrit - (abs(oldCrit) + sqrt(eps))...
        * options.TolFun;
else
    critTh = oldCrit - options.TolFun;
end
if newCrit > critTh
    stop = true;
end
end
