function obj = configureHeader(obj,varargin)
% Set up the header for the feature extractor by looking through the
% featureoptions and number of channels.
% The header shows what information is contained at each index of the
% feature vector.
% Header is dependent on the type of features and number of channels
% previously set in the extractor.
% Optionally you can pass the list of channels so that it does not use
% generic ones ('CH_1','CH_2'...)
%%%%%%%%%%%%%%%%%%%%%%%%%%% WARNING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The order of the header produced by this function is dependent
% on the parse function order in FeatureExtractor.m.
% The labels of the header produced by this function are dependent
% on the features extracted at each specific algorithm (e.g. TC_extract.m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Remember that featureOptions could have the following:
% Names={'TD','AR','AROrder','WT','WTLevels','WTname','EN'};

featureOptions=obj.featureOptions;

if nargin>1
    channel_headers=varargin{1};
    obj.channels=numel(channel_headers);
%    if (length(channel_headers)~=obj.channels)
%        error('Number of channels is not consistent');
%    end
else
    channel_headers=compose('CH%i',1:obj.channels);
end

% For convenience I'm ordering the header in alphabetical order w.r.t
% the feature code (e.g. AR,..., TD,..., WT)
header={};
if (featureOptions.AR)
    AROrder=featureOptions.AROrder;
    header=[header{:}, AR_header(AROrder)];
end

if (featureOptions.EN)
    header=[header{:}, EN_header()];
end
if (featureOptions.TD)
    header=[header, TD_header()];
end
if (featureOptions.MEAN)
    header=[header, MEAN_header()];
end
if (featureOptions.LAST)
    header=[header, LAST_header()];
end

if (featureOptions.WT)
    WTLevels=featureOptions.WTLevels;
    WT_header(WTLevels);
    header=[header{:},WT_header(WTLevels)];
end

obj.features_header=header;

header={};
for i=1:obj.channels
    if isempty(obj.features_header)
        header=[header,channel_headers{i}];
    else
        for j=1:numel(obj.features_header)
            header=[header,{[channel_headers{i} '_' obj.features_header{j}]}];
        end
    end
end
obj.header=header;

obj.isReady=true;

%%%%%%%%%%% Functions for creating each extractor's header %%%%%%%%%%%%%%%%
    function header=AR_header(AROrder)
        header=cell(1,AROrder);
        for i=1:AROrder
            header{i}=sprintf('a_%i',i);
        end
    end


    function header=EN_header()
        %header={'mean','zeroCross','slopeSignChange','waveformLenght'};
        header={'entropy'};
    end

    function header=TD_header()
        header={'rms','mean','meanAbs','zeroCross','slopeSignChange','waveformLength','min', 'max', 'std'};
        %header={'rms'};
    end
    function header=LAST_header()
        header={'last'};
        %header={'rms'};
    end
    function header=MEAN_header()
        header={'mean'};
        %header={'rms'};
    end

    function header=WT_header(levels)
        header=cell(1,3);
        header(1:3)={sprintf('min_CA_%i',levels),sprintf('max_CA_%i',levels),sprintf('stddev_CA_%i',levels)};
        for k=levels-(1:levels)
            header=[header,{sprintf('min_CD_%i',k),sprintf('max_CD_%i',k),sprintf('stddev_CD_%i',k)}];
        end
    end
end
