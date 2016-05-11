function data_out = iowa_preproc
% < description >
%
% Jan Kalkus
% 2013-08-14: still need to fix to enable appending of data AND iron out 
%             any other weird bugs --you know which one(s)


% look through file directory and database for new files
id_list_struct = findNewIOWAFiles;

% make sure IDs are real and not mistyped
data_to_import = matchAndFilterIDs(id_list_struct);

% get filenames from IDs
iowa_struct = getRawFiles(data_to_import,id_list_struct.data);

% load files, process data
iowa_struct = loadAndProc(iowa_struct);
save([pathroot 'analysis/iowa/data/iowa_data.mat'],'iowa_struct');

% optional data output
if(nargout), data_out = iowa_struct; end

return



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function list_out = findNewIOWAFiles()

% get ids from existing filenames
data_file_path = [pathroot 'analysis/iowa/data/raw/igt-*.txt'];
[iowa_dir_listing, dir_ids] = getDirData(data_file_path);

% load existing database (if there is one)
if(exist('data/iowa_data.mat','file') == 2) 
    load('data/iowa_data.mat');
    existing_ids = iowa_struct.id;
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
list_out.data         = iowa_dir_listing;
list_out.new_ids      = just_the_new_ids;
list_out.existing_ids = existing_ids;

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function [dir_data, ids] = getDirData(dir_path)
    
% get directory info (easy)
dir_data = dir(dir_path);

% get IDs from directory info
ids = cellfun(@(s) sscanf(s,'igt-%d.txt'),{dir_data.name})';
    
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
data_struct.id = zeros(sum(~isnan(import_data.actual_ID)),1);
data_struct.specs.filename = cell(size(data_struct.id));
data_struct.specs.orig_ID  = nan(size(data_struct.id));

% for each new ID, pass through the list of directory entries
% to find a match (use orig. ID entries for directory matches, 
% but save the actual ID in the final data structure
for n_ID = 1:length(import_data.actual_ID) % for each new ID
    if(~isnan(import_data.actual_ID(n_ID))) % skip NaN-entries
        
        % find index of filename matching original ID
        id_number       = import_data.orig_ID(n_ID);
        fxhdl_compIDstr = @(s) eq(sscanf(s,'igt-%d.txt'),id_number);
        filename_match  = find(cellfun(fxhdl_compIDstr,{dir_data.name}));
        
        if(any(filename_match))
            
            % store results in data structure
            data_struct.id(n_ID)             = import_data.actual_ID(n_ID);
            data_struct.specs.filename(n_ID) = {dir_data(filename_match).name};

            % only store original ID if it is different than the matched ID
            if(ne(id_number,data_struct.id(n_ID)))
                data_struct.specs.orig_ID(n_ID) = id_number;
            end
            
        end
    end
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function data_struct = loadAndProc(data_struct)

file_stem = [pathroot 'analysis/iowa/data/raw/'];

for file_n = 1:length(data_struct.specs.filename)
    if(~isempty(data_struct.specs.filename{file_n}))
        % read in file data
        file_path = [file_stem data_struct.specs.filename{file_n}];
        org_struct = organizeRawData(file_path);
        
        % some minor processing
        if(length(org_struct.trial_n) == 100)
            for n = 1:5 % total wins by blocks (5x20)
                q = 1+(20*(n-1)):(20*n);
                data_struct.blk_win_total(file_n,n) = sum(org_struct.trial_win(q));
                
                choice_ratio = sum(org_struct.choice(q) > 2)/length(q);
                data_struct.blk_prop1n2to3n4(file_n,n) = choice_ratio;
            end
        else
            fprintf(' >>> Incomplete file for %6d: SKIPPING <<< \n',data_struct.id(file_n));
        end
    end
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function organized_data = organizeRawData(file_name_path)

% read in data (we don't need the first column)
raw_data = dlmread(file_name_path,' ',0,1);

% get the basics
organized_data.trial_n   = raw_data(:,1);
organized_data.choice    = raw_data(:,2);
organized_data.win_cost  = raw_data(:,3);
organized_data.lose_cost = raw_data(:,4);
organized_data.trial_win = raw_data(:,5);
organized_data.total_win = raw_data(:,6);
organized_data.t_onset   = raw_data(:,7);
organized_data.RT        = raw_data(:,8);

return

