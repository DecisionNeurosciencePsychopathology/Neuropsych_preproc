function ug_context_qc
%Check to determine if any subjects' baseline is missing from context data
%list, double check on dates to ensure proper data is linked

main_dir = 'C:/kod/Neuropsych_preproc/matlab/analysis/ug_context/data';

glob_str = '/*[0-9]*';
array_fun_str = '/';
[T_context,context_list]=build_id_table(main_dir,glob_str,array_fun_str);

baseline_dir = [main_dir '/baseline'];
%glob_str = '/*[0-9]*';
%array_fun_str = '/baseline/';
[T_baseline,baseline_list]=build_id_table(baseline_dir,glob_str,array_fun_str);

%Determine whos missing from context list
found_idx = ismember(context_list,baseline_list);
found_ids = context_list(found_idx);
missing_ids = context_list(~found_idx);

%Could make this a seperate function run both found and missing ids right?
%double check the possible matches logic though for found?
for i = 1:length(missing_ids)
    %Get the date of context admin
    %file = dir([main_dir '/' num2str(missing_ids(i)) '/*.txt']);
    missing_id = missing_ids(i);
    
    %Get idx of missing id
    idx=T_context.ID==missing_id;
    
    %Get time difference
    t_diff=T_context.date_num(idx)-T_baseline.date_num;
    
    %Set time barrier
    thirty_min=0.020833333; %date vecotr for 30mins
    
    %Determine possible matches (if any) for missing ids in context ver
    possible_matches=find(and(0<t_diff,t_diff<thirty_min));
    
    %Output suggestions to user TODO run this on all found ids as well to
    %search of abnormalities
    if ~isempty(possible_matches)
        for j = 1:length(possible_matches)
            fprintf('%d is missing...possible match %d: %d \n',missing_ids(i),j,T_baseline.ID(possible_matches(j)));
        end
    else
        fprintf('%d is missing...no matches\n',missing_ids(i));
    end    
end

check_time_stamp(found_ids,T_baseline,T_context)

%Clean up
fclose all;


function [T,id_list]=build_id_table(main_dir,glob_str,array_fun_str)

%Get context list
id_list = regexp(glob([main_dir glob_str]),'[0-9]{3,6}+', 'match');
id_list = unique(flatten_cell_to_array(id_list));

%If any files are not in folders produce a table with ID and Session
%date/time
T=table();

%Set id lists
T.ID = id_list;

%Are txt files in a dir already?
T.is_dir=arrayfun(@(x) isdir([main_dir array_fun_str num2str(x)]),id_list);

%Grab the file names for dirs
tmp=arrayfun(@(x) dir([main_dir array_fun_str num2str(x) '/*.txt']),id_list(T.is_dir));
T.fname=cell(height(T),1);
T.fname(T.is_dir)={tmp.name}';

%Grab the file names not in dirs

tmp=arrayfun(@(x) dir([main_dir array_fun_str '*' num2str(x) '*.txt']),id_list(~T.is_dir));
if ~isempty(tmp)
    T.fname(~T.is_dir)={tmp.name}';
end

%Initialize dates
T.date_str=cell(height(T),1);
T.date_num=zeros(height(T),1);

for i = 1:height(T)
    if T.is_dir(i)
        f{i,1} = fullfile(main_dir,num2str(T.ID(i)),T.fname(i));
    else
        f{i,1} = fullfile(main_dir,T.fname(i));
    end
    
    %File I/O
    fid = fopen(f{i}{:});
    
    % check for file format
    if(checkFileBOM(f{i}{:})) % file format is UTF-16 IEEE-LE
        fprintf('\n\tfile: ''%s''\n\tis in UTF16-LE format\n',f{i}{:});
        fprintf('\t\tconverting to ASCII...');
        utf2ascii(f{i}{:},'fast'); % convert it (fast = no need to verify BOM)
        fprintf('\t done\n');
    end
    
    %Read in file
    file_data = textscan(fid,'%s','Delimiter','\n','whitespace','');
    file_data = file_data{:};
    fclose(fid);
    
    %Get the session data
    sessionidx = ~cellfun(@isempty,regexp({file_data{1:25}},'SessionStartDateTime'))';
    session_start_date = regexp(file_data{sessionidx},'\d+.*','match');
    
    %If for some reason Session date is not recorded
    if isempty(session_start_date)
        session_date = regexp(file_data{~cellfun(@isempty,regexp(file_data(1:25),'SessionDate'))'},'\d+.*','match');
        session_time = regexp(file_data{~cellfun(@isempty,regexp(file_data(1:25),'SessionTime'))'},'\d+.*','match');
        session_start_date=cat(1,session_date,session_time)';
        session_start_date={strjoin(session_start_date)};
    end
    
    %Save date in table
    T.date_str(i) = session_start_date;
    T.date_num(i) = datenum(session_start_date);
end

T.full_fname=f;
stop=1;


function out=flatten_cell_to_array(my_cell)

my_cell=[my_cell{:}];
my_cell = sprintf('%s ', my_cell{:});
out = sscanf(my_cell, '%d');

%check on the session date time stamp to ensure files match
function check_time_stamp(id_list,T_baseline,T_context,missing_flag)

try missing_flag; catch, missing_flag=0; end;

for i = 1:length(id_list)
    %Get the date of context admin
    %file = dir([main_dir '/' num2str(missing_ids(i)) '/*.txt']);
    ids = id_list(i);
    
    %Get idx of missing id
    idx=T_context.ID==ids;
    
    %Get time difference
    t_diff=T_context.date_num(idx)-T_baseline.date_num;
    
    %Set time barrier
    thirty_min=0.020833333; %date vecotr for 30mins
    
    %Determine possible matches (if any) for missing ids in context ver
    possible_matches=find(and(0<t_diff,t_diff<thirty_min));
    
    %Output suggestions to user TODO run this on all found ids as well to
    %search of abnormalities
    if ~isempty(possible_matches)
        for j = 1:length(possible_matches)
            if missing_flag
                fprintf('%d is missing...possible match %d: %d \n',id_list(i),j,T_baseline.ID(possible_matches(j)));
            else
                fprintf('%d can be matched with %d: %d \n',id_list(i),j,T_baseline.ID(possible_matches(j)));
            end
        end
    else
        fprintf('%d is missing...no matches\n',id_list(i));
    end    
end