function iowa_to_spss
% small function to output IOWA data into an SPSS
% friendly format (tab delimited text file) 

% load stored data
load([pathroot 'analysis/iowa/data/iowa_data.mat']);

% open file pointer for writing DAT file
fid = fopen([pathroot 'analysis/iowa/data/iowa2spss.dat'],'w');

% print header
for n = 1:5, fprintf(fid,'win_tot_block%d\t',n); end
for n = 1:5, fprintf(fid,'choice_prop_block%d\t',n); end
fprintf(fid,'ID\n');

for n_id = 1:length(iowa_struct.id)
    
    fprintf(fid,'%d\t',iowa_struct.blk_win_total(n_id,1:5));
    fprintf(fid,'%g\t',iowa_struct.blk_prop1n2to3n4(n_id,1:5));
    fprintf(fid,'%d\n',iowa_struct.id(n_id));
    
end

% close file pointer
fclose(fid);

return