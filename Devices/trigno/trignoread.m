function experiment = trignoread(trigno_path,varargin)
    %Read the trigno file in trigno_path and return a structure (experiment) 
    %that holds all the messages organized in tables by topic name.    
    %
    %
    % e.g.trignoread('example.trigno');
    %
    % TODO : explain optional arguments
    % InitialTime: blah blah
    % 
    
    %% TRIGNO Read
    inputs=inputParser;
    Names={'InitialTime'};
    Defaults={0};    
    for i=1:length(Names)
        addOptional(inputs,Names{i},Defaults{i});
    end
    parse(inputs,varargin{:});
    
    initialTime=inputs.Results.InitialTime;
    
    [topic_names,offset]=parse_trignotopics(trigno_path);
    trigno=dlmread_empty(trigno_path,',',offset,0,NaN);
          
    for i=1:length(topic_names)        
        time=trigno(:,(i-1)*2+1)+initialTime;        
        data=trigno(:,(i-1)*2+2);
        idx=~isnan(data);
        time=time(idx); data=data(idx);
        my_table=array2table([time data],'VariableNames',{'Header','Data'});
        eval(sprintf('experiment.%s=my_table;',topic_names{i}));        
    end
end




