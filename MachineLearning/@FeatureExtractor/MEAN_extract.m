function mean = MEAN_extract(window)
%MEAN_EXTRACT Summary of this function goes here
%   Detailed explanation goes here
    mean=sum(abs(window))/numel(window);
end

