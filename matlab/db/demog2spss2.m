function demogs = demog2spss2( varagin )
%demo2spss - import demographics tab from Protect2.0 and save as SPSS file
%This function runs a macro saved in the Protect2.0.accdb access file. If
%the file name changes, or the macro get deleted this script will have to
%adjust accordingly. File output is a .dat file for universal use on all
%systems.
%
% Syntax:  [demogs] = demog2spss(varagin)
%
% Inputs:
%    None so far
%
% Outputs:
%    A matlab data file and a .dat file
%
% Example:
%    demog2spss
%    demog2spss(1) to udpate demographic list
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
% Other files needed: Protect2.0.accdb; Currently saved in Y: drive.
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Jonathan Wilson
% Work address: B Towers
% email: wilsonj3@chp.edu
% June 2014; Last revision: 11/4/2014

%------------- BEGIN CODE --------------
%origin dir
origin = pwd;


% set data path 
%cd(pathroot)
if(~isdeployed)
    cd(fileparts(which(mfilename))); %if not in directory, move here
end

cd ../..
data_dir = [pwd '/SPSS/data/'];

%Update demog data
update_flag = 0;



if update_flag ==1
%     %Connect to database and export mast list
%     h= actxserver('Access.Application');
%     
%     %invoke(h,'OpenCurrentDatabase','Y:\Protect 2.0.accdb'); %Protect DB
%     invoke(h,'OpenCurrentDatabase','Y:\Front End (For Copying)\Jon\Protect 2 - Front End (Jon).accdb'); %Protect DB
%     %invoke(h.DoCmd,'RunMacro','exportDemog');
%     invoke(h.DoCmd,'RunMacro','ExportDemographics'); %Macro is currently only executable on my (Jon's) computer
%     h.Visible = 0;
updateIDList
end

%Load data into matlab
filename = [pathroot 'db/splashDemo2.xlsx'];
[~,~,data] = xlsread(filename);

%Strip header information
header_info = data(1,:);
data(1,:)=[];

%Map out needed info from cols index, rmv white space for setfield
index=[];
for i = 1:length(header_info)
    %index = setfield(index, regexprep(header_info{i},'[^\w'']',''),...
    %find(strcmpi(header_info,header_info(i))));
    index = setfield(index, regexprep(header_info{i},'[^\w'']',''),i);
end


%Grab all ids numbers
id_nums=[data{:,index.ID}]';
tmp = zeros(length(id_nums),1);

%Find where there are duplicates
for i = 2:length(id_nums)
    if id_nums(i)==id_nums(i-1)
        tmp(i,1)=1;
    end
end
idx=find(tmp);
count = 0;
for i=1:length(idx)
    %Not so clean workaround look into making this more robust
    idx(i)=idx(i)-count;
    
    %PROTO field
    data{idx(i)-1,index.PROTO}=strcat(data{idx(i)-1,index.PROTO},'/',data{idx(i),index.PROTO});
    
    %Combine dates adjust for SPSS UTF-16 error
    if ~strcmpi(data{idx(i)-1,index.Consent},data{idx(i),index.Consent}) && strcmpi(data{idx(i)-1,index.Consent},'NaN')
        data{idx(i)-1,index.Consent}=strcat(data{idx(i)-1,index.Consent},'--',data{idx(i),index.Consent});
    end
    
    if ~strcmpi(data{idx(i)-1,index.DateofTermination},data{idx(i),index.DateofTermination}) && strcmpi(data{idx(i)-1,index.DateofTermination},'NaN')
        data{idx(i)-1,index.DateofTermination}=strcat(data{idx(i)-1,index.DateofTermination},'--',data{idx(i),index.DateofTermination});
    end
    
    %Delete the duplicate row
    data(idx(i),:)=[];
    
    count=count+1;
end

%Clean up "other paitent" data, rmv 'NaN' entries
other_idx=strcmp(data(:,index.PATTYPE),'OTHER PATIENT');
data(other_idx,:)={'NaN'};
qnan = cellfun(@any,cellfun(@isnan,data,'UniformOutput',0));
qnan = ( qnan |  strcmp('NaN',data) ); % get rid of 'NaN' entries
data(qnan) = {''}; % replace NaN's with zeros
emptyCells = cellfun('isempty', data);
data(all(emptyCells,2),:) = [];

% open file pointer for writing DAT file
fid = fopen([data_dir 'demogspss.dat'] ,'w');

%Take care of headers
for hn = 1:length(header_info)
    fprintf(fid,'%s\t',header_info{hn});
end
fprintf(fid, '\n');

str_fmt=[]; %automate str formatting
for i = 1:size(data,2)
    if ischar(data{1,i})
        tempstr = '%s';
    else
        tempstr = '%d';
    end
    str_fmt = strcat(str_fmt,tempstr,'\t');
end
str_fmt(end)='n';

for i=1:size(data,1)
    fprintf(fid,str_fmt,data{i,:});
end

% Save it
save([data_dir 'demogs_data'],'data');

% varargout
if(nargout), demogs = data; end

%kill pointer
fclose(fid);
fclose all;

%Return to origin
cd(origin);

return

%------------- END OF CODE --------------

