function data_out = bart_preproc()
% 2013-09-05 Jan Kalkus
% a function to process basic BART data

% find list of files/new files
file_data = findNewBARTFiles();

% if there are no new files, stop execution here
if(isempty(file_data.new_files)), return; end

% read in files 
raw_data = readInData(file_data);

% filter out IDs that have already been processed
prepared_data = pruneRawData(raw_data);

% ID number verification 
filtered_ids = matchAndFilterIDs(prepared_data{1});

% organize data into structure
bart_struct = organizeDataStruct(prepared_data,filtered_ids); 

% store file metadata in structure
bart_struct.specs.file_data   = file_data.data; 
bart_struct.specs.original_id = filtered_ids.orig_ID(filtered_ids.q);

% save file
save([pathroot 'analysis/bart/data/bart_data.mat'],'bart_struct');

% optional data output
if(nargout), data_out = bart_struct; end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function list_out = findNewBARTFiles()
% needs to be re-tooled for BART usage

% get ids from existing filenames
data_file_path = [pathroot 'analysis/bart/data/raw/BART Mainballoon *.dat'];
bart_dir_listing = dir(data_file_path);

% load existing database (if there is one)
if(exist('data/bart_data.mat','file') == 2) 
    load('data/bart_data.mat');
    procd_files = {bart_struct.specs.file_data.name}';
else
    procd_files = {};
end

% find out which files have already been processed
files_in_dir  = {bart_dir_listing.name}';

% find only the new files (and their indices)
[~, q_dir] = setxor(files_in_dir,procd_files);

% we only want files unique to data dir (this protects against
% the contingency --regardless of its liklihood-- where there 
% are files in the database which not in the directory)
just_the_new_files = files_in_dir(q_dir);

% organize into single struct
list_out.data       = bart_dir_listing;
list_out.new_files	= just_the_new_files;

if(isempty(list_out.new_files))
    fprintf('No new files detected.\n');
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function data_out = readInData(file_struct)

% pre-allocate
tmp_data = cell(size(file_struct.new_files));

% loop through filenames and read in their raw data
for file_n = 1:numel(file_struct.new_files)
    tmp_data(file_n) = {readInRawDataFile(file_struct.new_files{file_n})};
end

% remove one layer of nested cells
tmp = reshape([tmp_data{:}],size(tmp_data{1},2),size(tmp_data,1))';

% group together data from all files into one big set
data_out = cell(size(tmp,2),1); % pre-allocate mem.
for n_col = 1:size(tmp,2)
    data_out(n_col) = {cat(1,tmp{:,n_col})};
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function d = readInRawDataFile(filename)
% simple function reads in data from raw files output by BART task

fid = fopen([pathroot 'analysis/bart/data/raw/' filename],'r');
d = textscan(fid,getStrFormat,'Delimiter','\t','CollectOutput',1,'HeaderLines',1);

fclose(fid); % terminate pointer

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function s = getStrFormat()

s = ['%*s '... % (1)                X - some sort of counter
    '%f '...   %       id number/fragment
    '%*s '...  %                    X - ? 
    '%*s '...  %                    X - gender
    '%*s '...  % (5)                X - order/sorting mode?
    '%*s '...  %                    X - ?
    '%*s '...  %                    X - RA id
    '%s '...   %       date
    '%s '...   %       time
    '%f '...   % (10)  duration (sec.)
    '%f '...   %       n balloons (sanity check)
    '%f '...   %       amount/pump (should be $0.02)
    '%f '...   %       pump count (total)
    '%f '...   %       pump count ( 1-10)
    '%f '...   % (15)  pump count (11-20)
    '%f '...   %       pump count (21-30)
    '%f '...   %       mean pump count (total)
    '%f '...   %       mean pump count ( 1-10)
    '%f '...   %       mean pump count (11-20)
    '%f '...   % (20)  mean pump count (21-30)
    '%f '...   %       adjusted n count (total)
    '%f '...   %       adj. n count ( 1-10)
    '%f '...   %       adj. n count (11-20)
    '%f '...   %       adj. n count (21-30)
    '%f '...   % (25)  adjusted pump count (total)
    '%f '...   %       adj. pump count ( 1-10)
    '%f '...   %       adj. pump count (11-20)
    '%f '...   %       adj. pump count (21-30)
    '%f '...   %       adjusted pump count average (total)
    '%f '...   % (30)  adj. pump count avg. ( 1-10)
    '%f '...   %       adj. pump count avg. (11-20)
    '%f '...   %       adj. pump count avg. (21-30)
    '%f '...   %       money earned (total)
    '%f '...   %       money earned ( 1-10)
    '%f '...   % (35)  money earned (11-20)
    '%f '...   %       money earned (21-30)
    '%f '...   %       explosions (total)
    '%f '...   %       explosions ( 1-10)
    '%f '...   %       explosions (11-20)
    '%f '...   % (40)  explosions (21-30)
];
    
