function nula( varargin )
% find data files in their backup dir and create a folder of the
% subject's ID to put them in. 
%
% Jan Kalkus
% 04 Oct 2012
% 
% Jan Kalkus
% 2013-12-03: updated to incorporate 'MatchID' function


% only takes one input argument at the moment
name_of_the_game = checkInputArgs(varargin);
name_of_the_game = name_of_the_game{:};
fprintf('looking for new ''%s'' data...\n',name_of_the_game);

% find most recent dir
default_bkup_dir = checkForBackupDir;
s = mostRecentDir(default_bkup_dir);
d = [pathroot 'analysis/' name_of_the_game '/data/raw'];

% get info/names of text data files
%I suggest rethinking this sometimes it automaticcaly picks bandit or
%ultimatum other times it just grabs the most recent directory
%Perhaps this would be a good exersice to use unix commands to find bandit
%or ultimatum or wtw in the most recent directory in the processed folder
%and then move all the data files?

%file_list = dir([s name_of_the_game '/*.txt']); % for E-Prime files
file_list = dir([s '/*.txt']); % for E-Prime files
if(isempty(file_list)) 
    fprintf('no ''%s'' files found\n',name_of_the_game);
    return; 
end

% attempt to match ID fragments in filenames
id_match = match_file_to_id(file_list);

% make directories and move files into them (on backup drive)
%src_dir  = [s name_of_the_game '/']; 
src_dir  = [s '/'];
dest_dir = [d '/'];

% why have I removed this from the processing stream?
organize_data_file(src_dir,dest_dir,file_list,id_match);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function fixed_input_args = checkInputArgs(input_args)

% name of the game/assessment
processable_game_list = { ...
    'bandit', ...
    'ultimatum', ...
    'bart' ...
};

%    'willingness to wait' ...
%};

% replace 'wtw' with longer name
if(strcmpi('wtw',input_args))
    q = strcmpi('wtw',input_args);
    input_args{q} = 'willingness to wait';
end

% validate input args
fh_any_match = @(s) any(strcmpi(s,processable_game_list));
q_appropriate_input = cellfun(fh_any_match,input_args)';

% in case of any unrecognizable input arguments
if(any(~q_appropriate_input))
    warning_str = [sprintf('I don''t know:\n') sprintf('\t%s\n',input_args{:})];
    warning('MATLAB:nula:UnknownAssessment',warning_str);
end

% adjust and return original input args
fixed_input_args = lower(input_args(q_appropriate_input));

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function dir_path = checkForBackupDir()

% this should work if the USB drive is plugged in
dir_path = 'E:\backup\our tablet data\'; % 2014-06-13

if(~isdir(dir_path))
    dir_path = uigetdir('','Choose NP backup/transfer directory source');
    dir_path = [dir_path '\'];
end
    
return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function m = match_file_to_id(dir_input)

% function handle for extracting ID with regular expression
fh_extracted_id = @(s) struct2cell(regexp(s,'(?<x>[0-9]{4,6}).{1,3}txt','names'));

% extract ID (or ID fragment) from filename string
id_fragment = cellfun(fh_extracted_id,{dir_input.name});

% match fragment(s) to existing database
m  = cellfun(@MatchID,id_fragment);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function organize_data_file(src_dir,dest_dir,file_data,matched_ids)

fprintf('creating directories and moving files...\n');

for filei = 1:numel(file_data)
    
    if(~isnan(matched_ids(filei))) % filter out skipped files/ID's if any

        % make directory path with ID name
        dest_file_path = sprintf('%s%d/',dest_dir,matched_ids(filei));
        
    else % if no match, put it in a different folder
        
        % make directory path for storing umatched files
        dest_file_path = sprintf('%sunmatched/',dest_dir);
        
    end
    
    % create directory, unless it already exists
    if(ne(exist(dest_file_path,'dir'),7))
        mkdir(dest_file_path);
    end
    
    % move files to that directory
    file_name     = [file_data(filei).name];
    txt_file_path = [src_dir file_name];
    src_file_path = [txt_file_path(1:end-3) '*']; % use wildcard to copy both files

    [status,messg] = copyfile(src_file_path,dest_file_path); % preserves timestamps, good
    
    % if something went wrong, let user know
    if(~status)
        warning('nula:copyfile','\t Something wrong here:\n\t%s\n',messg);
    end
    
end

return

