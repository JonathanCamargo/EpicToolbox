function [h,lgnd]=plot(experiment_data,topic_name,varargin)
% Plot an specific topic
% use: Topics.plot(experiment_data,topic_name,optional::options);
% 
% Options: name value pairs
% ----------------------------------------------
%  name    value1/value2/(default)  Description
% ----------------------------------------------
% 'channels' | ()   plot all the channels
% 'LineSpec' | {} cell array with properties
p=inputParser;
p.addParameter('Channels',{},@(x)(iscell(x) || isstring(x) || ischar(x)));
p.addParameter('Shaded',false);
p.addParameter('Legend',true);
p.addParameter('LineSpec',[]);
p.parse(varargin{:});

channels=p.Results.Channels;
lineSpec=p.Results.LineSpec;
LEGEND=p.Results.Legend;
washold=ishold();


if ~iscell(channels)
    channels={channels};
end
    
lgnd=[]; %legend
try     
    eval(sprintf('data=experiment_data.%s;',topic_name));
    istable(data);
catch
    error('Topic: %s does not exist',topic_name);
end
% Plot each channel
if isempty(channels)
    channels=setdiff(data.Properties.VariableNames,'Header');
else
    allchannels=setdiff(data.Properties.VariableNames,'Header');
    keys=channels;
    isSelected=false(size(keys));
    selectedChannelsInd=[];
    for keyIdx=1:numel(keys)
        key=keys{keyIdx};                 
        % Try strcmp first if fails then try regular expresion
        foundcell=strcmp(allchannels,key);
        notfound=~foundcell;
        if ~any(foundcell)
            foundcell=regexp(allchannels,key);
            notfound=cellfun(@isempty,foundcell);
        end
        found=~notfound;
        isSelected(keyIdx)=any(found);                    
        selectedChannelsInd=[selectedChannelsInd find(found)];
    end
    selectedChannelsInd=unique(selectedChannelsInd,'stable');
    channels=allchannels(selectedChannelsInd);
end


if washold
    hold on;
end
h=cell(numel(channels),1);
for j=1:numel(channels)
    channel=channels{j};
    % Plot
    t=data.Header;
    x=data.(channel);
    if ( (~isnumeric(x(1))) && (iscell(x(1))) )
        if (ischar(x{1}))
            plot_labels(t,x,varargin{:});
        end        
    else
        if ~isempty(lineSpec)
            h{j}=plot(t,x,lineSpec{:});
        else
            h{j}=plot(t,x);
        end
        if (LEGEND)
            lgnd=legend(h{j},channel,'interpreter','none');
        end
    end
    hold on;    
end
if (LEGEND)
    lgnd=legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'),'Location', 'best');   
end

title(topic_name,'interpreter', 'none');
xlabel('Time (s)');
ylabel(sprintf('%s',topic_name),'interpreter','none');

if ~washold
    hold off;
end
    
h=gcf;

end

function h=plot_labels(t,labels,varargin)
% Plot labels as shaded regions:

p=inputParser();
p.addParameter('Shaded',false);
p.addParameter('channels',{},@(x)(iscell(x) || isstring(x) || ischar(x)));
p.parse(varargin{:});

if (p.Results.Shaded)
    SHADES=true;
    LINES=false;
else
    LINES=true;
    SHADES=false;
end

time=t;
states=labels;
unique_states=unique(labels);
unique_states=unique_states(~strcmp(unique_states,''));
c=lines(numel(unique_states));

washold=false;
if ishold();washold=true;end

Ylim=ylim;
%Plot a transparent region with colors
h=cell(numel(unique_states),1);
for i=1:numel(unique_states)
    isphase=strcmp(states,unique_states(i));
    %Find the ranges of indices where the phase exists
    entering=(diff([0; isphase])==1);
    leaving=(-diff([0; isphase])==1);
    t_entering=time(entering);
    if isempty(t_entering);t_entering=time(1);end
    t_leaving=time(leaving);
    if (numel(t_leaving)<numel(t_entering)); t_leaving=[t_leaving;time(end)];end
    if LINES
        for idx=1:size(t_entering)
            h1=plot([t_entering(idx) t_entering(idx)],[Ylim(1) Ylim(2)],'Color',c(i,:));
            hold on;
        end
        h{i}=h1;
        h{i}.DisplayName=unique_states{i};
    end
    if SHADES
        centers=(t_entering+t_leaving)/2;
        widths=(t_leaving-t_entering);
        for idx=1:size(centers,1)
            h1=shadedRectangle(centers(idx),mean(Ylim),widths(idx),abs(diff(Ylim)),{'Color',c(i,:)});
            hold on;
            h1.edge(1).DisplayName='';
            h1.edge(2).DisplayName='';
            h1.patch(1).DisplayName='';
        end
        h{i}=h1;
        h{i}.patch.DisplayName=unique_states{i};
    end
    
end

if ~washold; hold off;end

%legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'),'Location', 'southeast');    
end


