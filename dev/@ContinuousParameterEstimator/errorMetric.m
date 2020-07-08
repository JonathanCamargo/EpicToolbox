function [error percent_error] = errorMetric(ytrain, ypred)
if isempty(ytrain)
    error = NaN;
else
    error = mean(abs(ytrain-ypred));% error is in the units of the output
    percent_error = mean(abs((ytrain-ypred)./ytrain));
end
end