function kbd = KBNumDist(A,B)

if(~isnumeric(A)), A = str2double(A); end
if(~isnumeric(B)), B = str2double(B); end

% create key distance index matrix
lookup_mat = [0 10-(1:9); 10-(1:9)' toeplitz(0:8)];

kbd = lookup_mat(A+1,B+1);

return
