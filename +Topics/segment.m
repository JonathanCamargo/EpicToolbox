function segmented= segment(trial_data,intervals,varargin)
% Segment the trial data 
% segmented= segment(trial_data,intervals
% 
% Function receives a trial_data structure containing the topics in
% ros namespace and split them to a cell array of structures given by some
% intervales defined in a cell array {[t1start t1end],[t2start t2end]...}
%
%
% usage: 
%        segment(experiment_data,intervals,OPTIONAL:TopicsList);
%
%	 
%	 Examples:
%  
%        %Segment all the topics configured in the @Topics class 
%        segment(experiment_data,{[0 1],[1 2]});
%
%        
%        %Segment specifying Header values for segments
%        segment(experiment_data,'times',{[1.0 2.0],[2.1 3.0]});
%        would segment from 1.0 to 2.0 and then from 2.1 to 3.0
%

narginchk(2,3);

% Use input parser to find the desired option

validStrOrCell=@(x) iscell(x) || ischar(x);
p=inputParser;
p.addOptional('Topics',{},validStrOrCell);

p.parse(varargin{:});

% Get the optional results:
% Get message list
% List of messages to process:
if isempty(p.Results.Topics)
    topics_list=Topics.topics(trial_data);
elseif ischar(p.Results.Topics)
    topics_list={p.Results.Topics};
else
    topics_list=p.Results.Topics;
end

if isempty(intervals)
	% no intervals
    warning('No intervals defined');
    segmented=[];
else
	
end

segmented=cell(numel(intervals),1);

for i=1:numel(segmented)
    fun=@(data_table)Topics.cut(data_table,intervals{i}(1),intervals{i}(2),topics_list);
    segmented{i}=Topics.processTopics(fun,trial_data,topics_list);
end


end

