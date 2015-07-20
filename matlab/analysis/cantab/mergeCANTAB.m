function mergeCANTAB(nu_file_name)
%Loop starts here
% CANTAB filename
% The actual game ball
filename = [pathroot 'analysis/cantab/SummaryDatasheet DataRepos.xls'];

%Old tmp code delete later
%filename = [pathroot 'analysis/cantab/SummaryDatasheet tmp data repos.xls'];

% read in files
[~,~,raw_data] = xlsread(filename);

%Rewrite orginal file
xlswrite('SummaryDatasheet DataRepos.xls',raw_data);

%Old temp code delete later
%xlswrite('SummaryDatasheet tmp data repos.xls',[raw_data]);

%Read in new file(s)
nufile=[pathroot 'analysis/cantab/data/raw/' nu_file_name];
[~,~,nuraw_data] = xlsread(nufile);

%Get tmp row data
nu_row = size(nuraw_data,1);

%Reshape/remove header data
nuraw_data=repmat(nuraw_data(2:nu_row,:),1,1);

%Find where first empty cell in data repository is located
first_empty_cell=['A',num2str(size(raw_data,1)+1)];

%I think I can delete this line of code
%first_empty_cell = strcat('A',first_empty_cell);

%Update main data repository
xlswrite('SummaryDatasheet DataRepos.xls',nuraw_data,1,first_empty_cell)

%Old tmp code delete later
%xlswrite('SummaryDatasheet tmp data repos.xls',[nuraw_data],1,first_empty_cell);

%Reorganize raw files
dest = [pathroot 'analysis/cantab/data/processed_files'];
movefile(nufile,dest);


return

%Reset This is more for debug purposes
%If things get to screwy remember to delete the xls file and start over...
%REMINDER all files in processed data after 2014-04-22 will need to be 
%reprocessed.
%filename = [pathroot 'analysis/cantab/data/raw/tmp/SummaryDatasheet EVERYTHING.csv'];
% read in files
%[~,~,raw_data] = xlsread(filename);
%xlswrite('SummaryDatasheet DataRepos.xls',[raw_data]);