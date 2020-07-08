function timeIntervals = findTimes(condition,trialdata, varargin)
% Identifies the time ranges within a trial that satisfy the condition
% given by condition.
% 
% timeIntervals = findTimes(condition_fun, trialdata, varargin)
% 
% condition 
%   Can be a handle operating on a table and returns a logical
% vector with the same number of samples. 
%   Can be a logical vector, in which case the size of condition vector
%   must match with the size of the table in the topics of trialdata.
% 
% 
% Outputs:
%   timeIntervals: Struct containing each condition label as a field and a
%       cell array containing duples of start and end times.
% See also Topics

narginchk(0,3);

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);
% Adding Parameter varagin
p.addOptional('Topics',{},validStrOrCell);
p.parse(varargin{:});

% Get the optional results:
% Get message list
% List of messages to process:
if isempty(p.Results.Topics)
    topics_list=Topics.topics(trialdata);
elseif ischar(p.Results.Topics)
    topics_list={p.Results.Topics};
else
    topics_list=p.Results.Topics;
end

fun=@(table_data)findTimes_table(table_data,condition);    
timeIntervals=Topics.processTopics(fun,trialdata,topics_list);    

end


function intervals=findTimes_table(table_data,condition_fun)
    
    if islogical(condition_fun)
        condition=condition_fun;
    elseif isnumeric(condition_fun)
        condition=logical(condition_fun);
    else
        condition=condition_fun(table_data);
    end
    
    a=diff([0;condition]);
    
    starts=find(a==1);
    ends=find(a==-1)-1;
    if (numel(starts)>numel(ends))
        ends=[ends;numel(a)];
    end
    
    intervalsArr=[starts ends];
    
    
    x1dim=ones(1,size(intervalsArr,1));
    x2dim=2;    
    
    intervals=mat2cell(intervalsArr,x1dim,x2dim);
    intervals=cellfun(@(x)(table_data.Header(x)'),intervals,'Uni',0);
end

