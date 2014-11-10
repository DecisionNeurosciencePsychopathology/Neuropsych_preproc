% Jan Kalkus
% 2012 Feb 6

% wait, does this actually work?

function CompileULTdata(gameType)
% Look for new data files in the directory containing the 'Ultimatum Task' data. Ideally this
% program can be used as part of a larger data compiling function, more on that later. 

% ### ACQUIRE AND MOVE TO DATA DIRECTORY ###

gameType = 'ultimatum'; % at the moment, that's all I'm doing
returntoDIR = pwd; % after execution, return here

if(ispc)
	dataTargetDIR = 'L:\Summary Notes\Data\Ultimatum Game\Data\';
	while(~isdir(dataTargetDIR))
		fprintf('!!! --> Sorry, can''t access \"%s\"\n',dataTargetDIR);
		pause(2); dataTargetDIR = uigetfile;
	end
elseif(isunix)
	tic; 
	while(toc < 5)
		dataTargetDIR = uigetdir; 
	end
	if(dataTargetDIR == 0)
		fprintf('!!! --> Looks like your display isn''t working.\n');
		fprintf('\n\t You may enter the path manually below\n');
		fprintf('\t or enter ''c'' to cancel.\n');
		while(~dataTargetDIR)
			dataTargetDIR = input('\n Path to data: ','s');
			if(dataTargetDIR == 'c')
				fprintf('\n TERMINATING... \n');
				return;
			elseif(~isdir(dataTargetDIR))
				dataTargetDIR = 0;
			end
		end
	end
else
	fprintf('!!! --> How are you running MATLAB on this computer?\n');
	return;
end

cd(dataTargetDIR);


% ### SEARCH FOR SUBJECT NUMBER DIRS ###

subjDirSpec = dir; index = 3; % first two listings are ./ and ../
mark_1_data = struct;

for subject_i = index:length(subjDirSpec)
	if(subjDirSpec(subject_i).isdir)
		% In this loop is where we could check for already-processed subjects (later)
		if(length(dir([pwd '/' subjDirSpec(subject_i).name])) > 2)
			%extracted_STRUC = lowlevelIOextract('ultimatum'); % later, Jan. Later. 
            subjectNumber = subjDirSpec(subject_i).name;
            if(length(subjectNumber) > 5)
                f = ['UG_Pitt_Beh_ShiftSpace5-' subjectNumber(2:end) '-1.txt'];
                g = [pwd '/' subjectNumber '/' f];
                if(exist(g,'file'))
                    currentFieldName = ['subject_' subjectNumber];
                    fprintf('Extracting data for subject %s...\n',subjectNumber);
                    mark_1_Data.(currentFieldName)= extract_data(subjDirSpec(subject_i).name); 
                else %if(length(dir([pwd '/' subjDiSpec(subject_i).name])))
                    % alternatively, you could store these values and display upon exiting
                    fprintf(' WARNING: No data found for subj. %s !\n',subjDirSpec(subject_i).name);
                end
            end
		end
	end
end

% ### SAVE DATA ###
save('ULT_data_structure',mark_1_data);

cd(returntoDIR);

return


%--------------------------------------------------------------------------
function out_STRUC = extract_data(subjID)

fileName = ['UG_Pitt_Beh_ShiftSpace5-' subjID(2:end) '-1.txt']; % only 14 (?) bits!
fid = fopen([pwd '/' subjID '/' fileName]);

% prepare data structure
out_STRUC = loadDataStructure(subjID); % need to finish writing
n = 0;

% prepare query structure
querySTRUC = loadqStructure;

while(ftell(fid) > -1)

	currentLineTXT = fgetl(fid); % get text from current line
	czsum = 0;

	for datum_i = 1:length(querySTRUC.fields)
        stringName = querySTRUC.strName{datum_i};
        trn = querySTRUC.ntrunc(datum_i);
		if(strcmp(stringName,'_sex_'))
			tmpvar = tediousStringPull('females',currentLineTXT,0,czsum);
			if(tmpvar.a)
				out_STRUC.(querySTRUC.fields{datum_i})(n) = 'female';
				czsum = tmpvar.c;
			else
				tmpvar = tediousStringPull('males',currentLineTXT,0,czsum);
				if(tmpvar.a)
					out_STRUC.(querySTRUC.fields{datum_i})(n) = 'male';
					czsum = tmpvar.c;
				end
			end
		else
			tmpvar = tediousStringPull(stringName,currentLineTXT,trn,czsum);
			if(tmpvar.a)
                fprintf('.');
				if(datum_i == 1), n=n+1; end
				if(querySTRUC.isnum(datum_i))
					out_STRUC.(querySTRUC.fields{datum_i})(n) = str2double(tmpvar.b);
				else
					out_STRUC.(querySTRUC.fields{datum_i})(n) = tmpvar.b;
				end
				czsum = tmpvar.c;
			end
		end
		if(czsum > 0 && czsum < length(querySTRUC.fields))
			fprintf('!!! --> Something wrong here; missing data entry?\n');
			keyboard;
		end
    end

    fprintf('next line\n');
	% more?

end

return


%--------------------------------------------------------------------------
function strOut = tediousStringPull(strIn,lineIn,ntrunc,cz)

if(~exist('ntrunc','var')), ntrunc = 0; end

strLen = length(strIn);

stringMatch = isempty(strfind(lineIn,strIn)); 
if(~stringMatch)
	startPtr = strfind(strIn,lineIn);
	strOut.a = boolean(1);
	strOut.b = lineIn((startPtr + strLen):end-ntrunc); 
	strOut.c = cz + 1;
else
	strOut.a = boolean(0);
	strOut.b = NaN;
	strOut.c = cz;
end

return



function qstruc = loadqStructure

qstruc.fields = {
	'trial_id'
	'proposer_id'
	'stake_id'
	'offer'
	'condition'
	'sex'
	'sex_id'
	'face_id'
	'trial_order'
	'accepted'
	'RT'
};
qstruc.strName = {
	'Trials1: '
	'Proposer: '
	'Stake: '
	'Offer: '
	'Condition: '
	'_sex_'
	'males: '
    'face: '
	'Trials1.Sample: '
	'Offer.ACC: '
	'Offer.RT: '
};
qstruc.ntrunc = [
	0
	4
	4
	4
	0
	0
	0
	0
	0
	0
	0
];

qstruc.isnum = [
	1
	0
	0
	0
	0
	0
	1
	0
	1
	1
	1
];

return


%--------------------------------------------------------------------------
function o_str = loadDataStructure(sID)

% this is not in the same order as structure above
o_str.subject_id  = str2double(sID);
o_str.trial_id    = [];
o_str.trial_order = [];
o_str.proposer_id = {};
o_str.stake_id    = {};
o_str.offer       = {};
o_str.condition   = {};
o_str.RT          = [];
o_str.sex         = {};
o_str.sex_id      = [];
o_str.face_id     = {};

return
