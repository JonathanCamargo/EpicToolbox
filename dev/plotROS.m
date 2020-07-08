clear; clc;
files = matchFiles('post/RawMatlab/sf2018/*/imu/ab07/*/ramp_3_l*.mat');

for f=1:length(files)
    [~,name,~] = fileparts(files{f});
    disp(['Processing: ' name])
    load(files{f})

    for i=2:width(data)
        figure(1)
        plot(data{:,1},data{:,i})
        pause 
    end
end