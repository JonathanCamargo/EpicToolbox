function features= TD_extract(data_window)
    %Get time domain features of signal
    %Modify header and comment the Parameter section accordingly
    %Parameter 1 Mean absolute value
    rms_=rms(data_window);
    mean_=sum(data_window)/numel(data_window); 
    mean_Abs=sum(abs(data_window))/numel(data_window);
    %Parameter 2
    %Mean slope TBD

    %Parameter 3
    zeroCross=sum(abs(diff(data_window>0)));

    %Parameter 4
    slopeSignChange=sum(abs(diff(diff(data_window)>0)));

    %Parameter 5
    waveformLength=sum(abs(diff(data_window)));
    
    %Paramter 6
    minVal = min(data_window);
    maxVal = max(data_window);
    stdVal = std(data_window);

    %features=rms_;%waveformLength;
    features=[rms_,mean_,mean_Abs,zeroCross,slopeSignChange,waveformLength,minVal, maxVal, stdVal];
    
end