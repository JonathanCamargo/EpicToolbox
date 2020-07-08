function selectionInfo = Heuristic(inputTable, outputTable)
%%Heuristic
% This script estimates the usefulness of a feature according to the
% following cost function:
%
%            |^|
%            |    d/dx(finite_difference_method(x))
% H(S_x) =   |   ----------------------------------  dx
%            |        standard_deviation(x)
%          |_|

outputNames = output.Properties.VariableNames;

for estimator = 1:size(output,2)
    single_output = output{:,estimator};
    unique_output = unique(single_output);
    mean_data = cell(1,length(unique_output));
    std_data = cell(1,length(unique_output));
    % Use 1% max value bucketing for continuous parameters
    for i = 1:length(unique_output)
        if iscell(unique_output(i))
            if strcmp(class(unique_output{i}),'char')
                data = input{strcmp(single_output,unique_output{i}),:};
            else
                data = input{single_output==unique_output{i},:};
            end
        else
            data = input{single_output==unique_output(i),:};
        end
        data = (data(:,:)-min(data(:,:)))./(max(data(:,:))-min(data(:,:))); % Normalize for comparison
%         data(isnan(data)) = 0; %% FIX ISNAN
        mean_data{i} = mean(data(:,:));
        std_data{i} = std(data(:,:));
    end
    mean_data = cell2mat(mean_data');
    std_data = cell2mat(std_data');
    num = diff(mean_data); % Will not work if there is only one unique output
    num = [num; num(end,:)]; % This is to extend the diff to the last value
    den = min(std_data, 1e-4);
    
    
    selectionInfo.(outputNames{estimator}) = array2table(abs(sum(num./den)),'VariableNames',input.Properties.VariableNames); % We do not care about increasing or decreasing
    % This final step should be re-evaluated. Consider the equivalencies of
    % this formula and whether or not you actually want them to be treated
    % the same.
%     dataset.([estimators{estimator} '_heuristic']) = array2table(heuristic_vals, ...
%         'VariableNames', dataset.combined_features.Properties.VariableNames);
    
end

end
