function polina_trust_game_pilot_proc

% code
readInData(9);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function data_out = readInData(id)
% this is a temporary and very slow solution

% read in "raw" Excel data file
%file_name = [pathroot 'analysis/bandit/fmri/data/raw/' num2str(id) '/' num2str(id) '.xlsx'];
file_name = [pathroot 'analysis/trust game/pilot/data/raw/natalie test data.xlsx'];
[~, ~, rawdata] = xlsread(file_name);

% separate headers and data and add handy indexing function handle
data_out.names = rawdata(1,:)';
data_out.data  = rawdata(2:end,:);

% f(x) returns binary list of indices matching regexp input
data_out.query_field_location = @(q,d) ~cellfun(@isempty,regexp(d.names,q)); 

fh = @(s) data_out.query_field_location(s,data_out); % not sure if we'll need this...


% (?=test)expr  match BOTH 'test' and 'expr' <--- can't get this to work how I'd like
%  fh('Procedure\[.*\]');

field_names_to_keep = {'Procedure\[.*\]','$'};

% % rename certain header strings for slightly more consistency
% for n_to_rename = {'computerplayblank','mystery'}
%     for m_each_suffix = find(fh(n_to_rename{:}))'
%         
%         % add 'showstim' prefix to these names
%         new_name = ['showstim' data_out.names{m_each_suffix}];
%         data_out.names{m_each_suffix} = new_name;
%         
%     end
% end

return