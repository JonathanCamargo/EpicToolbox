function h=plot_phases(experiment_data,varargin)
% Plot phases as shaded regions:
% plot_phases(experiment_data)
% plot_phases(experiment_data,'lines');
% plot_phases(experiment_data,'shades');

states=[experiment_data.fsm.State{:,2}{:}]';

time=experiment_data.fsm.State.Header;
unique_states=unique(states);
unique_states=unique_states(~strcmp(unique_states,''));
c=colormap('lines');

washold=false;
if ishold();washold=true;end


SHADES=true; LINES=false;
if nargin>1
    if varargin{1}=='lines'
        LINES=true; SHADES=false;
    elseif varargin{1}=='shades'
        SHADES=true; LINES=false;
    end
end

Ylim=ylim;
%Plot a transparent region with colors
for i=1:numel(unique_states)
    isphase=strcmp(states,unique_states(i));
    %Find the ranges of indices where the phase exists
    entering=(diff([0; isphase])==1);
    leaving=(-diff([0; isphase])==1);
    t_entering=time(entering);
    if isempty(t_entering);t_entering=time(1);end;
    t_leaving=time(leaving);
    if (numel(t_leaving)<numel(t_entering)); t_leaving=[t_leaving;time(end)];end
    %if (numel(t_leaving)>numel(t_entering)); t_entering=[t_leaving;time(end)];end    
    if LINES
        for idx=1:size(t_entering)
            plot([t_entering(idx) t_entering(idx)],[Ylim(1) Ylim(2)],'Color',c(i,:));
            hold on;
        end
    end
    if SHADES
        centers=(t_entering+t_leaving)/2;
        widths=(t_leaving-t_entering);
        for idx=1:size(centers,1)
            shadedRectangle(centers(idx),mean(Ylim),widths(idx),abs(diff(Ylim)),{'Color',c(i,:)});
        end
    end
    
end

if ~washold; hold off;end
h=gcf;
end

