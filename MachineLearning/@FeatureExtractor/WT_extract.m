function features=WT_extract(window,levels,wname)
	 %features are [minimum,maximum,stdev] for each Di and An
     
     %if you modify this file please change the configureHeader function
     %accordingly.
     
     [c,l]=wavedec(window,levels,wname);
     features=zeros(1,(levels+1)*3);%allocate features vector
     %go for each WT level
     start=1;
     for i=1:levels+1
        coefficients=c(start:start+l(i)-1);
        minimum=min(coefficients);
        maximum=max(coefficients);
        stdev=std(coefficients);
        features(3*(i-1)+1:(3*i))=[minimum, maximum, stdev];
        start=start+l(i);
     end
end

