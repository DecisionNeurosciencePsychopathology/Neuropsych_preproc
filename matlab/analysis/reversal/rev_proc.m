function data_out_struct = rev_proc()

% get data and IDs from directory information
data_struct = readInData;

% check IDs
matched_ids = matchAndFilterIDs(data_struct.ids);

% prune data structure
data_struct = pruneDataStructure(data_struct,matched_ids.matched_id);

% organize data into structure
rev_struct = organizeDataStruct(data_struct);

% save file
save('data/rev_data.mat','rev_struct');

% if requested, return data structure
if(nargout), data_out_struct = rev_struct; end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function data_out = readInData()
% read in raw data files from the directory and get IDs from the file names

% get file names from directory information
base_path = [pathroot 'analysis/reversal/data/raw/'];
dir_data = dir([base_path '*.rev']);
file_list = strcat(base_path,{dir_data.name}');

% extract IDs from file name
data_out.ids = cellfun(@(r) regexp(r,'[0-9]{5,6}','match'),file_list);

% read in file data
data_out.data = cellfun(@readInRawDataFile,file_list);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function raw_data_out = readInRawDataFile(file_name)

% open file pointer
fid = fopen(file_name,'r');

% find appropriate line
header_regexp = '^ {2,}trial.*stim.[pos|feed]';
fid = ffwdToLastHeaderLine(fid,header_regexp);

% read in data
raw_data_out = textscan(fid,getStrFormat,'CollectOutput',1);

% terminate file pointer
fclose(fid);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function s = getStrFormat()

s = [...
    ' %f' ...   %  (1) 'trial':          trial number
    ' %f' ...   %  (2) 'correctstim':  < doesn't seem like it to me >
    ' %f' ...   %  (3) 'choice':         stim choice
    ' %f' ...   %  (4) 'resptime':       RT
    ' %f' ...   %  (5) 'stim1pos':       stim 1 position
    ' %f' ...   %  (6) 'stim2pos':       stim 2 position
    ' %f' ...   %  (7) 'stim1feed':      correct stimulus choice
    ' %f' ...   %  (8) 'stim2feed':      incorrect stimulus choice
    ' %f' ...   %  (9) 'stim1':        < stim 1 identity? (not clear what this is) >
    ' %f' ...   % (10) 'stim2':        < stim 2 identity? (not clear what this is) >
];  

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function file_id = ffwdToLastHeaderLine(file_id,regular_expression)
% some 'reversal' data files contain multiple header lines. it 'textscan' 
% will only read data from the first to the second header. this function 
% returns a file identifier with a position after the last header line.

% loop until we reach the end of the file
while(~feof(file_id))
    
    % check if current line matches regular expression
    if(any(regexp(fgetl(file_id),regular_expression)))
        current_byte_position = ftell(file_id);
    end
    
end

% fast forward file identifier to current byte position
fseek(file_id,current_byte_position,'bof');

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function matched_ids = matchAndFilterIDs(raw_id_data)

% allocate memory
matched_ids.orig_id    = str2double(raw_id_data);
matched_ids.matched_id = nan(size(raw_id_data));

% match them
tmp = cellfun(@MatchID,raw_id_data);

% get rid of duplicates (for now)
[foo,q_tmp] = unique(tmp,'stable');
matched_ids.matched_id(q_tmp) = foo;

% visual sanity check
%[matched_ids.matched_id tmp eq(matched_ids.matched_id,tmp)]

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function pruned_struct = pruneDataStructure(data_to_prune,id_index)

% get non-NaN indices
q_valid_entries = ~isnan(id_index);

% filter out NaN's
pruned_struct.ids  = id_index(q_valid_entries);
pruned_struct.data = data_to_prune.data(q_valid_entries);

% sort entries by ID
[pruned_struct.ids,qsort] = sort(pruned_struct.ids);
pruned_struct.data = pruned_struct.data(qsort);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function final_struct = organizeDataStruct(data_struct)

% first filter out bad entries (this is hopefully temporary); there is a
% bug that needs to be fixed in the raw data reading section. there are
% some files that contain multiple headers and some rows of data before a 
% larger body of data (result of an aborted testing session?)
[n_trial,~] = cellfun(@size,data_struct.data);
q_valid = ( n_trial > 40 );

% --- store simple stats --- %

% # # # # # THIS IS A MESS # # # # # %
% # # # # #   CLEAN IT UP  # # # # # %
d2fStruct = ... 
    @(dstr,coln,q) cellfun(@(x) x(:,coln),dstr(q),'UniformOutput',0);

final_struct.ID = data_struct.ids(q_valid);

final_struct.specs.stim_choice = d2fStruct(data_struct.data,3,q_valid);
final_struct.specs.RT          = d2fStruct(data_struct.data,4,q_valid);
final_struct.specs.stim1pos    = d2fStruct(data_struct.data,5,q_valid);
final_struct.specs.stim2pos    = d2fStruct(data_struct.data,6,q_valid);


% --- define function handles for various error types --- %
errorBool = @(fh,q,data) cellfun(fh,data(q),'UniformOutput',0);

fh.prob_sw_er  = @(d)  probSwitchErrCount(d(:,3),( d(:,3) == d(:,7) ));
fh.spont_sw_er = @(d) spontSwitchErrCount(d(:,3),( d(:,3) == d(:,7) )); 
fh.persev_er   = @(d)      persevErrCount(d(41:end,3));

% function handles for pre- and post-reversal error counts
first_half_sum  = @(x) sum(x(1:40));
second_half_sum = @(x) sum(x(41:end));


% --- probabilistic reversal errors --- %
final_struct.prob_switch.total  = ...
    cellfun(@sum,errorBool(fh.prob_sw_er,q_valid,data_struct.data));

% pre-reversal counts
final_struct.prob_switch.pre_reversal = ...
    cellfun(first_half_sum,errorBool(fh.prob_sw_er,q_valid,data_struct.data));

% post-reversal counts
final_struct.prob_switch.post_reversal = ...
    cellfun(second_half_sum,errorBool(fh.prob_sw_er,q_valid,data_struct.data));


% --- spontaneous switch errors --- %
final_struct.spont_switch = ...
    cellfun(@sum,errorBool(fh.spont_sw_er,q_valid,data_struct.data));


% --- perseverative errors --- %
tmp = errorBool(fh.persev_er,q_valid,data_struct.data);
final_struct.persev_error = cellfun(@sumFirstErrorTrain,tmp);
%final_struct.persev_error = ...
%    cellfun(second_half_sum,errorBool(fh.persev_er,q_valid,data_struct.data));

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function prob_switch_index = probSwitchErrCount(stim_choice,choice_rewarded,~)

% pre-allocate array memory
prob_switch_index = false(size(stim_choice));

% make sure for index dimensions will be correct
if(size(choice_rewarded,2) > size(choice_rewarded,1))
    choice_rewarded = choice_rewarded';
end

% assign stimuli to choices
current_stim  = stim_choice(2:end);
previous_stim = stim_choice(1:end-1);

% assign feedback to choices
current_reward  = choice_rewarded(2:end);
previous_reward = choice_rewarded(1:end-1);

% compute
prob_switch_index(2:end) = ( ...
	ne(current_stim,previous_stim) & ...
    ~previous_reward & ~current_reward ... 
);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function spont_switch_index = spontSwitchErrCount(stim_choice,choice_rewarded)

% pre-allocate array memory
spont_switch_index = false(size(stim_choice));

% make sure this array has the appropriate dimensions 
if(size(choice_rewarded,2) > size(choice_rewarded,1))
    choice_rewarded = choice_rewarded';
end

% assign stimuli to choices
current_stim  = stim_choice(2:end);
previous_stim = stim_choice(1:end-1);

% assign feedback to choices
current_reward  = choice_rewarded(2:end);
previous_reward = choice_rewarded(1:end-1);

% compute
spont_switch_index(2:end) = ( ...
	ne(current_stim,previous_stim) & ...
	previous_reward & ~current_reward ...
);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function persev_err_index = persevErrCount(stim_choice)

% pre-allocate array memory
persev_err_index = false(size(stim_choice));

% assign stimuli to choices
current_stim  = stim_choice(2:end);
previous_stim = stim_choice(1:end-1);

% compute
persev_err_index(2:end) = ( ...
	eq(current_stim,previous_stim) & ...
	eq(current_stim,1) ...
);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function train_sum = sumFirstErrorTrain(error_train)
% we only want error counts for the first train of
% uninterrupted perseverative errros


if(~any(error_train))
    
    % if there were no errors, skip processing below
    train_sum = 0;

else
    
    % find first error in first train
    q_train_beg = find(error_train,1,'first');
    
    % find non-errors
    tmp = find(~error_train);

    % find last error in first train
    q_train_end = tmp(find(tmp > q_train_beg,1,'first'));

    % some subjects perseverate until the task is done
    if(isempty(q_train_end))
        q_train_end = length(error_train);
    end
    
    % count the errors
    train_sum = q_train_end - q_train_beg;
    
end

return

