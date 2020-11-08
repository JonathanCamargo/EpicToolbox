function isOutlier=isOutlierCurve(t,x,meanvals,stdvals,varargin)
% Determine if a curve is outlier w.r.t a mean and std range
% isOutlier=isOutlierCurve(t,x,meanvals,stdvals)
%
% MaxError (1) % Max error in std


%% 
% Example
%t=(0:0.001:2*pi)';
%meanvals=sin(t);
%stdvals=ones(size(meanvals))*0.5;
%x=meanvals-0.8*sin(t);

p=inputParser();
p.addParameter('MaxError',1,@isnumeric);
p.parse(varargin{:});

MaxError=p.Results.MaxError;

%Plot
%{
figure(1); clf
shadedErrorBar(t,meanvals,stdvals); hold on;
plot(t,x); hold off;
%}

% Find outlier distance

errorToMean=abs(x-meanvals);
errorFactor=(errorToMean./stdvals);
errorOverStd=errorToMean.*(errorFactor>1);

%Plot
%{
figure(2);clf;
plot(t,errorToMean); hold on;
plot(t,errorOverStd)
%}

% Check the total area outside of the std
%areaError=trapz(t,errorOverStd);
%areaMean=trapz(t,abs(meanvals));
% make this quadratic
areaError=trapz(t,errorOverStd.^2);
areaMean=trapz(t,abs(meanvals.^2));

% max(errorFactor)
% fprintf('maxerror: %1.2f, area error: %1.2f, area mean:%1.2f\n',max(errorFactor),areaError,areaMean);

if (max(errorFactor)>MaxError) %Tune this    
    isOutlier=true;
else
    isOutlier=false;
end


end