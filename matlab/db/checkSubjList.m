function checkSubjList
%Mac function to load in SubjIDListBD.mat 
run_flag=0; %this is to force overwirte the subjIDlist
orig=pwd;
if ~ispc
    
    l_drive = '/Volumes/llmd/Summary Notes/Data/matlab/'; %change for mac
    hardcopy = [l_drive 'db/subjIDlistDB.mat'];
    localcopy = [pathroot 'db/subjIDlistDB.mat'];
    
    if ~exist(localcopy,'file')
        error('No master list found, see help'); % Just in case
    end
    
    %Check original file's date
    org_file=dir(localcopy);
    org_file=org_file.date;
    
    %Check databases file date
    db_file = dir(hardcopy);
    db_file = db_file.date;
    
    %Compare dates buffer added to negate redundancy
    if datenum(org_file)+.03<=datenum(db_file) || run_flag
        disp('Database is out of date! Don''t worry we can put a bird on it....');
        
        %Rename it
        cd('L:/Summary Notes/Data/matlab/db/') %Will have to change for mac
        copyfile('subjIDlistDB.mat','subjIDlistDB_tmp.mat'); %Create tmp file
        movefile('subjIDlistDB.mat',localcopy);
        movefile('subjIDlistDB_tmp.mat','subjIDlistDB.mat');
        disp('All DONE, press any key to continue!');
        pause();
    else
        disp('Database is up to date!');
    end
    
else
    error('This is only for Mac use UpdateIDList and CreateSubjList for pc');
end
 cd(orig); %Return Home