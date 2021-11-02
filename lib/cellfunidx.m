    function A=cellfunidx(FUN,varargin)
%   A = CELLFUNidx(FUN, X1,X2,...,XN) applies the function specified by FUN to the
%   contents of each cell of cell array X, and returns the results in
%   the array A. 
%   ust like cellfun but when used with more arguments it operates in an
%   indexed fashion. Where A{i,j,..}=FUN(X1{i,j,k},X2{i,j,k},...)
%

X=varargin(1:end);
XX=cell(numel(X{1}),numel(X));
for i=1:size(XX,2)
    xi=X{i};
    XX(:,i)=xi;   
end

Y=cell(size(XX,1),1);
for i=1:numel(X{1})
    Y{i}=FUN(XX{i,:});
end

if numel(Y)>1
    A=reshape(Y,size(X{1},1));
else
    A=Y;
end