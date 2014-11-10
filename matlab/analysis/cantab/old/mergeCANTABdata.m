function mergeCANTABdata( varargin )
% This is a somewhat revamped version of the previous function I
% was coding to do this. Unfortunately, I noticed some problems
% in the logic of the previous code which required a substantial
% rewrite. That is what we have here. An explanation of what
% problems are being addressed and how that is done will follow
% later. For the moment, getting the code down and working is the
% priority. 

% source appropriate directories for external functions
if(~exist('pathroot','file'))
	addpath(genpath('L:/Summary Notes/honza/kod/matlab/programs/'));
elseif(~exist('damlevdist','file'))
	addpath([pathroot 'programs/']);
end

% /* Parse input */
varargin = parseInputArgs(varargin);

% /* Locate file */
fpath = findDataFile(varargin);

% /* Check for existing CANTAB db */
existing_ids = checkForCumulativeFile;

% /* Load and organize incoming data into data struc. */
incoming_struc = entryPrep(fpath); 

% /* search through duplicate entries and resolve */
x = cascadeRankSort(incoming_struc,existing_ids);

% WHAT DARK MAGIC IS THIS?
% headerData = textscan(fileString,'%[^\n\r]',firstLineOffset,...
% 	'whitespace','','delimiter','\n','bufsize', bufsize);

% r = textscan(fid,'%[$^\n\r]','HeaderLines','delimiter','\t');

return


%--------------------------------------------------------------------------
function v = parseInputArgs( vr_in )
% The function name is fairly self explanatory. This sub-function
% parses the input variables. At the moment, either 1 or 0
% arguments are accepted. If there are 0 arguments, the output is
% set to a MD5 hash of something. (I probably won't remember what
% it was, which is for the best since it was likely not something
% appropriate for a workplace environment.) The hash is used
% because of the extremely low probability of a collision. You
% see, later functions check for an existing file and MATLAB will
% return a non-zero answer if the file exists OR it is a file
% within the MATLAB search path (kind of annoying that a
% distinction between the two is not made). 


if(isempty(vr_in))
    warning('MATLAB:import:argCount', ...
        'No arguments provided. Use ''help'' flag for more info.');
    v{1} = '4ffc630efb1c02c6e88d95a03a6c4070'; % low collision probability
elseif(numel(vr_in) > 1)
    error('CANTAB:import:argCount', ...
        'Too many arguments. Only basic arguments supported for now.');
else
	v = vr_in;
end

return


%--------------------------------------------------------------------------
function fp = findDataFile(v_in)
% Check to see if the arguments given match a data file anywhere.
% Files are searched first assuming the literal path was entered.
% If no file is found with that string, then files are checked
% for locally, assuming the input is just the name of the file.
% If no files are found locally, they are checked for in a folder
% on the L:/ drive. If no file has yet been found, a user is
% asked select the file manually, with a GUI dialogue. If the
% user cancels the dialogue, the function aborts and returns an
% error. 

altdir = 'L:/Summary Notes/Data/CANTAB data/CANTAB files 2008-11.2011/Excel files/';

if(exist(v_in{1},'file')) % check for full path
	fp = v_in{1}; % why was I using the below format?
elseif(exist(['./' v_in{1}],'file')) % check for local path
    fp = ['./' v_in{1}];
elseif(exist([altdir v_in{1}],'file')) % check L drive
    fp = [altdir v_in{1}];
else % otherwise, request user choose file w/ GUI
    [tmp_name,tmp_path] = uigetfile([altdir '*.csv'],'Choose file to add to CANTAB cumulative');
	fp = [tmp_path tmp_name];
    if(~tmp_name) % in case user aborts 'uigetfile'
        error('CANTAB:import:filePath','No files found for given input');
    end
end

return


%--------------------------------------------------------------------------
function fout = checkForCumulativeFile
% Check for presence of the cumulative CANTAB data file. This is
% a bit tricky. I haven't quite worked out all the details yet...

