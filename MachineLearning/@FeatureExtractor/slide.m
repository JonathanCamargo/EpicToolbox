function outdata=slide(e,dataTable,window,increment)
    % outdata(dataTable,window,increment)
    % Slide an extractor across all data in data with a given window size
    % and increment of the sliding.    
    %
    % dataTable must have a first column as Header which is ignored by the
    % extractor
    %
    % See also
    % FeatureExtractor
    N=height(dataTable); %Number of samples
    header=dataTable.Header;
    endIdx=window;
    startIdx=0;
    allfeatures=[];
    allheaders=[];
    while endIdx<=N
        windowIdx=startIdx+(1:window); % Set up window
        x=e.extract(dataTable{windowIdx,2:end}); %Get features
        allfeatures=[allfeatures;x];
        allheaders=[allheaders;header(endIdx)]; % Keep header for future reference
        startIdx=startIdx+increment;
        endIdx=startIdx+window;                
    end
    headerTable=array2table(allheaders,'VariableNames',{'Header'});
    featureTable=array2table(allfeatures,'VariableNames',e.header);
    outdata=[headerTable featureTable];               
end
