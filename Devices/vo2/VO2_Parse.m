% Jared Li 2/22/18
% Runs VO2_read, generates .mat file, parses data, generates graph of all
% successful trials and text file detailing avg and mean metabolic rates
% and the trials that have failed

function [] = VO2_Parse(Patient_Name, Patient_Weight_kg)

VO2_read(Patient_Name)
load(Patient_Name)
i = 0;
text_name = sprintf('%s_Experiment_Info.txt',Patient_Name);
fh = fopen(text_name,'w');
graph_title = sprintf('%s Metabolic Data', Patient_Name);
graph_file = sprintf('%s_figure.png',Patient_Name);

for i = 1:length(VO2_Struct)
    
    try
        arr = VO2_Struct(i).numerical_data(:,[1,5,6]);
        [row,~] = find(isnan(arr));
        arr(row,:) = [];

        ds = datestr(arr(:,1),'HH:MM:SS');
        [Y, M, D, MN, S, ~] = datevec(ds);
        seconds = (MN*60)+S;
        arr(:,1) = seconds;
        tend = arr(end,1);
        arr = arr(arr(:,1) > tend-180, :);
        seconds = arr(:,1);
    
        VO2 = (arr(:,2))./60; %units in ml/s
        VCO2 = (arr(:,3))./60;
        meanVO2 = mean(arr(:,2))/60;
        meanVCO2 = mean(arr(:,3)/60);
    
        %%brockway equation
        metabolicr = ((16.58.*VO2)+(4.51.*VCO2))./(Patient_Weight_kg); %%in W/kg
        %metabolicr = metabolicr - resting;
        meanmr = ((16.58.*meanVO2)+(4.51.*meanVCO2))./(Patient_Weight_kg); %%in W/kg
        %meanmr = Smeanmr - resting;
        arr(:,1:3) = [];
    
        fig = plot(seconds,metabolicr);
        title(graph_title);
        xlabel('Time (s)');
        ylabel('Metabolic rate (W/kg)')
        hold on
        
        
        fprintf(fh,'Trial #%d: Mean Metabolic Rate = %d W/kg\n',i,meanmr);
        
    catch
        
        fprintf(fh,'Trial #%d failed, no graph is available.\n',i);
    end

end

legend
hold on
saveas(fig, graph_file);

end

