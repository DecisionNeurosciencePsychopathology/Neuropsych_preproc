function bart_to_spss
% small function to output BART data into an SPSS
% friendly format (tab delimited text file) 
%
% Jan Kalkus
% 2013-10-28
%
% Jon Wilson
% 2014-08-06

% load stored data
load([pathroot 'analysis/bart/data/bart_data.mat']);

% open file pointer for writing DAT file
fid = fopen([pathroot 'analysis/bart/data/bart2spss.dat'],'w');

% print header
printHeader(bart_struct,fid);

% print data
printData(bart_struct,fid);

% close file pointer
fclose(fid);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function printHeader(data_struct,file_pointer)

% metrics across entire experiment
for fnm = fieldnames(data_struct.across_all_trials)
    fprintf(file_pointer,'total_%s\t',fnm{:});
end

% metrics across each block
for block_n = 1:length(data_struct.across_blocks)
    field_names = fieldnames(data_struct.across_blocks{block_n});
    for f = 1:length(field_names)
        fprintf(file_pointer,'block_%d_%s\t',block_n,field_names{f});
    end
end

% ID (and create a new line)
fprintf(file_pointer,'ID\n');

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function printData(data_struct,file_pointer)

% collect data into single matrix
final_matrix = [
    struct2array(data_struct.across_all_trials), ...
    struct2array(data_struct.across_blocks{1}), ...
    struct2array(data_struct.across_blocks{2}), ...
    struct2array(data_struct.across_blocks{3}), ...
    data_struct.id, ...
];
 % So becasue we would get funky errors in the data I switched this around
 % to print the data file from a cell. 
 final_matrix = num2cell(final_matrix);
 
 %Find where there are Nan's replace them with ''
 elm = find(isnan(final_matrix));
 
 for i = 1:length(elm)
     final_matrix{elm(i)}='';
 end
 
 % print to file 
str_format = [repmat('%g\t',1,( size(final_matrix,2)-1 )) '%6d\n'];
 for i=1:size(final_matrix,1)
     fprintf(file_pointer,str_format,final_matrix{i,:});
 end
 
 %OLD CODE...
% replace NaN's with some sort of error code
% Setting this to a value of '999999' was causing problems with SPSS
% as it was drastically skewing the frequency hist.
%final_matrix(isnan(final_matrix)) = 12346;

% print to file (make sure to transpose matrix --because fprintf)
%str_format = [repmat('%g\t',1,( size(final_matrix,2)-1 )) '%6d\n'];
%fprintf(file_pointer,str_format,final_matrix');

return

