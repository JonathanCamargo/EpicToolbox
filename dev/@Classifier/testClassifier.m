function [testing_accuracy, lab_pred, conf] = testClassifier(obj, testing_data, lab_truth, model)
    % TODO Doc James
    lab_pred = cell(length(lab_truth), 1);
    conf = zeros(length(lab_truth), 1);

    switch obj.Model
        case 'dbn'
            [lab_pred, conf] = obj.testDBN(model, testing_data);
        case 'bn'
            [lab_pred, conf] = obj.testBN(model, testing_data);
        case 'lda'
            [lab_pred, conf] = predict(model, testing_data);
    end
    
    if(isempty(lab_pred))
        testing_accuracy = 0;
    else
        testing_accuracy = sum(strcmp(lab_pred, lab_truth))/length(lab_truth);
    end

end