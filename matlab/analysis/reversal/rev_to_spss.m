function rev_to_spss
% small function to output BART data into an SPSS
% friendly format (tab delimited text file) 
%
% Jan Kalkus
% 2014-04-15

% load stored data
load([pathroot 'analysis/reversal/data/rev_data.mat']);

% open file pointer for writing DAT file
fid = fopen([pathroot 'analysis/reversal/data/rev2spss.dat'],'w');

% print header
printHeader(rev_struct,fid);

% print data
printData(rev_struct,fid);

% close file pointer
fclose(fid);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function printHeader(data_struct,file_pointer)

fnm = fieldnames(data_struct);
fnm = fnm(cellfun(@(x) ~any(regexp(x,'reversal|specs|prob')),fnm));
cellfun(@(f) fprintf(file_pointer,'%s\t',f),fnm);

% total, pre-, and post-reversal prob. switch error counts
for hn = fieldnames(data_struct.prob_switch)
    err_name = strcat(hn,'_prob_switch');
    fprintf(file_pointer,'%s\t',err_name{:});
end
    
% convert last byte from \t to \n
fseek(file_pointer,-1,'cof');
fprintf(file_pointer,'\n');

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function printData(data_struct,file_pointer)

% collect data into single matrix
final_matrix = [
    data_struct.ID, ...
    data_struct.spont_switch, ...
    data_struct.persev_error, ...
    data_struct.prob_switch.total, ...
    data_struct.prob_switch.pre_reversal, ...
    data_struct.prob_switch.post_reversal ...
];

% replace NaN's with some sort of error code
final_matrix(isnan(final_matrix)) = 999999;

% print to file (make sure to transpose matrix --because of fprintf)
str_format = ['%6d\t' repmat('%g\t',1,( size(final_matrix,2)-2 )) '%g\n'];
fprintf(file_pointer,str_format,final_matrix');

return

