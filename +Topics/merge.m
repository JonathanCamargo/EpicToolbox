function merged=merge(trial_data1,varargin)
% Merge all topics from two trial_data entities
% 
% Combine two or more trials into one
% merged=merge(trial_data1,trial_data2,trial_data3,...,OPTIONS)
% This will merge by copying the data in trial_data2,trial_3, etc into trial_data1. 
%
% merged=merge(cellarray_with_trials,OPTIONS)
% This will merge all the data as one single struct 
% contents in trial_data1 if they exist.
%
%
% Regular usage:
% trial_data is a data structure containing all the topics
%
% Advanced usage:
% trial_data could be: a cell array containing trial data structures
% in this case both should have the same size

%%
p=inputParser();
p.addParameter('Overwrite',true); % Overwrites data with the same header

% Parse varargin:
% Options:
% trial_data1 is a struct, then look for trial_data2, trial_data3 etc in
% varargin.

if isstruct(trial_data1)
   nTrials=1;
   for i=1:numel(varargin)
       if ~isstruct(varargin{i})          
           break;
       else
           nTrials=nTrials+1;
       end      
   end
   if i==1; error('No second trial to merge with');end
   alltrials=[{trial_data1},varargin(1:nTrials-1)];
elseif iscell(trial_data1)
    % TODO [NOT STABLE] User tries to merge every i,j,k,... of a cell array
    % not sure how this will work on any type of data but lets give it a
    % shot...
   nTrials=1;
    for i=1:numel(varargin)
       if ~iscell(varargin{i})
           break;
       else
           nTrials=nTrials+1;
       end
    end    
    if isempty(varargin) || i==1
        % No second trial to merge with, user wants to merge all the trials
        % in this cell array as a single trial.
        merged=Topics.merge(trial_data1{:},varargin{:});            
        return;
    end
    alltrials=[trial_data1,varargin(1:nTrials-1)];
    alltrials=cellfun(@cell2mat,alltrials,'Uni',0);
    inputsstr=strjoin(compose('x%d',nTrials),',');
    mergefun_str=['@(' inputsstr ')Topics.merge(' inputsstr ',varargin(nTrials-1:end)'];
    mergefun=eval(mergefun_str);
    merged=arrayfun(mergefun,alltrials{:});
    return;
end
    
if numel(varargin)>nTrials-1
    p.parse(varargin{nTrials:end});   
else
    p.parse();
end
Overwrite=p.Results.Overwrite;

% Alltrials contains all the trials to be combined
% alltrials={trial_data1,trial_data2,...};

%% Check if trial_data is a cell array

merged=alltrials{1};
for i=2:nTrials    
    data2=alltrials{i};
        %Get every topic from both and merge if topics are repeated copy de
        %data and override contents.        
        fields1=Topics.topics(merged,'Header',false);
        fields2=Topics.topics(data2,'Header',false);      
        for v=1:numel(fields2)                        
            if ismember(fields2{v},fields1)
                %warning('Topic %s is present in both trial_data1 and trial_data2. Using trial_data2 to merge',fields2{v});
                % Replace content that shares the same header
                                
                eval(sprintf('a=merged.%s;',fields2{v}));
                if istable(a) && Overwrite
                    eval(sprintf('b=data2.%s;',fields2{v}));
                    [~,loc]=ismember(b.Header,a.Header);
                    a=a(setdiff((1:numel(a.Header))',loc),:);                
                    aa=sortrows(vertcat(a,b),'Header');
                elseif istable(a) && ~Overwrite
                    eval(sprintf('b=data2.%s;',fields2{v}));
                    aa=[a;b];                                        
                elseif Overwrite
                    eval(sprintf('aa=data2.%s;',fields2{v}));
                elseif ~Overwrite
                    eval(sprintf('b=data2.%s;',fields2{v}));
                    aa=[a;b];                    
                end
                eval(sprintf('merged.%s=aa;',fields2{v}));                
                                                
            else
                eval(sprintf('merged.%s=data2.%s;',fields2{v},fields2{v}));
            end
        end                   
end

end
