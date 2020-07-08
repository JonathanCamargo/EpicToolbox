function [pred_filt, conf_filt, pred_unfilt, conf_unfilt] ...
    = testDBN(obj, model, features, varargin)
%% Function to output probability x|c
% using a DBN model created from trainDBN
%
% [predicted, confidence] = testDBN(features, model)
%
% Inputs:
%   features - 1 x n feature vector for n features
%   model - DBN model struct created by trainDBN
%
% Outputs:
%   predicted

    numClasses = length(model.classes);
    mu_prime = model.mu_prime;
    sigma_prime = model.sigma_prime;
    
    pred = cell(length(features(:, 1)), 1);
    conf = zeros(length(features(:, 1)), 1);
    
    pred_filt = cell(length(features), 1);
    pred_unfilt = pred_filt;
    p_c_give_x = model.p_c; %initialize with p_c (stored as p_last)
    for sampInd = 1:length(features)
        p_last = p_c_give_x;
        
        p_x_give_c = zeros(1, numClasses);
        for classInd = 1:numClasses
            p_x_give_c(classInd) = mvnpdf(features(sampInd,:), ...
                       mu_prime(:,:,classInd), sigma_prime(:,:,classInd));
        end
        
        [val_unfilt, loc_unfilt] = max(p_x_give_c);
        pred_unfilt(sampInd) = model.classes(loc_unfilt);
        conf_unfilt(sampInd) = val_unfilt;

        %make it dynamic
        p_c_give_x = (p_x_give_c .* p_last * model.transMat);
        %normalize
        p_c_give_x = p_c_give_x/max(p_c_give_x);
        
        [val_filt, loc_filt] = max(p_c_give_x);
        pred_filt(sampInd) = model.classes(loc_filt);
        conf_filt(sampInd) = val_filt;
    end
end