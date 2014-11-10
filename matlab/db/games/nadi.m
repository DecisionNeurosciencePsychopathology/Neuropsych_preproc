function nadi( varargin )
% find data files in their backup dir and create a folder of the
% subject's ID to put them in. 
%
% Jan Kalkus
% 04 Oct 2012
% 
% Jan Kalkus
% 2013-12-03: updated to incorporate 'MatchID' function
%
% Jon Wilson
% 2014-08-22: updated to incorporate more Neuorpsych games
% Notes: To not kick out make a function starting at vara that if the dir
% is empty it will call the function again only idx will be increased by 1
% therefore one the next loop the program will skip the assessment with no
% data. MAKE MAIN LOOP WITH YES NO ANSWER

%Main loop
while(1)

% find most recent dir
default_bkup_dir = checkForBackupDir;
s = mostRecentDir(default_bkup_dir);

% compute number of files in new data dir
files = dir(s);
files=struct2cell(files)';

% Grep file names
f_names = ~cellfun(@isempty,regexp(files(:,1),'[a-z]'));
f_names = files(f_names);

for idx = 1:length(f_names)
    
    vara = {f_names(idx)};

    % Loop takes in multiple files now 
    name_of_the_game = checkInputArgs(vara{1});
    name_of_the_game = name_of_the_game{:}; %go from cell to char
    fprintf('looking for new ''%s'' data...\n',name_of_the_game);

    d = [pathroot 'analysis/' name_of_the_game '/data/raw'];

    % get info/names of text data files
    if strcmpi('willingness to wait',name_of_the_game)
        file_list = dir([s name_of_the_game '\*.mat']); % for Matlab files

    elseif strcmpi('cantab',name_of_the_game)
        file_list = dir([s name_of_the_game '\*.csv']); % for csv files

    elseif strcmpi('reversal',name_of_the_game)
        file_list = dir([s name_of_the_game '\*.rev']); % for rev files

    else
        file_list = dir([s name_of_the_game '\*.txt']); % for E-Prime files
    end

    % Kick out if there are no files in dir
    if(isempty(file_list)) 
        fprintf('no ''%s'' files found\n',name_of_the_game);
        return; 
    end

    %Display message to let know user what's going on
    fprintf('\nNow finding and matching ''%s'' files...\n',name_of_the_game);
    pause(2);

    % attempt to match ID fragments in filenames
    if ~strcmp('cantab',name_of_the_game) 
        id_match = match_file_to_id(file_list);
    
        % make directories and move files into them (on backup drive)
        src_dir  = [s name_of_the_game '/']; 
        dest_dir = [d '/'];

        % why have I removed this from the processing stream?
        organize_data_file(src_dir,dest_dir,file_list,id_match);
    
    else
        cantab_excep(s,d,file_list.name);
    end
end %End Loop

%Ask user to continue or not
choice = menu('Continue','Yes','No');
if choice == 2 || choice == 0
    break;
end

end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function fixed_input_args = checkInputArgs(input_args)

% name of the game/assessment
processable_game_list = { ...
    'bandit', ...
    'ultimatum', ...
    'bart' ...
    'willingness to wait'...
    'cantab'...
    'reversal'...
    'iowa'...
};

%    'willingness to wait' ...
%};

% replace 'wtw' with longer name
if(strcmpi('wtw',input_args))
    input_args = {'willingness to wait'};
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
dir_path = 'E:\backup\'; % 2014-06-13

if exist(dir_path,'dir')
    dir_path = makeChoice();
end

if(~isdir(dir_path))
    dir_path = uigetdir('','Choose NP backup/transfer directory source');
    dir_path = [dir_path '\'];
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function m = match_file_to_id(dir_input)

%Grab the file extension to add to the regexp cmd
ext = char({dir_input(1).name});
ext = ext(end-2:end);
reg = ['(?<x>[0-9]{4,7}).{1,5}',ext];

% function handle for extracting ID with regular expression
fh_extracted_id = @(s) struct2cell(regexp(s,reg,'names'));

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
        warning('nadi:copyfile','\t Something wrong here:\n\t%s\n',messg);
    end
    
end

return

function cantab_excep(scr,dest,file)
fprintf('creating directories and moving files...\n');
    dest = [dest '/'];
    scr = [scr 'cantab/' file];
    copyfile(scr,dest);
return

function dir=makeChoice()
% display message to user
% This is bugged you have to get it right the first time, fix later
prompt='Please indicate if you would like to process N.Pysch 2 or 3 data'; 
prompt=[prompt '\n(please enter the number 2 or 3): '];
res = input(prompt);

if res == 2        
    dir = 'E:\backup\neuropsych data\';
elseif res == 3
    dir = 'E:\backup\our tablet data\';
else
    fprintf('Error: Invalid input\n\n');
    makeChoice();
end
return



