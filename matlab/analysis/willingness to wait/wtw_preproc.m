


function data_out = wtw_preproc

% look through file directory and database for new files
id_list_struct = findNewDataFiles('qtask_upmc*.mat','wtw_data.mat');

% make sure IDs are real and not mistyped
data_to_import = matchAndFilterIDs(id_list_struct);

% get filenames from IDs
% - - - - - 
% This should be simpler than the other routines since
% all the raw data is stored in an organized manner
% - - - - -
wtw_struct = getRawFiles(data_to_import,id_list_struct.data);

% load files, process data
wtw_struct = loadAndProc(wtw_struct);
save([pathroot 'analysis/willingness to wait/data/wtw_data.mat'],'wtw_struct');

% optional data output
if(nargout), data_out = wtw_struct; end

return



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function list_out = findNewDataFiles(raw_data_str,data_file)

% get ids from existing filenames
data_file_path = ['data/raw/' raw_data_str];
[data_dir_listing, dir_ids] = getDirData(data_file_path);

% load existing database (if there is one)
if(exist(['data/' data_file],'file') == 2) 
    load(['data/' data_file]);
    existing_ids = wtw_struct.id;
else
    existing_ids = [];
end

% find only the new files (and their indices)
[~,i_dir] = setxor(dir_ids,existing_ids);

% we only want IDs unique to data dir (this protects against
% the contingency --regardless of its liklihood-- where there 
% are IDs in the database which not in the directory)
just_the_new_ids = dir_ids(i_dir);

% organize into single struct
list_out.data         = data_dir_listing;
list_out.new_ids      = just_the_new_ids;
list_out.existing_ids = existing_ids;

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function [dir_data, ids] = getDirData(dir_path)
    
% get directory info (easy)
dir_data = dir(dir_path);

% get IDs from directory info
ids = cellfun(@(s) sscanf(s,'qtask_upmc_%d_1.mat'),{dir_data.name})';
    
return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function import_data = matchAndFilterIDs(id_struct)

fprintf('Checking IDs against database entries...\n');

% preallocate memory for output structure
import_data.orig_ID   = nan(length(id_struct.new_ids),1);
import_data.actual_ID = nan(length(id_struct.new_ids),1);

% loop through each new ID
for entry_n = 1:length(id_struct.new_ids)
    
    % attempt to match filename IDs to actual IDs
    m = MatchID(id_struct.new_ids(entry_n),'quiet');
    
    % check if match is already in the database of processed files
    if(any(eq(id_struct.existing_ids,m)))
        % throw up a message about that choice, being ignored
        fprintf('This ID has already been processed.\n');
        fprintf('For simplicity, it will be SKIPPED.\n');
        m = NaN; % NaN will be ignored
    end
    
    % store results in structure for output
    import_data.orig_ID(entry_n)   = id_struct.new_ids(entry_n);
    import_data.actual_ID(entry_n) = m;

end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function data_struct = getRawFiles(import_data,dir_data)

% pre-allocate memory
data_struct = struct('id',cell(sum(~isnan(import_data.actual_ID)),1), ...
    'specs',struct('filename',{''},'orig_ID',{''}));

% for each new ID, pass through the list of directory entries
% to find a match (use orig. ID entries for directory matches, 
% but save the actual ID in the final data structure
for n_ID = 1:length(import_data.actual_ID) % for each new ID
    if(~isnan(import_data.actual_ID(n_ID))) % skip NaN-entries
        
        % find index of filename matching original ID
        id_number       = import_data.orig_ID(n_ID);
        fxhdl_compIDstr = @(s) eq(sscanf(s,'qtask_upmc_%d_1.mat'),id_number);
        filename_match  = find(cellfun(fxhdl_compIDstr,{dir_data.name}));
        
        if(any(filename_match))
            
            % store results in data structure
            data_struct(n_ID).id             = import_data.actual_ID(n_ID);
            data_struct(n_ID).specs.filename = dir_data(filename_match).name;

            % only store original ID if it is different than the matched ID
            if(ne(id_number,data_struct(n_ID).id))
                data_struct(n_ID).specs.orig_ID = id_number;
            end
            
        end
    end
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function data_struct = loadAndProc(data_struct)

file_stem = [pathroot 'analysis/willingness to wait/data/raw/'];

for file_n = 1:length(data_struct)
    
    %Hopefully this will fix any more issues with load, skip over any empty
    %ids in struct
    if isempty(data_struct(file_n).id)
        continue
    end
    
    % read in file data
    file_path = [file_stem data_struct(file_n).specs.filename];
    
    % 'load' does stupid things when loading structures
    %This was tmp = data_struct and would fail so I changed it to struct and it ran
    %If this fails first delete the old wtw_data.mat file in the data dir.
    tmp = struct; 
    tmp.header = load(file_path,'dataHeader');
    tmp.data   = load(file_path,'trialData');
    
    % add data to main data structure
    data_struct(file_n).specs.dataHeader = tmp.header.dataHeader; 
    data_struct(file_n).trialData = tmp.data.trialData;
    
end

return

