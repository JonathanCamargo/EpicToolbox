function table2hdf5(tbl,filename)
% table2hdf5(tbl,file)
% Save a table to a mat file in hdf5 format.

mkdirfile(filename);
data=tbl.Variables;
names=tbl.Properties.VariableNames;
parsave(filename,'data',data,'names',names,'-v7.3')

end
