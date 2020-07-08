function parsave(filename,varargin)
% Simple solution to call save inside parfor
% parsave(filename,'varname',vardata,'varname2',vardata2,...,{othersaveoption})    

    if mod(nargin-1,2)
        otheropts=varargin(end);
        if ~iscell(otheropts)
            otheropts={otheropts};
        end
        varpairs=varargin(1:end-1);
    else
        varpairs=varargin;
        otheropts={};
    end
    %all inputs are pairs of var and data    
    allvars=struct();
    names=varpairs(1:2:end);
    data=varpairs(2:2:end);
    for i=1:numel(names)
        allvars.(names{i})=data{i};
    end
    
    save(filename,'-struct','allvars',otheropts{:});
    
end