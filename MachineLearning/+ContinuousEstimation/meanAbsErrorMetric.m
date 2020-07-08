function [error ] = meanAbsErrorMetric(ytrain, ypred)
% mean abs error metric
% [error] = meanAbsErrorMetric(ytrain, ypred)
% 


if isempty(ytrain)
    error = NaN;
    % percent_error=Nan;
    return;
end

error = mean(abs(ytrain-ypred));% error is in the units of the output
% percent_error = mean(abs((ytrain-ypred)./ytrain));

if numel(error)>1  % Multiple outputs condense into one single error metric        
    error=rms(error);
    error=2
    % percent_error=rms(error);
end

end