return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function pruned_output = pruneRawData(data_to_prune)

% load existing database (if there is one)
if(exist('data/bart_data.mat','file') == 2) 
    load('data/bart_data.mat');
    existing_ids = bart_struct.id;
else
    existing_ids = [];
end

% list IDs that are only in incoming and not in exsiting data
new_ids   = data_to_prune{1};
[~,new_i] = setxor(new_ids,existing_ids);

% remove indices referencing NaN's
q = new_i(~isnan(new_ids(new_i)));

% then just output
pruned_output = cell(size(data_to_prune)); % pre-allocate
for cell_n = 1:numel(data_to_prune)
    pruned_output{cell_n} = data_to_prune{cell_n}(q,:);
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function import_data = matchAndFilterIDs(raw_data_ids)

fprintf('Checking IDs against database entries...\n');

% load existing database (if there is one)
if(exist('bart_data.mat','file') == 2) 
    load('bart_data.mat');
    existing_ids = bart_struct.id';
else
    existing_ids = [];
end

% preallocate memory for output structure
import_data.orig_ID   = zeros(length(raw_data_ids),1);
import_data.actual_ID = zeros(length(raw_data_ids),1);

% loop through each new ID
for entry_n = 1:length(raw_data_ids)
    
    % attempt to match filename IDs to actual IDs
    m = MatchID(raw_data_ids(entry_n),'quiet');
    
    % check if match is already in the database of processed files 
    if(any(eq(existing_ids,m)) || any(eq(import_data.actual_ID,m)) )
        % throw up a message about that choice, being ignored
        fprintf('This ID (%6d) has already been processed.\n',m);
        fprintf('For simplicity, it will be SKIPPED.\n');
        m = NaN; % not a valid ID entry and will be ignored
    end
    
    % store results in structure for output
    import_data.orig_ID(entry_n)   = raw_data_ids(entry_n);
    import_data.actual_ID(entry_n) = m;

end

% output index of valid (non-NaN) entries
import_data.q = ~isnan(import_data.actual_ID);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function x_struct = organizeDataStruct(raw_input,valid_ids)

% filter out non-valid entries
for n_cell = 1:numel(raw_input)
    raw_input{n_cell} = raw_input{n_cell}(valid_ids.q,:);
end

% meta-/config. data
ids             = valid_ids.actual_ID(valid_ids.q);
specs.date      = cellfun(@(x,y) datenum([x ' ' y]),raw_input{2}(:,1),raw_input{2}(:,2));
specs.duration  = raw_input{3}(:,1);
specs.n_balloon = raw_input{3}(:,2); % simple sanity check
specs.pump_cost = raw_input{3}(:,3); % should be $0.02 (has been known to change)

% behavioral data
x_trials.pump_count          = raw_input{3}(:,4);
x_trials.mean_pump_count     = raw_input{3}(:,8);
x_trials.adj_n_count         = raw_input{3}(:,12);
x_trials.adj_pump_count      = raw_input{3}(:,16);
x_trials.adj_mean_pump_count = raw_input{3}(:,20);
x_trials.money_earned        = raw_input{3}(:,24);
x_trials.explosions          = raw_input{3}(:,28);

% block 1 (trials 1-10)
bart_block{1}.pump_count          = raw_input{3}(:,5);
bart_block{1}.mean_pump_count     = raw_input{3}(:,9);
bart_block{1}.adj_n_count         = raw_input{3}(:,13);
bart_block{1}.adj_pump_count      = raw_input{3}(:,17);
bart_block{1}.adj_mean_pump_count = raw_input{3}(:,21);
bart_block{1}.money_earned        = raw_input{3}(:,25);
bart_block{1}.explosions          = raw_input{3}(:,29);

% block 2 (trials 11-20)
bart_block{2}.pump_count          = raw_input{3}(:,6);
bart_block{2}.mean_pump_count     = raw_input{3}(:,10);
bart_block{2}.adj_n_count         = raw_input{3}(:,14);
bart_block{2}.adj_pump_count      = raw_input{3}(:,18);
bart_block{2}.adj_mean_pump_count = raw_input{3}(:,22);
bart_block{2}.money_earned        = raw_input{3}(:,26);
bart_block{2}.explosions          = raw_input{3}(:,30);

% block 3 (trials 21-30)
bart_block{3}.pump_count          = raw_input{3}(:,7);
bart_block{3}.mean_pump_count     = raw_input{3}(:,11);
bart_block{3}.adj_n_count         = raw_input{3}(:,15);
bart_block{3}.adj_pump_count      = raw_input{3}(:,19);
bart_block{3}.adj_mean_pump_count = raw_input{3}(:,23);
bart_block{3}.money_earned        = raw_input{3}(:,27);
bart_block{3}.explosions          = raw_input{3}(:,31);

% return organized data structure
x_struct.id                 = ids;
x_struct.specs              = specs;
x_struct.across_all_trials  = x_trials;
x_struct.across_blocks      = bart_block;

return

