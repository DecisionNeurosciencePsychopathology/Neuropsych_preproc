function gstruc = UGmakegeedatafile

% read in more variables
allvnames = readinvars([pathroot 'db/megadata/megadatafile_var-names.dat']);

% return structure containing names, fields, and formats for vars
vars = returnvarstruc;

% create format string for use in 'textscan'
sfmt = num2cell(repmat('%*s',length(allvnames),1),2); 
for vii = 1:length(vars.query_name)
    
    % find indices of variable
    vs = vars.query_name{vii};
    q  = strcmp(vs,allvnames);
    
    % insert appropriate format 
	if(all(~q))
		warning('MATLAB:UGmakeGEE:VarNotFound','Variable ''%s'' not found',vs);
	else
		sfmt{q} = vars.format{vii};
	end
    
end

% get values from *.dat file (SPSS > Save as...)
f = fopen([pathroot 'db/megadata/megadatafile_most-recent.dat'],'r');
data = textscan(f,cell2mat(sfmt'),'HeaderLines',1,'Delimiter','\t', ...
    'EmptyValue',NaN); %,'CommentStyle','/*');
fclose(f); % kill it

% organize data
for fii = 1:length(data)
    field_name = vars.field_name{fii};
    UGstruc.(field_name) = data{fii};
end

% get latest file
dname = mostrecentUGdir([pathroot 'analysis/ultimatum/data/']);
fpath = [pathroot 'analysis/ultimatum/data/' dname '/ball.mat'];

% load UG data file
load(fpath);
g.geedata={}; % init./allocate

fprintf('Processing data...\n');
for sub = 1:length(ball.trial)
	
	n = 0; subtrialdata = {}; % init vars
    qid = ( UGstruc.id == ball.id(sub) );
    
	if(any(qid))
    
        ntrial = 1:length(ball.trial(sub).accept);
        field_nom = fieldnames(UGstruc);
        
		% vars from SPSS 'megadatafile'
        for fii = 1:length(field_nom)
            n=n+1;
            
            % if data is type 'char' no need to put into a cell,
            % it alread is; just pass it on it
            if(strcmp('%s',vars.format{fii}))
                subtrialdata(ntrial,n) = UGstruc.(field_nom{fii})(qid);
            else
                subtrialdata(ntrial,n) = {UGstruc.(field_nom{fii})(qid)};
            end
        end
        
        % additional vars. not in SPSS 'megadatafile'
        % ...
		n=n+1; subtrialdata(ntrial,n) = num2cell(ball.trial(sub).accept);            % accept = 1
		n=n+1; subtrialdata(ntrial,n) = num2cell(ntrial);                            % trial id
		n=n+1; subtrialdata(ntrial,n) = num2cell(ball.trial(sub).fairness);          % trial fairness
		n=n+1; subtrialdata(ntrial,n) = num2cell(ball.trial(sub).stake);             % trial stake
		n=n+1; subtrialdata(ntrial,n) = num2cell(ones(size(ball.trial(sub).stake))); % constants

		g.geedata=[g.geedata; subtrialdata]; % concatenate
        
	end
end

fprintf('Saving data...\n');
% save GEE data locally
g.varnames  = [vars.field_name {'accept' 'trial' 'fairness' 'stake' 'const'}];
saveData('data/GEEdata',g,vars.format);

% % /* get data for 60+ only */
% q60 = cellfun(@(a) a >= 60,g.geedata(:,6)); % indices of older subjs.
% g60.geedata  = g.geedata(q60,:); % check if this works
% g60.varnames = g.varnames;
% saveData('data/GEEdata60+',g60,vars.format);

if(nargout)
    gstruc = g;
end

fprintf('\n N = %d \n',numel(unique(cell2mat(g.geedata(:,1)))));

return


%-------------------------------------------------------------------------
function a = readinvars(b)
% returns a list of variable names from the (prior SPSS, now *.dat) file
% in the future, a universal function (stored in 'programs') will adopt 
% some of these methods to read varables from the first line of a text file,
% invariant of which delimiter is used.

f = fopen(b,'r');
x = textscan(f,'%s'); % what happens if '\n' is delimiter?
fclose(f);

a = x{:};

return


