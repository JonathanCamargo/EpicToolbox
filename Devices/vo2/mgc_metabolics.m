function mgc_metabolics(filename)

[num,txt,raw] = xlsread(filename);

%%%edit for each subject
kg = 70;

arr = num(:,[1,5,6]); 
[row,col] = find(isnan(arr));
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
        
%RER = VCO2./VO2;
%meanRER = meanVCO2/meanVO2;
%ec = 21.13;
%ef = 19.62;
%metabolicr = VO2.*([(((RER-0.7)./0.3).*ec)+(((1.0-RER)./0.3).*ef)]./60).*1000;
%meanmr = meanVO2.*([(((meanRER-0.7)./0.3).*ec)+(((1.0-meanRER)./0.3).*ef)]./60).*1000;

%%brockway equation
metabolicr = ((16.58.*VO2)+(4.51.*VCO2))./(kg); %%in W/kg
%metabolicr = metabolicr - resting;
meanmr = ((16.58.*meanVO2)+(4.51.*meanVCO2))./(kg); %%in W/kg
%meanmr = Smeanmr - resting;
arr(:,1:3) = [];

sprintf('The mean metabolic rate (W/kg) = %d', meanmr)
avg = num2str(metabolicr(end),'%1.2f');
txt = sprintf('Avg = %s', avg);
%figure
%plot(seconds,metabolicr)
%hold on

figure
plot(seconds,metabolicr)
legend(filename)
xlabel('Time (s)');
ylabel('Metabolic rate (W/kg)');
text(seconds(end),metabolicr(end),txt)


end