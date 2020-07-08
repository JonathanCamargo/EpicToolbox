function out=rostopics2fields(topics)
% Use this for transform topic names from ros to topic names in
% epic toolbox. This will remove any / chars and change for .
if(contains([topics{:}],'/'))
	for i=1:numel(topics)
		topic=topics{i};
		if (topic(1)=='/')
			topics{i}=topic(2:end);
		end
	end
	out=strrep(topics,'/','.');
    warning(['Support for topics with / character will be removed',... 
       ' please use Topics.defaults.rostopics2fields to convert topics to names',...
        ' supported by EpicToolbox']);    
else
	out=topics;
end

end