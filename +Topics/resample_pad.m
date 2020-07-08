function [Y,Ty]= resample_pad(X,Tx,Fs,varargin)
% Resample with padding to remove initial and end oscillations
% It is the same as resample(X,Tx,Fs) function but will add 10 samples before
% and after the data prior calling resample.
% 
% See help resample

avg_Fs=Fs;%1/mean(diff(Tx));
tpad=(10/avg_Fs:-1/avg_Fs:1/avg_Fs)';

xpad_beg=ones(10,size(X,2)).*repmat(X(1,:),10,1);
xpad_end=ones(10,size(X,2)).*repmat(X(end,:),10,1);


tpad_beg=Tx(1)-tpad;
tpad_end=Tx(end)+tpad;

X_pad=[xpad_beg;X;xpad_end;];
Tx_pad=[tpad_beg;Tx;tpad_end];


[Y,Ty]=resample(X_pad,Tx_pad,Fs,varargin{:});

idx=((Ty>=Tx(1))&(Ty<=Tx(end)));
Y=Y(idx,:);
Ty=Ty(idx);

end