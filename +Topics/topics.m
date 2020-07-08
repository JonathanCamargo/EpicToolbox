function alltopics=topics(trial_data,varargin)
% Get all the topic names within the trial data
%
%
% 'Header' (true)/false  only find topics that have a header

p=inputParser();
p.addParameter('Header',true,@islogical);
p.parse(varargin{:});

hasHeader=p.Results.Header;



if ~isstruct(trial_data)
    if iscell(trial_data)
        trial_data=trial_data{1};
    end
end

alltopics=topics_recursive(trial_data,{});


function alltopics=topics_recursive(trial_data,parent)

alltopics={};
if isstruct(trial_data)
	fnames=fieldnames(trial_data);
	for i=1:numel(fnames)
		theseTopics=topics_recursive(trial_data.(fnames{i}),fnames{i});
		for j=1:numel(theseTopics)
            if ~isempty(parent)
                alltopics=[alltopics,{strjoin({parent,theseTopics{j}},'.')}];
            else
                alltopics=[alltopics,theseTopics(j)];                
            end
		end
	end
elseif istable(trial_data)
    if otherValidations(trial_data,hasHeader)
        alltopics={parent};	
    end
elseif isnumeric(trial_data) && ~hasHeader
    alltopics={parent};
elseif ~hasHeader
    alltopics={parent};
end

end
end


function out=otherValidations(trial,hasHeader)
    out=false;
    if ~hasHeader || (hasHeader && ismember('Header',trial.Properties.VariableNames))
        out=true;    
    end
end


