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
% June 2014; Last revision: 5/13/2015

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
    updateIDList
end

% open file pointer for writing DAT file
fid = fopen([data_dir 'demogspss.dat'] ,'w');

%Strip header information
header_info = data(1,:);
data(1,:)=[];

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

