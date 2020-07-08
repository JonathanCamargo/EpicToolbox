function export()
% Generate p-code to easy share with individuals who will just run
% things.

exportPath=[tempdir 'EpicToolbox'];

fprintf('Exporting to %s\n',exportPath);

% List of folders to export:

toExport={'+Topics','install.m'};

for i=1:numel(toExport)
	copyfile(toExport{i},[exportPath filesep toExport{i}]);	
end

makePCode(exportPath,false);
