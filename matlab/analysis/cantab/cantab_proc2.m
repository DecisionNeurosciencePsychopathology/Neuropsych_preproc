%8/15/2014
%Writeen by Jan Kalkus
%Edited by Jon Wilson 
%This script will (hopefully) take in new CANTAB files and save them into one
%giant repository
%Probably has some bugs to work out but it ran!
%Lsat edit: 9/24/14

%Grab files
new_files=dir([pathroot 'analysis/cantab/data/raw']);
new_files=struct2cell(new_files)';

%Make sure to update regexp in the next ~900 years
f_names = ~cellfun(@isempty,regexp(new_files(:,1),'2\d\d\d'));
f_names = new_files(f_names);

%Merge them all into one big file
if ~isempty(f_names)
        for i = 1:length(f_names)
            mergeCANTAB(f_names{i});
        end
else
	disp('There are no new files for processing...');
end

% CANTAB filename
%filename = [pathroot 'analysis/cantab/foo/raw/Summaryfoosheet large.csv'];
%filename = [pathroot 'analysis/cantab/foo/raw/Summaryfoosheet -- beginning to end (excluding clock failure).csv'];
%filename = [pathroot 'analysis/cantab/foo/raw/tmp/Summaryfoosheet all.csv'];
%filename = [pathroot 'analysis/cantab/foo/raw/tmp/Summaryfoosheet EVERYTHING.csv'];
filename = [pathroot 'analysis/cantab/SummaryDatasheet DataRepos.xls'];

% read in file
[~,~,raw_foo] = xlsread(filename);


%% filter out other protocols 

% not sure why I'm separating this
header_foo = raw_foo(1,:);
q_warnings = ~cellfun(@isempty,regexp(header_foo,'^Warning [0-9]{1,3}'));

% first get rid of NaN entries
qnan = cellfun(@any,cellfun(@isnan,raw_foo,'UniformOutput',0));
qnan = ( qnan |  strcmp('N/A',raw_foo) ); % also get rid of 'N/A' entries
raw_foo(qnan) = {''}; % replace NaN's with zeros

% regular expression string to match our protocols
proto_pattern = '^suicide|^protect|(^additional tests battery)';

% return matches
qproto = ~cellfun(@isempty,regexpi(raw_foo(:,5),proto_pattern));

%% go through IDs

q_valid_id = cellfun(@MatchID,raw_foo(qproto,1));

%% clean up foo

% filter out other protocols
tmp_good_protocols = raw_foo(qproto,~q_warnings);

% remove NaN entries
foo = tmp_good_protocols(~isnan(q_valid_id),:);

%Jon-This could be wrong but replace the first column of foo with the correct
%Matched ID's. May cause furure error watch closely...

bar = q_valid_id(~isnan(q_valid_id));
bar = num2cell(bar);
foo(:,1)=bar(:);

% check to see if there are any duplicates and remove them based on date
%n_u_ids = length(unique(cell2mat(foo(:,1))));
n_u_ids = unique(cell2mat(foo(:,1)));
eq(size(foo,1),n_u_ids)

%idxs = zeros((length(foo(:,1))-length(n_u_ids))*2,1);
%for i=1:length(foo(:,1))
%    j=find(n_u_ids(89)==cell2mat(foo(:,1)));
%    if length(j)>=2
%        idxs(i)=j;
%    end
%end



%% print out foo to file

% sort first
[~,qs] = sort(cell2mat(foo(:,1)));
foo = foo(qs,:);

%Second cleaning. Possibly make this a function later to clean up code.
tmp = zeros(length(foo(:,1)),1);
bar=cell2mat(bar);
bar=sort(bar);
%Find where there are duplicates
for i = 2:length(bar)
    if bar(i)==bar(i-1)
        tmp(i,1)=1;
    end

end
idx=find(tmp);
count = 0;
for i=1:length(idx)
    %Not so clean workaround look into making this more robust
    idx(i)=idx(i)-count;
    
    %Compare Dates and delete latest task data
    if datenum(foo{idx(i)-1,6})<datenum(foo{idx(i),6})
        foo(idx(i),:)=[];
    else
        foo(idx(i)-1,:)=[];
    end
    
    count=count+1;
end

% !!!!! --- need to add header --- !!!!! % You might want to add a line
% where to delete the file first as well to reduce any confusion in SPSS
xlswrite('file_out_test4_new.xls',[header_foo(~q_warnings); foo]);
