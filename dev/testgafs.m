  load('fisheriris');
  X = randn(150,10);
  X(:,[1 3 5 7 ])= meas;
  y = species;
  opt = statset('display','iter');
  % Generating a stratified partition is usually preferred to
  % evaluate classification algorithms.
  cvp = cvpartition(y,'k',10); 
  [fs,history] = sequentialfs(@classf,X,y,'cv',cvp,'options',opt);
  
 %% GA test
 numfeats=size(X,2);
 lb=zeros(numfeats,1);
 ub=ones(numfeats,1);  
 opts=gaoptimset;
 opts.Display='iter';       
%%
[fs,history]=gafs(@classf,X,y,'cv',cvp,'options',opts);
a=1:numel(fs);
fprintf('Final columns included:');
fprintf('%d ',a(logical(fs)));
fprintf('\n');

%%
x=history.In';
c=history.Crit;

[M,N]=size(x);
x=imresize(x,[M*200 N],'Method','nearest');
figure(1)
subplot(2,1,1)
plot(c);
subplot(2,1,2)
imshow(x)
%% 
function [fs,history]=gafs(fun,X,y,varargin)
% Genetic algorithm feature selection
%
%   'MCReps'    A positive integer indicating the number of Monte-Carlo
%               repetitions for cross-validation.  The default value is 1.
%               'MCReps' must be 1 if 'CV' is 'none' or 'resubstitution'.
%
            p=inputParser;
            validCv=@(x) (isscalar(x) || ischar(x) || isa(x,'cvpartition'));
            
            p.addParameter('cv',10,validCv);
            p.addParameter('MCReps',1,@isnumeric);
            p.addParameter('options',[]);
            p.parse(varargin{:});
             
            mcreps=p.Results.MCReps;
            cv=parsecv(p.Results.cv,mcreps);
            
            
            options=p.Results.options;
            defaultOptions = statset('sequentialfs');
            options = statset(defaultOptions, options);
            
            options.OutputFcns={@outputfun};
             
            %Binary vector defining if feature is active or not
            numfeats=size(X,2);
            lb=zeros(numfeats,1);
            ub=ones(numfeats,1);
            
            fun=@(feat_idx)callfun(feat_idx,X,y,cv); 
            
            history.Crit=[];
            history.In=[];
            
            
            [x_,fval_,exitflag,output,population,scpres]=ga(fun,numfeats,[],[],[],[],lb,ub,[],1:numfeats,options);
            
            %x: solution
            %fval: f(x)
            %exitflag:  
            %output: 
            %population: final population
            %scores: scores for population
            
           fs=x_;
           
            
            
function [state,options,optchanged]=outputfun(options,state,flag)
    
    optchanged=false;
    
    if ~(strcmp(flag,'init'))
        x=state.Population;
        fval=state.Score;    
        history.Crit=[history.Crit;fval];
        history.In=[history.In;x];
    end
end
end


function cv=parsecv(cv,mcreps)            
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
end

  
function crit = callfun(featIsActive,X,y,cv)
   usefeat=logical(featIsActive);   
   x=X(:,usefeat);   
   funResult = crossval(@classf,x,y,'partition',cv);  
   crit=sum(funResult);
end
    
function err = classf(xtrain,ytrain,xtest,ytest)
    yfit = classify(xtest,xtrain,ytrain,'quadratic');
    err = sum(~strcmp(ytest,yfit));
end