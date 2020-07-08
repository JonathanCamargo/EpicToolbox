classdef FeatureSelector
% Class to select features from our data. Possible feature selection
% algorithms include:
%
% see also: heuristic, forwardFeatureSelection

    properties
        selectionMethod='';
        selectionProperties=''; % ex Neural network parameters
    end
    
    methods(Static)
        Info=Heuristic(obj,input,output)
        Info=ForwardFeatureSelection(obj,input,output)
        Info=HeuristicCorrelation(obj,input,output)
		Info=MutualInformation(input,output)
    end
    
    methods
        function obj=FeatureSelector(selectionMethod)
            % FeatureSelectoor (selection method);
            if(ismethod(obj,selectionMethod))
                obj.selectionMethod=selectionMethod;
            else
                error('Feature selection method %s not defined uin Feature Selector Class',selectionMethod);
            end
        end
        
        function select(obj, input, output, varargin)
            % Parse varargin
            % check if outputpath is char or cell
            % check if Output is char or cell and only pass those into
            % algorithm
            % Options: name value pairs
            % ----------------------------------------------
            %  name    value1/value2/(default)  Description
            % ----------------------------------------------
            % 'Save'        | (true)/false            | Save the output into mat files
            % 'OutputPath'  | 'FeatureSelector_output'|  Directory to save the mat files in
            % can also be a cell array with the path of the output matfiles.
            % 'OutputName'  | 'FeatureSelectionInfo'  |  File name to save the mat files as
            p=inputParser;
            validStrOrCell=@(x) iscell(x) || ischar(x);
            p.addParameter('Save',true);
            p.addParameter('OutputPath','FeatureSelector_output',validStrOrCell);
            p.addParameter('OutputName','FeatureSelectionInfo',validStrOrCell);
            p.parse(varargin{:});
            
            Save=p.Results.Save;
            OutputPath=p.Results.OutputPath;
            
            if ischar(OutputPath)
                %Create the list of output paths
                OutputPath=fullfile(p.Results.OutputPath, p.Results.OutputName);
                %Create directories if they do not exist
                [dirname,~,~]=fileparts(OutputPath);
                if ~exist(dirname,'dir')
                    mkdir(dirname);
                end
            else
                error('Output Path %s not valid', OutputPath);
            end
            
            selectionInfo=eval(['obj.' obj.selectionMethod '(input,output)']);
            
            if(Save)
                save(OutputPath,'selectionInfo')
            end
        end
    end
    
end