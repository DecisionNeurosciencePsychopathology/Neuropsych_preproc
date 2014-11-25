function updateIDList( varargin )
%This funciton assumes you have access to both the W: and R: (I think)
%drives. Since this function is specific for only two files maybe it would
%be ok to hard code?

%Added this so we could overwrite if needed
if(strcmpi('force',varargin))
    run_flag = true;
else
    run_flag = false;
end

orig=pwd;
%fpath = [pathroot 'db/master id list.xlsx'];
fpath = 'L:/Summary Notes/Data/matlab/db/master id list.xlsx';

if ~exist(fpath,'file')
    error('No master list found, see help'); % Just in case
end

hardcopy = 'W:/SUICIDE2 Salem''s Copy.mdb';
%Check original file's date
org_file=dir(strcat(fpath));
org_file=org_file.date;

%Check databases file date
db_file = dir(strcat(hardcopy));
db_file=db_file.date; 

%Compare dates buffer added to negate redundancy
if datenum(org_file)+.03<=datenum(db_file) || run_flag
    disp('Database is out of date! Don''t worry we can put a bird on it....');
    
    %Connect to database and export mast list
    h= actxserver('Access.Application');
    invoke(h,'OpenCurrentDatabase','W:\SUICIDE2 Salem''s Copy.mdb');
    invoke(h.DoCmd,'RunMacro','exportMSList'); %REMBER to change macro file dest.
    h.Visible = 0;
    
    %Rename it
    cd('L:/Summary Notes/Data/matlab/db/')
    movefile('master id list.xlsx','master id list_old_bckup.xlsx'); %Create backup
    movefile('master_id_list.xlsx','master id list.xlsx');
    disp('All DONE, press any key to continue!');
    pause();
else
    disp('Database is up to date!');
end
cd(orig);
end