%-------------------------------------------------------------------------
function vars = returnvarstruc
vars.query_name = {...
    'ID', ...
    'Group12467', ...
    'Lethality', ...
    'Gender', ...
    'RACET', ...
    'AgeatConsent', ...
    'WTARSSWTARStandardScore', ...
    'TOTA_MDRS', ... % Mattis Dementia Rating Scale
    'EXITtotal', ...
        'PPOSUB', ...
        'NPOSUB', ...
        'RPSSUB', ...
        'ICSSUB', ...
        'ASSUB', ...
        'SPSITOT_EA', ...
    'burdentotal', ...
        'IIP15INTSEN', ...
        'IIP15INTAMBV', ...
        'IIP15AGRESS', ...
	'ADMCHRS17TOT', ...
    'BIS', ...
    'UPPS_Negurgency', ...
    'UPPS_Posurgency'};

vars.field_name = { ...
    'id', ...
    'group', ...
    'lethality', ...
    'gender', ...
    'race', ...
    'age', ...
    'wtarZ', ...
    'mdrs', ...
    'exit', ...
        'pposub', ...
        'nposub', ...
        'rpssub', ...
        'icssub', ...
        'assub', ...
        'spsi_total', ...
	'burden', ...
        'iip_intsen', ...
        'iipint_ambv', ...
        'iip_agress', ...
    'hrsd', ...
    'bis', ...
    'upps_neg_urgency', ...
    'upps_pos_urgency'};

vars.format = { ...
    '%d', ... % id number
    '%d', ... % group number
    '%d', ... % lethality
    '%s', ... % gender
    '%s', ... % race
    '%d', ... % age
    '%d', ... % WTAR standardized
    '%d', ... % MDRS
    '%d', ... % EXIT
    '%d', ... % SPSI ppo
	'%d', ... % SPSI npo
	'%d', ... % SPSI rps
	'%d', ... % SPSI ics
	'%d', ... % SPSI as
	'%d', ... % SPAI total
	'%d', ... % burden
	'%d', ... % IIP int sen  (%d or %f?)
	'%d', ... % IIP int ambv (%d or %f?)
	'%d', ... % IIP agress   (%d or %f?)
	'%d', ... % HRSD?
    '%d', ... % BIS
    '%d', ... % UPPS neg. urg.
    '%d', ... % UPPS pos. urg.
    '%d', ... % accept *
    '%d', ... % trial *
    '%d', ... % fairness *
    '%d', ... % stake *
    '%d'};    % const *

return


%-------------------------------------------------------------------------
function dout = mostrecentUGdir(path_to_dirs)

% code
d = dir(path_to_dirs); %
sstr = '_data_';

% find pattern in dir listing
slocfind = @(x) strfind(x,sstr) + length(sstr);
xloc     = cellfun(slocfind,{d.name},'UniformOutput',false);

% grab dates from dir string
dstrip = @(ds,xp) ds(xp:end);
dstr   = cellfun(dstrip,{d.name},xloc,'UniformOutput',false);

% sort dates and use the most recent
fdnum = cellfun(@datenum,dstr(~cellfun(@isempty,dstr)));
spart = datestr(fdnum(fdnum == max(fdnum)));

% recreate file name 
c = cellfun(@(s) strfind(s,spart),{d.name},'UniformOutput',false);
%dout = {d.name}{~cellfun(@isempty,c)}; % works in GNU Octave :(
tmp = {d.name};
dout = tmp{~cellfun(@isempty,c)};

fprintf('dout = %s\n',dout);

return


%-------------------------------------------------------------------------
function saveData(filename,data_struc,varformat)

% arg-check
if(ne(length(data_struc.varnames),length(varformat)))
	error('MATLAB:saveData:ArgCheck', [ '''varformat'' and ''varnames''' ...
		' field of ''data_struc'' not equal lengths']);
end

% save *.mat file
save([filename '.mat'],'data_struc');
filenameSPSS = [filename 'SPSSready.dat'];

% save tab-delimited file for use in SPSS
f = fopen(filenameSPSS,'w');
for fii = 1:length(data_struc.varnames)
    fprintf(f,'%s',data_struc.varnames{fii});
    if(ne(fii,length(data_struc.varnames)))
        fprintf(f,'\t');
    else
        fprintf(f,'ant\n');
    end
end

% now write the data
for rowii = 1:size(data_struc.geedata,1)
	for varii = 1:length(varformat)

		% manage numeric precision (might need to be updated)
        if(strcmp(varformat{varii},'%d'))
			vf = '%6g';
		else
			vf = varformat{varii};
        end
        
		% write the data to file
		fprintf(f,vf,data_struc.geedata{rowii,varii});

		% print delimiter or newline where appropriate
		if(ne(varii,length(varformat)))
			fprintf(f,'\t');
		else
			fprintf(f,'\n'); 
		end

	end
end

fclose(f); % kill it (no loose ends)

return
