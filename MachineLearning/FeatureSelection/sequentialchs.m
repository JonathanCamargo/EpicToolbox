function [crit,history] = sequentialchs(selfun,nChannels,varargin)
%SEQUENTIALCHS TODO Summary of this function goes here
% [crit,history] = sequentialchs(selfun,nChannels,varargin)
% Performs a sequential process by activating one element of a vector at a
% time.

% Things to include: direction, Parallel, maxiters


% Forward direction
direction='forward';

history.In = false(0,0);
history.Crit = [];
in=false(1,nChannels);
switch direction
    case 'forward'
        % Sequential forward selection
        nStart = nChannels;
        for j = 1:nStart
            available = find(~in);%find(~in & ~keepout);
            numAvailable = length(available);
            % select next one from all the remaining features
            crit = zeros(1,numAvailable);
            for k = 1:numAvailable        %Parallel?                 
                selvector= in; selvector(available(k))=true;
                crit(k) = callfun(selfun,selvector); % other options
            end
            [bestCrit,idx] = min(crit);  % minimize the cost.            
            nextOne = available(idx);
            in(nextOne) = true;         % move the selected features in
            history.In = [history.In; in];
            history.Crit = [history.Crit, bestCrit];
        end
        
    % TODO backward
end



end



%%%%%%%%%% HELPER %%%%%%%%%%%%%%

function crit=callfun(selfun,selvector)
    crit=selfun(selvector);    
end
