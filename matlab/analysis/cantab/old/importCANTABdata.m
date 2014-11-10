function importCANTABdata( varargin )
% The impetus for this function is that duplicate IDs were found
% in the cumulative CANTAB data file. We want to avoid this and
% having to evaluate each duplicate by hand. Below follow my
% thoughts on what is involved in tackling this sort of problem.
%
% I see two problemast that need to be dealt with when accounting
% for duplicate entries and merging CANTAB data into a cumulative
% file. The first, problem alpha, is the presence of duplicates in 
% the incoming set (set A). The second, problem beta, is the
% presence of intersections between the incoming (set A' - why
% this is considered A' and not A will become apparent later) 
% existing CANTAB data (set B). 
%
% Perhaps there is an elloquent way of dealing with these two
% problemast.in unicen. For the sake of expediency (and maybe
% simplicity) I am dealing with each problem separately, in the
% following sequence. 
%
% Problem alpha:
%   If there are no duplicates (indexed by subjet ID), that's
%   great; just move on to the next step (set A = A').
%
%   If there are duplicates, these will need to be eliminated so
%   that set A is composed entirely of unique IDs. For each
%   duplicate set, the ID associated with the earliest NP test 
%   date is likely to be accurate (this will be double-checked by
%   making sure it's is within 3 weeks of the consent date). The
%   remaining will be considered duplicates. 
%
%   Each remaining duplicate will be "matched" with its closest 
%   pair(s) from the master list (set M) based on a distance
%   metric (shortest Euclidean distance in R^2 "misspell-date 
%   space"). Matches will be confirmed by user feedback. If there 
%   is more than 1 duplicate, previously matched IDs from the
%   master list will not be considered when finding matches for
%   the remaining duplicates. This will be repeated until no
%   duplicates remain. 
%
%   This will result in a new set, A', of which A is a subset.
%   Set A' contains additional IDs that set A does not. The
%   number of members of sets A and A' should be equal (unless
%   something has gone terribly wrong). 
%
% Problem beta:
%   If there are no intersects between set A' and the existing
%   set E (cumulative CANTAB data), great; all that is left to do
%   is append the new data from A' to E.
%
%   If there are intersections between set A' and E, they need to
%   be eliminated. For each intersecting set, the same procedure
%   to find the closest "match" and correct the error as
%   described above will be used. 
%
%   Set E should (but, logically, not necessesarily) now have new
%   (and necessarily unique) members. We can call this E'. It
%   doesn't matter much since E will cease to exist as E' will be
%   saved as the new cumulative CANTAB data file. (On the next
%   implimentation of this function, this current E' will be the 
%   future E). 
%
%   Logically, E' should be a subset of M with all members within
%   set M (isempty(setxor) should return true).
%
%
% Problem gamma*:
%   There are duplicates in set E. This is a big "no-no" and
%   indicates a serious problem. If this happens, yell at Jan;
%   it's likely he fudged something up in the algorithm. 
%
% Problem delta**:
%   There are duplicates in set M. This is even "no-no"-ier than
%   Problem gamma. Make sure this is not just an error from
%   saving data from MS Access to a text file; if there's an
%   error in the MS Access DB, you should contact Salem.
%
%
% *	this should not happen.
% ** this should not happen, even harder. 
%
%
% Jan Kalkus
% 31 Mar 2012


% TODO: Work more on this later; despite your "code once; code
% right on the first try," first get something that works, if
% only crudely. Then, work on the details (including adding to
% the TODO list desired future features). 
%
%	-- TODO --
%	000 - Small subfunction to return path of cumulative CANTAB
%	      file if it exists. Otherwise return 0. 
%
%	001 - If we can use SQL commands from MATLAB, then we could
%         pull data from the master ID list on demand. That 
%         would be really great. It might require use of a 
%         *.mex file though, which would necessitate brushing 
%         up on some C, at the least. 
%
%   002 - update check for DELTA to check for multiple IDs in
%         any protocol (use 'unique' to generate list, then 
%         check from there, probably with a for-loop), not just
%         the ones that are currently listed.
% 

% // STEP -2: PARSE INPUT 
% Check argument counts (would be nice to wrap this in a sub-function: later)
altdir = 'L:/Summary Notes/Data/CANTAB data/CANTAB files 2008-11.2011/Excel files/';
if(isempty(varargin))
    warning('MATLAB:import:argCount', ...
        'No arguments provided. Use ''help'' flag for more info.');
    varargin{1} = '4ffc630efb1c02c6e88d95a03a6c4070'; % cannot share name of *.m function
elseif(length(nargin) > 1)
    error('CANTAB:import:argCount', ...
        'Too many arguments. Only basic arguments supported for now.');
end


% // STEP -1: LOCATE FILE
% check argument validity (i.e., does file exist?)
%	(I know you want to work on the efficieny of this, but let 
%	it go for now.)

if(exist(varargin{1},'file')) % check for full path
	fpath = varargin{1}; % why was I using the below format?
elseif(exist(['./' varargin{1}],'file')) % check for local path
    fpath = ['./' varargin{1}];
elseif(exist([altdir varargin{1}],'file')) % check L drive
    fpath = [altdir varargin{1}];
else % otherwise, request user choose file w/ GUI
    [tmp_name,tmp_path] = uigetfile([altdir '*.xls*'],'Choose file to add to CANTAB cumulative');
	fpath = [tmp_path tmp_name];
    if(~tmp_name) % in case user aborts 'uigetfile'
        error('CANTAB:import:filePath','No files found for given input');
    end
end


% /* * * execute processing protocal * * */ %

% // STEP 0: LOAD INCOMING DATA
% load appropriate files
fprintf('Loading data...\n');
num = xlsread(fpath); % perhaps this could be replaces in the future 
% with a more nimble function by calling 'textscan' (the problem
% will be dealing with the "x","y", ... formatting)

% -- ALPHA -- %
% // STEP 1: FIND ANY DUPLICATE IDs
% look for duplicate IDs (in imcoming file)
dups = duplicateSearch(num(:,1));

% // STEP 2: DOES A CANTAB DB ALREADY EXIST?
% check for existing (cumulative CANTAB) file
prevCANTABfpath = checkForCumulativeFile;

% // STEP 3: FIX... WHAT EXACTLY?
% correct any errors found
newIds = heavyLifting(dups);

% -- BETA -- %
% busque intersecciones entre cumulative and new file IDs
intxIds = busqueIntx(newIds,prevCANTABfpath);

% correct any errors found
fixIds = heavyLifting(intxIds); % input needs to be an Nx3 matrix

return


%--------------------------------------------------------------------------
%  These sub-functions could be saved each as separate files. However, 
%  for the sake of portability, they are all included below, in one file. 
%  They appear, more or less, in the order in which they are called.
%--------------------------------------------------------------------------
function fout = checkForCumulativeFile
% Check for presence of the cumulative CANTAB data file

% this should be updated to source from its own tree (i.e., /kod/matlab/db/...
defpath = ['L:/Summary Notes/Data/CANTAB data/CANTAB files 2008-11.2011/' ...
	'Excel files/proc/cantab cumulative.csv'];

if(exist(defpath,'file'))
	[~,~,raw] = xlsread(defpath); % load existing file
	fout = raw;
else
	fout = NaN;
	warning('CANTAB:fileCheck:existingCANTAB', ...
        'No cumulative CANTAB file found, starting from scratch\n');
end

return


%--------------------------------------------------------------------------
function [d,n] = duplicateSearch(M)
% search for duplicate entries in an array; return list of unique IDs for
% which duplicates were found (e.g., [222, 322, 222, 412] returns [222])

counts = [unique(M) histc(M,unique(M))];

q = ( counts(:,2) > 1 ); % index duplicates only

% ouput list of ID's with more than one occurence
if(any(q))
	d = counts(q,1); 
else
	d = [];
end

% optional output
if(nargout > 1)
	n = counts(q,2);
end

return


%--------------------------------------------------------------------------
function xs = busqueIntx(newIds,yaIds)
% similar to the behavior of 'duplicateSearch' except instead of searching
% for duplicates we search for intersections; returns array of unique IDs

defpath = ['L:/Summary Notes/Data/CANTAB data/CANTAB files 2008-11.2011/' ...
	'proc/cantab cumulative.dat'];

if(~exist(defpath,'file')) % can cumulative CANTAB file be found?
	warning('CANTAB:intersect:noCANTAB', ...
        'No cumulative file found, so no intersections found.');
end

if(isnan(yaIds))
	xs = [];
	fprintf('\tNo intersections with current and new IDs. (Yay!)\n');
else
	% load cumulative CANTAB *.dat file

	% !! This is probably going to be a problem. The 'dlmread' function
	% !! will fail if the data format is uniform (which it will not be)
	% !! 'textscan' will be more flexible, though a bit more tedious.
	% ---> oldIds = dlmread(defpath,'\t',1,0); % just load the IDs

    % try this...
	f = fopen(defpath,'r'); % open file pointer
	oldIds = textscan(f,CTfmt(1),'HeaderLines',1,'Delimiter','\t');
	fclose(f); % kill it

	% -- GAMMA -- %
	if(any( histc(oldIds,unique(oldIds)) > 1 ))
		error('CANTAB:gamma:Duplicate IDs found in existing CANTAB file!');
	end

	xs = intersect(unique(newIds),oldIds); % finally, the intersections
end 

% not sure if this is a possible contigency (will check this logic later)
if(isempty(xs))
	fprintf('\tNo intersections with current and new IDs. (Yay!)\n');
end

return 


%--------------------------------------------------------------------------
function f = CTfmt(q)
% returns a formatted string corresponding to organization of the 
% cumulative CANTAB data file; input index specifies requested variables 

p = ['%d';'%d';'%s';'%s'; repmat('%f',61,1)]; % return all variables
n = num2cell(repmat('%*s',65,1),2); % return no variables

n{q} = p(q); % return format only for vars. specified by indices in q
f = cell2mat(n');

return


%--------------------------------------------------------------------------
function heavyLifting( d )
% where the real work is done; the input must have two dimensions, 
% 
%	1) ID
%	2) date of NP testing
%
% these will ultimately be used to match duplicates to their correct match

% organize input into variables
dup.ids = d(:,1);
dup.age = d(:,2); % can't be used yet, but may be helpful in output
dup.np  = datenum(d(:,3)); % use 'datestr' to conver back from double 

% load appropriate files (e.g., master list)
m = loadAllids('refresh'); % master list

% -- DELTA --
m = delta(m); % remove duplicate ID listed under multiple protocols

for dset = dup.ids % routine for each duplicate ID set
	qx = ( m.id_number == dset );
    
	if(any(qx)) % there are intersections
		% check for 

		% find earliest date within duplicates
		% compare to consent date (it would probably be best to compare
		% all duplicates to the consent date in case there are multiples
		% that are within 3 weeks -- cover all the bases). 
		% etc.
	end
end

return


%--------------------------------------------------------------------------
function ustruc = delta(mstruc)
% This checks for problem delta (see top). It turns out there are likely to
% be multiple ID's associated with different protocols. This function checks
% for any duplicate ID's in the same protocol and returns the input
% structure without any duplicate entries; only entries associated with the
% earliest protocol is returned. This function returns an error if there
% are multiple IDs in the same protocol.  

d = mstruc.id_number;
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
		% for any number of different protocols
		both_protect = all(strcmp('PROTECT',p(d == dup_id)));
		both_suicide = all(strcmp('SUICID2',p(d == dup_id)));

        if(both_protect || both_suicide) % both entries under same protocol (bad)

			tmp = p(d == dset); 
			error('CANTAB:delta',['Inappropriate duplicate entry in master list!' ...
				sprintf('Two entries for %d under ''%s'' protocol\n',dup_id,tmp{1})]);

		else

			% index which indices to be removed
			later_date = max(mstruc.consent_date(d == dup_id));
			qclear = ( qclear & ( mstruc.consent_date == later_date ) );

        end
	end % if
end % for

% return structure with no duplicates
for fii = fielnames(mstruc)

	% don't return entries from original structure as indicated by indices
	ustruc.(fii{:}) = mstruc.(fii{:})(~qclear);

end

return


%--------------------------------------------------------------------------
function q = dldist(a,b)

% I think this is redundant: if there is access to 'pathroot', then there
% should also be access to 'damlevdist'
addpath([pathroot 'programs/']); % guarantee access to 'damlevdist'
q = damlevdist(a,b);

return


%--------------------------------------------------------------------------
function s = writeCantab( x )
% not yet sure exactly how this is going to work, this should probably come
% later though, after other sub-functions

% this will essentially just be a looped fprintf routine, with variable
% names printed for the header; if necessary, sorting (by ascending ID 
% value) will take place here as well. 

if(x)
    fprintf('Not done yet\n');
end

return