defpath = [pathroot 'db/cantab/proc/cantab cumulative.dat'];

if(exist(defpath,'file'))
	fprintf('Loading data...\n');

    raw = readDataFile(defpath); % load existing file
    fout = struct('id',{},'age',{},'date',{},'sex',{});
    
    for iie = 1:size(raw,1); % number of entries in incoming data
        fout(iie).id   = raw{1}; 
        fout(iie).age  = raw{2}; 
        fout(iie).date = datenum(raw{6}); 
        fout(iie).sex  = raw{4};
    end

	fout.specs.filepath = defpath;
	%fout.specs.raw      = raw; % might not need this

	fout.fields = [
		'    id:   subject ID number    ';
		'   age:   age of subject       ';
		'  date:   date NP testing began';
        '   sex:   sex of subject       ';
		];
else
	fout = 0;
	warning('CANTAB:fileCheck:existingCANTAB', ...
        'No cumulative CANTAB file found, starting from scratch\n');
end

return


%--------------------------------------------------------------------------
function in_struc = entryPrep(file_path)
% Create a structure for use in determining which ID's are
% miss-typed and which are accurate. More details later. 

% /* get data from file */
data = readDataFile(file_path);

% set variables and allocate memory
nent = numel(data{1}); % number of entries
master = fetchMasterEntryStruc; % fetch master DB structure
in_struc = struct('id',{},'age',{},'test_date',{},'sex',{}, ...
    'match_rank',{},'match_id',{},'index_ptr',{});

for iis = 1:nent
	
	% basic info.
    in_struc(iis).id        = data{1};
    in_struc(iis).age       = data{2};
    in_struc(iis).test_date = data{6};
    in_struc(iis).sex       = data{4};
    
	% I don't like for loops, but I don't know of another way to
	% store data in this data structure format
	for jjm = 1:length(master.id_number)

		% for clarity
		in_stuff = [in_struc(iis).id; in_struc(iis).test_date];
		ma_stuff = [master.id_number(jjm); master.consent_date(jjm)];

		% compute distance in an R^2 (sort of?) space
		dxy = matchDistMetric(in_stuff,ma_stuff);

		% store results
		in_struc(iis).match_rank(jjm) = dxy;
		in_struc(iis).match_id(jjm)   = master.id_number(jjm);
		in_struc(iis).index_ptr(jjm)  = 1;
		
	end

	% /* sort according to distance */
	[in_struc(iis).match_rank,qs] = sort(in_struc(iis).match_rank); % !! assignment might not work
	in_struc(iis).match_id = in_struc(iis).match_id(qs);
    in_struc.specs.sort_order = qs; % useful?

end

% /* add helpful field information */
in_struc.fields = [
	'           id:  subject''s (supposed) ID number                   ';
	'          age:  subject age                                      ';
	'    test_date:  neuropsych. beginning testing date               ';
	'          sex:  sex of subject (assuming this is infallible)     ';
	'   match_rank:  distance from MASTER DB entries (ascending order)';
	'     match_id:  MASTER ID associated with each distance metric   ';
	'    index_ptr:  pointer for indexing while cascade-sorting       ';
	];

return


%--------------------------------------------------------------------------
function dc = readDataFile(path_to_file)

d_indices = [1:3 24:31 70:89 94:97]; % indices with numerical data
fid = fopen(path_to_file); % file pointer

is_csv = strcmp(path_to_file(end-3:end),'.csv');
is_dat = strcmp(path_to_file(end-3:end),'.dat');

if(is_csv)
    fchar = ' %q';
    delimiter_char = ',';
elseif(is_dat)
    fchar = ' %s';
    delimiter_char = '\t';
else
    error('MATLAB:DataFileFormat','File %s unrecognized format',path_to_file);
end

sf = repmat(fchar,1,327);
dc = textscan(fid,sf,'Delimiter',delimiter_char,'HeaderLines',1); 
fclose(fid);

