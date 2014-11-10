function demogs = demog2spss( varagin )
%demo2spss - import demographics tab from Protect2.0 and save as SPSS file
%This function must be ran in the 32-bit version of Matlab
%64-bit matlab will not work because of the drivers/version of MS Access
%For more info: http://www.mathworks.com/help/database/ug/microsoft-access-odbc-windows.html
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
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Jonathan Wilson
% Work address: B Towers
% email: wilsonj3@chp.edu
% June 2014; Last revision: 7/30/14

%------------- BEGIN CODE --------------

% set data path
data_dir = ['C:/kod/SPSS/data/']; 

% If no connection in 7 sec exit
logintimeout(7);

% ODBC driver name
dbname = 'Protect2'; 

% Get data
[data, fieldString] = conn2db(dbname);

% Save it
save([data_dir 'demogs_data'],'data');

% varargout
if(nargout), demogs = data; end

%%%% MAKE THIS INTO A FUNC AND CLEAN IT UP BUT IT WORKS
%Grab all ids numbers
id_nums=[data{:,1}]';
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
    data{idx(i)-1,2}=strcat(data{idx(i)-1,2},'\',data{idx(i),2});
    
    %Combine dates
    if data{idx(i)-1,4}~=data{idx(i),4}
        data{idx(i)-1,4}=strcat(data{idx(i)-1,4},'\',data{idx(i),4});
    end
    
     if data{idx(i)-1,7}~=data{idx(i),7}
        data{idx(i)-1,7}=strcat(data{idx(i)-1,7},'\',data{idx(i),7});
     end
     
     %Delete the duplicate row
     data(idx(i),:)=[];
    
    count=count+1;
end
%%%% End of function

%Clean up "other paitent" data
other_idx=strcmp(data(:,8),'OTHER PATIENT');
data(other_idx,:)={'NaN'};
qnan = cellfun(@any,cellfun(@isnan,data,'UniformOutput',0));
qnan = ( qnan |  strcmp('NaN',data) ); % get rid of 'NaN' entries
data(qnan) = {''}; % replace NaN's with zeros
emptyCells = cellfun('isempty', data); 
data(all(emptyCells,2),:) = [];

% open file pointer for writing DAT file
fid = fopen('C:/kod/SPSS/data/demogspss.dat','w');

%Take care of headers
for hn = fieldString
fprintf(fid,'%s\t',fieldString{:});
end
fprintf(fid, '\n');

%Write data to file...Sloppy brute force
%Since this is hard coded remember to insert or delete strings 
%Based upon the sql cmd
str_fmt = '%d\t%s\t%s\t%s\t%d\t%d\t%s\t%s\t%s\t%d\t%d\t%s\t%s\t%d\t%d\n'; %Can we automate this?
for i=1:size(data,1)
fprintf(fid,str_fmt,data{i,:});
end

%kill pointer
fclose(fid);

return

function [data_out,String]=conn2db(name)
%Set load prefs.
setdbprefs ('NullNumberRead', '');
setdbprefs ('NullStringRead', '');

%Connect to Database
conn=database(name,'','');

%If failed kick out
if ~isempty(conn.Message)
    error('No connection made check driver settings');
    printf('See help for more assistance');
end

%Define SQL command to grab headers and all data

%Grab everything
sql = 'select * from [temp splash demo], [splash demo 1b]'; %can we automate what table we need to grab?

cursor = exec(conn,sql);
cursor = fetch(cursor);
data_out = fetch(conn,sql);

%Headers
String = columnnames(cursor,1);

return






%------------- END OF CODE --------------

