function tbl=hdf52table(filename)
% tbl=hdf52tbl(file)
% Load a mat file in hdf5 format and convert to a table
z=load(filename);
tbl=array2table(z.data,'VariableNames',z.names);
end
