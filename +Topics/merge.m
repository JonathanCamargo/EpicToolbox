function merged=merge(trial_data1,trial_data2,varargin)
% Merge all topics from two trial_data entities
%
% merged_trial_data=selectTopics(trial_data1,trial_data2);
% This will copy the data in trial_data2 to the trial_data1 overriding the
% contents in trial_data1 if they exist.
%
%
% Regular usage:
% trial_data is a data structure containing all the topics
%
% Advanced usage:
% trial_data could be: a cell array containing trial data structures
% in this case both should have the same size

%% Check if trial_data is a cell array
if iscell(trial_data1)
    ADVANCED=true;
    if size(trial_data1)~=size(trial_data2)
        error('Trial data arrays to merge should have the same size');
    end
    merged=cell(size(trial_data1));
else
    ADVANCED=false;
end

for i=1:size(trial_data1,1)
    for j=1:size(trial_data1,2)
        % Get the data depending if it is cell array or not
        if ADVANCED
            data1=trial_data1{i,j};
            data2=trial_data2{i,j};
        else
            data1=trial_data1;
            data2=trial_data2;
        end
        %Get every topic from both and merge if topics are repeated copy de
        %data and override contents.
        merged_tmp=struct();
        fields1=Topics.topics(data1,'Header',false);
        fields2=Topics.topics(data2,'Header',false);
        for k=1:numel(fields1)
            eval(sprintf('merged_tmp.%s=data1.%s;',fields1{k},fields1{k}));            
        end
        for v=1:numel(fields2)            
            
            if ismember(fields2{v},fields1)
                %warning('Topic %s is present in both trial_data1 and trial_data2. Using trial_data2 to merge',fields2{v});
                % Replace content that shares the same header
                                
                eval(sprintf('a=merged_tmp.%s;',fields2{v}));
                if istable(a)
                    eval(sprintf('b=data2.%s;',fields2{v}));
                    [~,loc]=ismember(b.Header,a.Header);
                    a=a(setdiff((1:numel(a.Header))',loc),:);                
                    aa=sortrows(vertcat(a,b),'Header');
                else
                    eval(sprintf('aa=data2.%s;',fields2{v}));
                end
                eval(sprintf('merged_tmp.%s=aa;',fields2{v}));                
                                                
            else
                eval(sprintf('merged_tmp.%s=data2.%s;',fields2{v},fields2{v}));

            end
        end
        
        if ADVANCED
            merged{i,j}=merged_tmp;
        else
            merged=merged_tmp;
        end

    end
end

end
