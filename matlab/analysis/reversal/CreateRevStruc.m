% Jan Kalkus
% 08 Feb 2012
% 
% A function for batch processing 'reversal' data


% INPUT DATA STRUCTURE FORMAT: 
%
%	subjSTRUC.subject_id
%			 .trial
%			 .correctstim
%			 .choice
%			 .resptime
%			 .stim1pos
%			 .stim2pos
%			 .stim1feed
%			 .stim2feed
%			 .stim1
%			 .stim2
%			 .specs (really only the date/time)
%

% TODO:
% OUTPUT DATA STRUCTURE FORMAT:
%
%		L2_rev = 
%
%			protocol: 'reversal'
%				 RTs: {subject_no}(ntrials x 1)
%			  choice: {subject_no}(ntrials x 1)
%	   			   ...
%			   specs: [struct{subject_no}.(fieldname)]
%			  fields: {n x 1 cell}
%


function CreateRevStruc

% quality-check the directories (check dir listing against master list)
dirCalidad;

% acquire list of subjects' data directories
dataDIR = getDataDir;

% parse file names
fileList = getDataFiles(dataDIR);

% call data mining f(x) for each subject's ID/file (can we use 'parfor'?)
for subj_i = fileList
	% iterative code
end

return

%--------------------------------------------------------------------------
function dirCalidad

% ultimately call function for 'DamerauLevenshteinDistance' (which needs to be written) if not every
% subject directory is a subset of the master list (also, make text version of master list and
% sub-f(x) to call that list
							 
fprintf('\n\t-  -  -  -  -  -   ATTENTION   -  -  -  -  -  - \n'); 
fprintf('\tUltimately, at this point in the script we''d   \n');
fprintf('\tcheck the directories of subjec ID''s and check \n');
fprintf('\tthem for errors against a \"master\" list of    \n');
fprintf('\tsubject ID''s. (A Damerau-Levenshtein distance  \n');
fprintf('\twill be calculated for each string combination  \n');
fprintf('\tto determine the closest match.)              \n\n');
fprintf('\tAt this point, we are not at that point.  \n\n\n\n');

return

%--------------------------------------------------------------------------
function odir = getDataDir;

% set default dir
if(ispc)
	defaultDIR = 'L:/Summary Notes/Data/Reversal Data/Cleaned_Baseline';
elseif(isunix)
	defaultDIR = '~/kod/devenv/reversal/Cleaned_Baseline/';
else
	fprintf('\n\n??? How are you running MATLAB on this machine ???\n');
	keyboard;
end

% check it
while(~isdir(defaultDIR))
	fprintf('!!! --> Sorry, can''t access \"%s\"\n',defaultDIR); pause(2); 
	if(ispc)
		defaultDIR = uigetfile;
	elseif(isunix)
		tic; while(toc < 10), defaultDIR = uigetdir; end
		while(~defaultDIR)
			fprintf('!!! --> Looks like your display isn''t working.\n');
			fprintf('\n\t You may enter the path manually below\n');
			fprintf('\t or enter ''c'' to cancel.\n');
			while(~defaultDIR)
				defaultDIR = input('\n Path to data: ','s');
				if(strcmp(defaultDIR,'c'))
					fprintf('\n TERMINATING... \n');
					error('CreateRevStruc:abort','function terminated');
				elseif(~isdir(defaultDIR))
					defaultDIR = 0;
				end
			end
		end
	end
end

odir = defaultDIR;
%fprintf('Using ''%s'' as data directory\n',odir); % for debugging

return

%--------------------------------------------------------------------------
function flist = getDataFiles(indir)

% get preliminary directory listing
preDIRlist = dir(indir); shlist = {};

c = struct2cell(preDIRlist);
dirName = cell(@(x) sscanf(x,'%d'),c(1,:),'UniformOutput',false);

% discard empty cells and convert to vector
flist = cell2mat(c( ~cellfun(@ismepty,c) ));

% files that don't meet naming criterion
shlist = dirName(cellfun(@isempty,c));
if(length(shlist) > 2)
	fprintf('\n The following files did not meet criteria and\n');
	fprintf('   were not added to the database: \n\n');
	for i = 1:length(shlist)
		nename = shlist{i};
		if(~strcmp(nename,'.') || ~strcmp(nename,'..'))
		fprintf('\t\t\t %s\n',shlist{i});
	end
end

% - - - - - - - - - - - - -
% THESE MAY BE USEFUL LATER
% - - - - - - - - - - - - -
%for i = 1:length(preDIRlist)
%	dirName = preDIRlist(i).name; 
%	if(length(dirName) > 12) % name can be shorter and still wrong
%		shlist = Cadd(shlist,dirName);
%		if(sscanf(dirName,'%d')) % there's a number in the DIR name (e.g., the patient ID)
	
% probably useful f(x)'s: isletter(), isspace(), deblank(), 
% 		sscanf('1234 .rev','%d') <-- this will return just a number !!

return

%---------------------------------------------------------------------------
function foo = Cadd(foo,bar)

% Because I'm anal about memory use

if(any( (size(foo) == 1) ))
	tmp = foo; clear foo;
	foo = {tmp{:} bar}';
end

return
