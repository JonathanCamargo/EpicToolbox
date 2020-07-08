function features=AR_extract(window,AROrder) 		
        [r,lg] = xcorr(window,'biased');
        r(lg<0) = [];
        ar = levinson(r,AROrder);        
        features=ar(2:end);
 end
