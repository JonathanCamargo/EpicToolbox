function [pred_unfilt, conf_unfilt] ...
    = testBN(obj, model, features, varargin)
%% Function to output probability x|c
% DBN but without time-history/transition matrix

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
    end
end