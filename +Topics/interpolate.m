function resampled=interpolate(trial_data,T,varargin)
% Interpolate the content of the topics to the times given by T
% 
%  interpolate(trial_data,T,OPTIONAL:SELECTED_TOPICS)
%     interpolate the data in to times given by T
%
%   T is a vector of times, and interpolate will sample the trial_data 
%   e.g interpolatedTrial=interpolate(trial_data,0:0.1:10,sometopics)
%   will interpolate from Header 0 to 10 equally spaced 0.1dt.
%
% Optional:
% 'Extrapolation': (false)/true, flase with fill extrapolated values with nan. if true will extrapolate 
% See also Topics

% Check if the data is a the topic or all the trial data
p=inputParser();
p.addOptional('Topics',{},@(x)(ischar(x) || iscell(x)));
p.addParameter('Extrapolation',false);
p.parse(varargin{:});

Extrapolation=p.Results.Extrapolation;
if Extrapolation
    Extrapolation='extrap';
else
    Extrapolation=NaN;
end

% Get message list
topics_list=p.Results.Topics;
if isempty(topics_list)
    topics_list=Topics.topics(trial_data);    
end

fun=@(table_data)interpolate_table(table_data,T,Extrapolation);
resampled=Topics.processTopics(fun,trial_data,topics_list);
end

function interpolated_table=interpolate_table(table_data,T,Extrapolation)
    % Interpolate the data in a table using a spline
    % if data is not numeric it will be repeated till a new value exists.
    if ~iscolumn(T);T=T';end    
    tx=table_data.Header;
    try
        x=table_data{:,2:end};    
        xinterp=interp1(tx,x,T,'linear',Extrapolation);
        interpolated_table=array2table([T xinterp]);
        interpolated_table.Properties=table_data.Properties;
    catch
        interpolated_table=interpolate_table_with_nonnumeric(table_data,T);
    end
end


function interpolated_table=interpolate_table_with_nonnumeric(table_data,T)
    % Interpolate the data in a table using a splinenorma
    % if data is not numeric it will be repeated till a new value exists.
    fields=table_data.Properties.VariableNames;
    interpolated_table=table();interpolated_table.Properties.VariableNames;
    interpolated_table.Header=T;
    for field_idx=2:numel(fields)
        field=fields{field_idx};
        tx=table_data.Header;
        column=table_data.(fields{field_idx});
        if isnumeric(column)
             x=column;
             xinterp=interp1(tx,x,T,'spline',NaN);
             interpolated_table.(field)=xinterp;
        elseif islogical(column)
            interpolated_logicals=false(size(T,1),1);  
            for i=1:size(tx,1)
                index=(T>=tx(i));
                interpolated_logicals(index)=repmat(column(i),sum(index),1);
            end
            interpolated_table.(field)=interpolated_logicals;
        else
             interpolated_cells=repmat({''},size(T,1),1);   
             for i=1:size(tx,1)
                index=(T>=tx(i));
                interpolated_cells(index)=repmat(column(i),sum(index),1);
             end
             interpolated_table.(field)=interpolated_cells;       
        end
    end
end








