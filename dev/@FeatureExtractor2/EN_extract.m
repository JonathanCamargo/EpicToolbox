function features=EN_extract(window)
	 %feature is the entropy from the window
     
     %if you modify this file please change the configureHeader function
     %accordingly.
    
     n_channels=size(window,2);          
     features=zeros(1,n_channels);
     for i=1:n_channels
        features(i)=entropy(window(:,i)); 
     end
     
end

