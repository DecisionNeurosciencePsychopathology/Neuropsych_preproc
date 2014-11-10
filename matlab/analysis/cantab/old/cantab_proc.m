% CANTAB filename
%filename = [pathroot 'analysis/cantab/data/raw/SummaryDatasheet large.csv'];
%filename = [pathroot 'analysis/cantab/data/raw/SummaryDatasheet -- beginning to end (excluding clock failure).csv'];
%filename = [pathroot 'analysis/cantab/data/raw/tmp/SummaryDatasheet all.csv'];
filename = [pathroot 'analysis/cantab/data/raw/tmp/SummaryDatasheet EVERYTHING.csv'];

% read in file
[~,~,raw_data] = xlsread(filename);

%% filter out other protocols 

% not sure why I'm separating this
header_data = raw_data(1,:);
q_warnings = ~cellfun(@isempty,regexp(header_data,'^Warning [0-9]{1,3}'));

% first get rid of NaN entries
qnan = cellfun(@any,cellfun(@isnan,raw_data,'UniformOutput',0));
qnan = ( qnan |  strcmp('N/A',raw_data) ); % also get rid of 'N/A' entries
raw_data(qnan) = {''}; % replace NaN's with zeros

% regular expression string to match our protocols
proto_pattern = '^suicide|^protect|(^additional tests battery)';

% return matches
qproto = ~cellfun(@isempty,regexpi(raw_data(:,5),proto_pattern));

%% go through IDs

q_valid_id = cellfun(@MatchID,raw_data(qproto,1));

%% clean up data

% filter out other protocols
tmp_good_protocols = raw_data(qproto,~q_warnings);

% remove NaN entries
foo = tmp_good_protocols(~isnan(q_valid_id),:);

%Jon-This could be wrong but replace the first column of foo with the correct
%Matched ID's. May cause furure error watch closely...

bar = q_valid_id(~isnan(q_valid_id));
bar = num2cell(bar);
foo(:,1)=bar(:);

% check to see if there are any duplicates
n_u_ids = length(unique(cell2mat(foo(:,1))));
eq(size(foo,1),n_u_ids)

%% print out data to file

% sort first
[~,qs] = sort(cell2mat(foo(:,1)));
foo = foo(qs,:);

% !!!!! --- need to add header --- !!!!! %
xlswrite('file_out_test3_new.xls',[header_data(~q_warnings); foo]);
