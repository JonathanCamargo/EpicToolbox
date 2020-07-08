% Jared Li 4/4/18
% Runs VO2_read, generates .mat file, parses data, generates graph of all
% successful trials and text file detailing avg and mean metabolic rates
% and the trials that have failed

% Patient_Name = String Input
% Patient_Weight_kg = Float Input

% IF ANYTHING IS IN THE "SUMMARY" CELL, THE TRIAL WILL NOT BE DISPLAYED

function [] = parvo_parse(Patient_Name, Patient_Weight_kg)

parvo_read(Patient_Name)
load(Patient_Name)
i = 0;
text_name = sprintf('%s_Experiment_Info.txt',Patient_Name);
fh = fopen(text_name,'w');
graph_title = sprintf('%s Metabolic Data 3/31/18', Patient_Name);
graph_file = sprintf('%s_figure.png',Patient_Name);
legend_vec =  [];

for i = 1:length(parvo_struct)
    
        trial_name = parvo_struct(i).raw_data(6,2);
    
        arr = parvo_struct(i).numerical_data(:,[1,2,5]);
        [row,~] = find(isnan(arr));
        arr(row,:) = [];
        
        seconds = arr(:,1)*60;
    
        VO2 = (arr(:,2).*1000)./60;  %units in ml/s
        VCO2 = (arr(:,3).*1000)./60;
        meanVO2 = mean(VO2);
        meanVCO2 = mean(VCO2);
    
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
        legend_vec = [legend_vec trial_name];
        
        
        fprintf(fh,'Trial #%d: Mean Metabolic Rate = %d W/kg\n',i,meanmr);


end

legend(legend_vec)
hold on
saveas(fig, graph_file);

end

