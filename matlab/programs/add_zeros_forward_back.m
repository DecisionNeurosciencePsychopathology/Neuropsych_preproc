%function add_zeros_forward_back(file,index_length)
%Function will currently take in id, the path to the censor_union.1D file,
%and the number of indices you want to censor forawrd and back by.

%Ex index 6 contains a 0 with 1's at index 5 and 7 (1 0 1) 
%add_zeros_forward_back(999,file,1) -> at index(5,6,7) = 0 0 0

%This version is current;y broke don't run it...

addpath('../');

%Get index length
index_length=getenv('index_length');
if strcmpi(index_length, '') 
	index_length=1; 
else
	index_length=str2double(index_length);
end

%Load in the data
%data = load(file);
file=getenv('current_file');
if strcmpi(file, '') 
    error('No file name present');
else
    data=load(file); 
end

%Find the censored data
zero_idx = find(data==0);

%Forward back censoring by the specified distance
for i = 1:length(zero_idx)
    make_zeros(i,:)=zero_idx(i)-index_length:1:zero_idx(i)+index_length;
end

%Rehape it
make_zeros=unique(make_zeros);

%Filter the original data
data(make_zeros) = 0;

%Save it
%fpath = fileparts(file);
%save([fpath filesep sprintf('censor_union_%d_forback_%d.1D',id,index_length)],'data')
%save(file,'data', '-ascii')
file = sprintf('%d_forback.1D',index_length);

fid=fopen(file,'wt');
fprintf(fid,'%d\n',data);
fclose(fid);

%exit
