function model = trainClassifier(obj, training_data, labels)
%% TRAIN CLASSIFIER

    switch obj.Model
        case 'dbn'
            model = obj.trainDBN(training_data, labels);
        case 'bn'
            model = obj.trainDBN(training_data, labels);
        case 'lda'
            model = fitcdiscr(training_data, labels);
    end

end
