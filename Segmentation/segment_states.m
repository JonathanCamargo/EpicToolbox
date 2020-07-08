function segmented= segment_states(trial_data,topic,channel,varargin)
% segment_states(experiment_data,topic,channel,OPTIONAL:TOPICSLIST,optional);
%Segment the walking trial data by gait cycles
% segments=segment_states(trial_data)
%Function receives a trial_data structure containing the topics in
%ros namespace and split them to a cell array of structures by the
%value of a char channel.
%
% usage: 
%        segment_states(experiment_data,topic,channel,OPTIONAL:TOPICSLIST,optional);
%        Without name value pair options argument it will use fsm/EarlyStance to segment (default)
%	 
%        Options: '', channel to do the segmentation 
%                 

narginchk(1,4);
% Use input parser to find the desired option

p=inputParser;
% Validations
validStrOrCell=@(x) iscell(x) || ischar(x);

p.addParameter('States',{},validStrOrCell);
p.parse(varargin{:});

states=p.Results.States;
if isempty(states)
    topicsplt=strsplit(topic,'.');
    states=unique(getfield(trial_data,topicsplt{:},channel));
end

% Use findTimes to determine when is entering or leaving 
s=Topics.select(trial_data,topic,'Channels',{{'Header',channel}});
intervals=Topics.findTimes(@(x)(isEnteringOrLeavingState(x,states)),s,topic);

intervals=getfield(intervals,topicsplt{:});

inintervals_mat=cell2mat(intervals);
a=inintervals_mat(:,1);
a=[a(1:end-1) a(2:end)];
intervals=mat2cell(a,ones(size(a,1),1),2);

segmented=Topics.segment(trial_data,intervals);
end


function out=isEnteringOrLeavingState(tbl,states)
% For a table with header and a state column find the times when it enter
% or leaves the state member of the states group. Returns logical 1 when it
% happens.

unique_states=unique(states);
isEntering=false(size(tbl,1),1);
isLeaving=false(size(tbl,1),1);
time=tbl.Header;
for i=1:numel(unique_states)
    isphase=strcmp(tbl{:,2},unique_states(i));
    %Find the ranges of indices where the phase exists
    entering=(diff([0; isphase])==1);
    leaving=(-diff([0; isphase])==1);
    t_entering=time(entering);
    if isempty(t_entering)
        %t_entering=time(1);
        entering(1)=true;
    end
    t_leaving=time(leaving);
    if (numel(t_leaving)<numel(t_entering))
        %t_leaving=[t_leaving;time(end)];
        leaving(end)=true;
    end
    isEntering=isEntering | entering;
    isLeaving=isLeaving | leaving;
end

out=isEntering | isLeaving;


end

