function model = trainDBN(obj, features, labels, varargin)
%% Create a DBN model
%
% model = dbn(features, labels)
%
% Inputs:
%   features - m x n matrix for m samples, n features
%   labels - m x 1 vector of labels for features
%
% Outputs:
%   dbn model to use with testModel
    
    model = struct();
    
    steadyStateProb = 0.85; %probability that you will stay in same state
    
    classes = unique(labels);
    steadyClasses = unique(labels(~contains(labels, '-')));
    transClasses = unique(labels(contains(labels, '-')));
    
    numClasses = length(classes);
    numFeatures = length(features(1,:));
    numSteady = length(steadyClasses);
    numTrans = length(transClasses);
    
    % create transition matrix (for now this is just an arbitrary diagonal
    % matrix with equal probabilities for transition
    transMat = zeros(numSteady);
    for ind = 1:numSteady
       transProb = (1 - steadyStateProb)/(numSteady - 1);
       transMat(ind, :) = zeros(1, numSteady) + transProb;
       transMat(ind, ind) = steadyStateProb;
    end
    
    Mu = mean(features);
    Sigma = cov(features);

    mu_prime = zeros(1, size(features, 2), numClasses);
    sigma_prime = zeros(size(features, 2), size(features, 2), numClasses);
    p_c = zeros(1, numClasses);
    for classInd = 1:numClasses
        mu_prime(:,:,classInd) = mean(features(strcmp(labels, classes{classInd}),:));
        sigma_prime(:,:,classInd) = cov(features(strcmp(labels, classes{classInd}),:));
        p_c(classInd) = sum(strcmp(labels, classes{classInd}))/length(labels);
    end

    model.classes = steadyClasses;
    model.Mu = Mu;
    model.Sigma = Sigma;
    model.mu_prime = mu_prime;
    model.sigma_prime = sigma_prime;
    model.p_c = p_c;
    model.transMat = transMat;
end

