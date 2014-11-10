% / * * * * *
% 
%	This function has one required input, the path to a
%	data file containing patient IDs and medications. This
%	file should be a tab delimited ASCII file. One can 
%	easily be created from an existing SPSS file by 
%	choosing 'Save as...' and selecting 'delimited file' 
%	as the format (resulting file extension should be *.dat).
%
% 
%	Features yet to arrive:
%
%		- file paths can be entered or selected manually
%		- input will be compared to DB of medicines, for
%		  meds not listed, user will be prompted to 
%		  classify (this will subsequently be added to the
%		  DB file)
%		- ouput file will include variable names in first
%		  row of text for clarification and ease of 
%		  conversion to SPSS
%
%   * * * * * /

% Jan Kalkus
% 14 Mar 2012 (Happy Pi day)


% This needs to be rehauled and make use of 'varargin' for more
% dynamic performance. 
%
% Input file should have only 3 columns: ID, meds, date

% function meds_codes = compileMeds(varargin)

function meds_codes = compileMeds(target_file_path)

[fid status] = fopen(target_file_path); % open a pointer to the file

if(~isempty(status)) % Couldn't open the file for some reason 
	error('MATLAB:compileMeds:fopen',['Could not open file ''%s\n'''...
        '\t status: %s\n'],target_file_path,status);
	% /*	in the future, this will include a subsequent 
	%  *	prompt for the user to choose a file manually 
	%  */ 	with the GUI
end

format_string = '%d %*s %s %d %*s %*s %*s %*s %*s %*s %*s'; % only grab necessities
raw_data = textscan(fid,format_string,'delimiter','\t','CommentStyle',sprintf('ID\t'));

% -- compile subject by subject data...
% !!! Need to change this to 'xlswrite' or something that will output
% !!! a file which can be direclty imported by SPSS
meds_codes = organizaSujetos(raw_data);
save(['coded_meds_' datestr(date,'yyyy-mm-dd') '.dat'],'meds_codes','-ascii','-tabs');

% -- organize drugs into classes... (not yet complete)
clasificoDrogas

return


%--------------------------------------------------------------------------
function sout = organizaSujetos(data_in)

unique_ids = unique(data_in{1}); % only unique IDs
sout = zeros(length(unique_ids),4); % allocate memory
s = warning('off','MATLAB:conversionToLogical'); % turn off annoying 'logical()' warnings

for subj_i = 1:length(unique_ids)

	q = ( unique_ids(subj_i) == data_in{1} ); % find indices for this subj. ID
	drugs = data_in{3}(q); % find drug codes for this ID

	% sort and code output (no entries == no meds)
	sout(subj_i,1)     = unique_ids(subj_i);
	sout(subj_i,2:end) = logical(histc(drugs,1:3)'); % concise

end

warning(s); % restore previous warning settings

return


%--------------------------------------------------------------------------
function clasificoDrogas

% code
fprintf('\n!! Creating or concatenating meds list DB not yet functional !!\n');
fprintf('\n (Subjects'' meds were coded correctly if you made it this far)\n');

% just stick with one platform for now (M$ Windows)
if(ispc)
	% look in the 'llmd' drive for the list of meds
	% if it's not there, abort
elseif(isunix)
	% check to see if running on wallace 
	% if so, look in '~/kod/matlab/jan/db/'
	% otherwise, abort
end

return

% %%DIAGNOSTICS
%
%target_file = 'c:/kod/matlab/jan/db/fMRI Med list original form.dat';
%x = compileMeds(target_file);