% frewind(fid); fnames = textscan(fgetl(fid),sf,1,'Delimiter',',');
% fclose(fid);

fconv = @(c) cellfun(@str2double,dc{c}); % yay, for f(x) handles
for iid = d_indices, dc{iid} = fconv(iid); end % convert to arrays

return


%--------------------------------------------------------------------------
function mstruc = fetchMasterEntryStruc
% I'd like to clean this up or restructure the output of
% 'loadALLids' to circumvent or reduce the complexity of this
% problem with multiple consents/protocols for a given ID
%
% (The description below may not be entirely up to date.)
% It turns out there are likely to be multiple ID's associated
% with different protocols. This function checks for any
% duplicate ID's in the same protocol and returns the input
% structure without any duplicate entries; only entries
% associated with the earliest protocol is returned. This
% function returns an error if there are multiple IDs in the same
% protocol. 

ustruc = loadAllids;

d = ustruc.id_number;
dup_counts = [unique(d) histc(d,unique(d))]; % return duplicates

% if there is more than 1 duplicate, that can only be bad -> throw error
if(any(dup_counts(:,2) > 2))
    error('CANTAB:delta','too many duplicates in master list!');
end

qclear = false(length(d),1); % preallocate

for idii = 1:length(dup_counts)

	dup_id = dup_counts(idii,1); % set ID

	% if there are multiple IDs, make sure there's only one per protocol
	if(dup_counts(idii,2) > 1)

		% in the future, update this with a more dynamic routine to check
		% for any number of different protocols (probably using 'unique').
		both_protect = all(strcmp('PROTECT',p(d == dup_id)));
		both_suicide = all(strcmp('SUICID2',p(d == dup_id)));

        if(both_protect || both_suicide) % both entries under same protocol (bad)
			tmp = p(d == dset); 
			error('CANTAB:delta',['Inappropriate duplicate entry in master list!' ...
				sprintf('Two entries for %d under ''%s'' protocol\n',dup_id,tmp{1})]);
		else
			% index which indices to be removed
			later_date = max(ustruc.consent_date(d == dup_id));
			qclear = ( qclear & ( ustruc.consent_date == later_date ) );
        end
	end % if
end % for

% return structure with no duplicates
for fii = fieldnames(ustruc)

	% don't return entries from original structure as indicated by indices
	mstruc.(fii{:}) = ustruc.(fii{:})(~qclear);

end

return


%--------------------------------------------------------------------------
function distance = matchDistMetric(src_str,trg_str)
% first index of each varargin is ID number (will need to change this to
% char before passing to 'damlevdist').

% /* get Damerau-Levenshtein distance between IDs */
dtypo = damlevdist(num2str(src_str(1)),num2str(trg_str(1)));

% /* datenum component of vectors */
a = [0; ... 		% distance from src to src
	 src_str(2)]; 	% datenum(src)
b = [dtypo; ...     % distance from trg to src
     trg_str(2)];   % datenum(trg)

% /* compute Euclidean distance between entries */ 
distance = norm(a - b);

return


%--------------------------------------------------------------------------
function xout = cascadeRankSort(in_str,ex_str)

% /* check if existing entries is empty or not */
if(~isstruct(ex_str))
	eie = true;
end

% /* load master data set */
mstruc = fetchMasterEntryStruc;

% /* find duplicate closest matches to incoming entries */
%...

% /* while loop for cascade match/sort */
exist_conflicting_matches = 1;
while(exist_conflicting_matches)
    
    q_conflict = getDuplicateIndices(in_str(:).match_id(:)); 
    
    
end
    
% // true_entry.incoming
% //           .existing
% //           .master
% // logical arrays than cannot intersect (easy sanity check)

return

function q = getDuplicateIndices(s)

p = false(size(s));

uid = unique(s);
cid = histc(s,uid);

for ii = s(uid(cid > 1))
    p(s == ii) = true;
end
    
q = p;

return
