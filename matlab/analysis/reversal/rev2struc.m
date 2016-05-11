% Jan Kalkus
% 07 Feb 2012
%
% A low-level function that converts raw 'reversal' data into a MATLAB structure

function subj_STRUC = rev2struc(filePath)

% get some experiment specs from file
exp_specs = getFileSpecs(filePath);

% get actual data
exp_data = getFileData(filePath);

% organize and store data
subj_STRUC = fieldcat(exp_data,exp_specs);

return



%--------------------------------------------------------------------------
function fspecs = getFileSpecs(fpath)

[fid m] = fopen(fpath,'r');

if(isempty(m))
	fspecs.ID   = str2double(fscanf(fid,'%s',1));
	% is time format in UTC or EST?
	fspecs.date = datestr([fscanf(fid,'%s',1) ' ' fscanf(fid,'%s',1)]);
	fclose(fid);
else
	error('MATLAB:fopen:FileNotFound','%s: ''%s''',m,fpath);
end

return

%--------------------------------------------------------------------------
function fdata = getFileData(fpath)

rdata = dlmread(fpath,'',2,0); % in one fell swoop
fdata = struct; fnames = makeFields;

for ncols = 1:(size(rdata,2) - 1) % awkward raw format results in extra col
	fdata.(fnames{ncols}) = rdata(:,ncols);
end

return

%--------------------------------------------------------------------------
function fs = makeFields

% /* * * NOTE * * *
%  * 
%  * It would be nice to change these to more intuitive labels
%  *
%  * * * NOTE * * */
fs = {'trial','correct_stim','choice','RT','stim1_position','stim2_position', ...
	'stim1_feedback','stim2_feedback','stim1_identity','stim2_identity'};	

return

%--------------------------------------------------------------------------
function snew = fieldcat(s,spec)

% add fields
s.specs      = spec.date;
s.subject_id = spec.ID;

% re-order them
nfs  = length(fieldnames(s));
snew = orderfields(s,[nfs 1:nfs-1]);

return
