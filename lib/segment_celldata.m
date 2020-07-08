function output=segment_celldata(data_cellarray,delimiter_data,varargin)
    % Split the data in data_cellarray using peaks from delimiter_data
    % by calling findpeaks on delimiter_data.
    %
    % data_cellarray={[t1 x1],[t2 x2],[t3 x3]};
    % delimiter_data=[tdelim xdelim];
    %
    % segment_celldata(data_cellarray,delimiter_data,varargin)
    %
    % Optional arguments: findpeaks optional arguments like:
    %  'MinPeakProminence','MinPeakDistance',etc.    
    
    delim_t=delimiter_data(:,1);
    delim_x=delimiter_data(:,2);
    
    [~,t_maxima] = findpeaks(delim_x,delim_t,varargin{:});
    
    steps=length(t_maxima)-1;
    output=cell(steps,length(data_cellarray));
    
    for step_idx=1:steps
        for sensor_idx=1:length(data_cellarray)
            X=data_cellarray{sensor_idx};
            output{step_idx,sensor_idx}=cut(X,t_maxima(step_idx),t_maxima(step_idx+1));
        end                
    end                    
end