function mgc_metabolics_graph(filename,cond)

[num,txt,raw] = xlsread(filename);

arr = num(:,:); 
figure
%%%edit for each subject
kg = 81;
resting = 1.408526; %W/kg
%kg = mean(arr(5,:)./arr(4,:));

%find maximum time for all experiments in case one of the experiments ended
%early
tend = 0;
for i=1:cond
    temparr = arr(:,1);
    tempmax = max(temparr);
    if tempmax > tend 
        tend = tempmax;
    end
    temparr(:,1) = [];
end 

i = 1;
for i=1:cond
temparr = arr(:,1:3);
[row,col] = find(isnan(temparr));
if (isempty(row) == 0)
temparr((row(1):end),:) = [];
end
temparr = arr(arr(:,1) > tend-180, :);
seconds= temparr(:,1);
VO2 = (temparr(:,2))./60; %units in ml/s
VCO2 = (temparr(:,3))./60;
meanVO2 = mean(temparr(:,2));
meanVCO2 = mean(temparr(:,3));
sprintf('The average VO2 (ml/min) for cond %d = %d', i, meanVO2)
%RER = VCO2./VO2;
%meanRER = meanVCO2/meanVO2;
%ec = 21.13;
%ef = 19.62;
%metabolicr = VO2.*([(((RER-0.7)./0.3).*ec)+(((1.0-RER)./0.3).*ef)]./60).*1000; %%in W
%meanmr = meanVO2.*([(((meanRER-0.7)./0.3).*ec)+(((1.0-meanRER)./0.3).*ef)]./60).*1000;

%%brockway equation
metabolicr = ((16.58.*VO2)+(4.51.*VCO2))./(kg); %%in W/kg
metabolicr = metabolicr - resting;
meanmr = ((16.58.*meanVO2)+(4.51.*meanVCO2))./(kg); %%in W/kg
meanmr = meanmr - resting;
arr(:,1:3) = [];

sprintf('The mean metabolic rate (W/kg) for cond %d = %d', i, meanmr)
avg = num2str(metabolicr(end),'%1.2f');
txt = sprintf('Avg = %s', avg);
plot(seconds,metabolicr)
text(seconds(end),metabolicr(end),txt)
hold on
end
%%%edit for particular study
legend('exo zero', 'exo 7.5', 'exo 15', 'no exo')
xlabel('time (s)');
ylabel('metabolic rate (W/kg)');

end