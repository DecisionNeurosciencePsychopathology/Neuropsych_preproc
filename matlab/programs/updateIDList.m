function updateIDList( varargin, spss_flag )
%This funciton assumes you have access to both the W: and R: (I think)
%drives. Since this function is specific for only two files maybe it would
%be ok to hard code?

%5/13/15 So now this code will run a macro and save the query spalshdemo2
%from my remote copy in the Y:drive. It also saves a copy to the L drive as
%a backup, and creates a local backup (thikning about that now it seems
%like it's overkill?). this code will also create and save that query in a
%.mat file which will be used for the subsequent Neuropsych processing
%functions (CreateSubjList, LoadAllIds, ect). This function will now also
%update the spss demogfile as well in one go

%Example of how to run
%UpdateIDList <- this will check to see if the list needs updated and react
%accordingly

%UpdateIDList([],1)<- this will check to see if the list needs updated and react
%accordingly, then update the spss .dat file

%UpdateIDList('force',1) <- force updates list, updates spss demog .dat file

%%%%%%%%-------BEGIN CODE-------------%%%%%%%%%%%%%%

%Update spss demog file
if nargin < 1
    varargin = ' ';
    spss_flag=0;
elseif nargin < 2
    spss_flag=0;
end



%Added this so we could overwrite if needed
if(strcmpi('force',varargin))
    run_flag = true;
else
    run_flag = false;
end


data_dir = [pathroot 'tmp\'];

orig=pwd;
%fpath = [pathroot 'db/master id list.xlsx'];
%fpath = 'L:/Summary Notes/Data/matlab/db/master id list.xlsx';
fpath = 'c:\kod\Neuropsych_preproc\matlab\db\ALL_SUBJECTS_DEMO.xlsx';

if ~exist(fpath,'file')
    error('No master list found, see help'); % Just in case
end

%4/18/2017 Look at access_snippet in N_pre/matlab/programs
%Might be easier to use that and then just import or copy the xlsx into a
%table?

%hardcopy = 'Y:\Front End (For Copying)\Protect DB Front End.accdb';
hardcopy = 'Y:\Protect 2.0.accdb'; %File name
%Check original file's date
org_file=dir(strcat(fpath));
org_file=org_file.date;

%Check databases file date
db_file = dir(strcat(hardcopy));
db_file=db_file.date; 

%Compare dates buffer added to negate redundancy
if datenum(org_file)+.03<=datenum(db_file) || run_flag
    disp('Database is out of date! Don''t worry we can put a bird on it....'); %Databases are over!
    
    %Connect to database and export mast list
    h= actxserver('Access.Application');
    invoke(h,'OpenCurrentDatabase',hardcopy); %Protect DB
    %invoke(h.DoCmd,'RunMacro','exportDemog_noRunMacro'); %Macro is currently only executable on my (Jon's) computer
    invoke(h.DoCmd,'RunMacro','exportDemog'); %Macro is currently only executable on my (Jon's) computer
    h.Visible = 0;
    
    %Garbage collection
    h.Quit;
    delete(h);
    %Copy it to the L drive
    %cd('L:/Summary Notes/Data/matlab/db/')
    copyfile(fpath,'L:/Summary Notes/Old L-drive/Data/matlab/db/ALL_SUBJECTS_DEMO.xlsx');
%     movefile('master id list.xlsx','master id list_old_bckup.xlsx'); %Create backup
%     movefile('master_id_list.xlsx','master id list.xlsx');
    disp('All DONE, press any key to continue!');
    %pause();
else
    disp('Database is up to date!');
end

%This portion of the code will replace the demog_data file in the tmp
%directory used for the older Jan code

%Load data into matlab
filename = [pathroot 'db/ALL_SUBJECTS_DEMO.xlsx'];
[~,~,data] = xlsread(filename);

%Strip header information
header_info = data(1,:);
data(1,:)=[];

%Map out needed info from cols index, rmv white space for setfield
index=[];
for i = 1:length(header_info)
    %index = setfield(index, regexprep(header_info{i},'[^\w'']',''),...
    %find(strcmpi(header_info,header_info(i))));
    index = setfield(index, regexprep(header_info{i},'[^\w'']',''),i);
end


%Grab all ids numbers
id_nums=[data{:,index.ID}]';
tmp = zeros(length(id_nums),1);


%Determine what study(ies) each subject participated in
studies = {'SUICIDE' 'SUICID2' 'PROTECT' 'PROTECT2' 'AFSP'  'LEARN' ...
    'EXPLORE' 'B_SOCIAL'};

for i = 1:length(studies)
    study_index = index.(studies{i});
    enrolled_in_study=~cellfun(@sum,cellfun(@isnan, data(:,study_index),'UniformOutput',false)); %Make logical vector
    index_update = length(fieldnames(index)) +1;
    index.([studies{i} '_BIN']) = index_update; %Add binary header for final data struct
    data(:,index_update) = num2cell(enrolled_in_study);

end
    


%Find where there are duplicates
for i = 2:length(id_nums)
    if id_nums(i)==id_nums(i-1)
        tmp(i,1)=1;
    end
end
idx=find(tmp);
count = 0;

%Only run if duplicates are found
if ~isempty(idx)
    
    %Find the duplicates -- if any though there should not be!
    [C,ia,ic] = unique(sort(id_nums));
    diff_ia = diff(ia);
    dup_idx = find(diff(ia)>1);
    reoccurance=diff_ia(find(diff(ia)>1));
    
    if ~isempty(dup_idx) && ~isempty(data(dup_idx,1)) %This is a massive pain as working with cells is no bueno, but if need be you can figure it out
        error('There is a duplicate! You need to fix this or talk to Josh again!')
        return
        for i = 1:length(dup_idx)
            tmp = cell(1,length(data(dup_idx(i),:)));
            for j = 1:reoccurance(i)
                ct = j-1;
                cell_idx = cellfun(@isnan, data(dup_idx(i)+ct,:), 'UniformOutput', false);
                B = ~any(cellfun(@isnan,A(:,4:end)),2);
                tmp(cell_idx) = data(dup_idx(i)+ct,cell_idx);
            end
        end
    end
end
%Clean up "other paitent" data, rmv 'NaN' entries
other_idx=strcmpi(data(:,index.PATTYPE),'OTHER PATIENT');
data(other_idx,:)={'NaN'};
qnan = cellfun(@any,cellfun(@isnan,data,'UniformOutput',0));
qnan = ( qnan |  strcmp('NaN',data) ); % get rid of 'NaN' entries
data(qnan) = {''}; % replace NaN's with zeros
emptyCells = cellfun('isempty', data);

%5/13/2016 talk to Josh, this was removing everyone that had an empty cell,
%people had empty cells becasue they had Nan's in various columns, (dates,
%ect)
%data(all(emptyCells,2),:) = [];
data(emptyCells(:,1),:) = [];

%Convert data into table format
final_headers = fieldnames(index)';
data=cell2table(data,'VariableNames',final_headers);

%Final clean up of data, some numbers are still strings, remove any nans
%that appear
data=convert_string_to_double(data,{'MAXLETHALITY'});
data=convert_string_to_double(data,{'GROUP12467'});

% Archive and save it
cd(data_dir)
if exist('demogs_data.mat','file')
    copyfile('demogs_data.mat', 'demogs_data_archive.mat');
end
save([data_dir 'demogs_data'],'data');


if spss_flag ==1
    % open file pointer for writing DAT file
    cd(pathroot)
    cd('../SPSS/data')
    fid = fopen('demogspss.dat' ,'w');
    
    
    %Take care of headers
    for hn = 1:length(header_info)
        fprintf(fid,'%s\t',header_info{hn});
    end
    fprintf(fid, '\n');
    
    str_fmt=[]; %automate str formatting
    for i = 1:size(data,2)
        if ischar(data{1,i})
            tempstr = '%s';
        else
            tempstr = '%d';
        end
        str_fmt = strcat(str_fmt,tempstr,'\t');
    end
    str_fmt(end)='n';
    
    for i=1:size(data,1)
        fprintf(fid,str_fmt,data{i,:});
    end
    
    % Save it
    save([data_dir 'demogs_data'],'data');
end

%Just added this is so it's one less function to run really
createSubjIDlist;

% varargout
if(nargout), demogs = data; end

%kill pointer
fclose all;

%Return to origin
cd(orig);
end

function T=convert_string_to_double(T,my_field)
T.(my_field{:}) = str2double(T.(my_field{:}));
T.(my_field{:})(isnan(T.(my_field{:}))) = 0;
end