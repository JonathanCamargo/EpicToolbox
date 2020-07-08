tg = uitabgroup; % tabgroup
for ii = 1:20
    thistab = uitab(tg,'Title',['Fig' num2str(ii)]); % build iith tab
    axes('Parent',thistab); % somewhere to plot
    plot(rand(1,100));
end