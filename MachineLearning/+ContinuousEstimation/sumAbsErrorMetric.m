function [error ] = sumAbsErrorMetric(ytrain, ypred)
% sub abs error metric
% [error] = sumAbsErrorMetric(ytrain, ypred)
% 


if isempty(ytrain)
    error = NaN;
    % percent_error=Nan;
    return;
end

error = sum(abs(ytrain-ypred));% error is in the units of the output
% percent_error = mean(abs((ytrain-ypred)./ytrain));

if numel(error)>1  % Multiple outputs condense into one single error metric        
    error=rms(error);   
    % percent_error=rms(error);
end

end