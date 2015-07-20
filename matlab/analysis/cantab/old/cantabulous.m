% notes
%
% step 0: convert *.csv file to *.dat file (matlab is OK and Octave is shitty at reading them)
%		  this processing could be called by this very functon. a batch file will be needed
%
% setp 1: ignore step 0, for now.
%

function cantabulous( varargin )

% code
if(strcmp('check',varargin))


if(~isunix)
    % open cumulative file
    data_in = loadCumulativeDataFile;
else
	% yay, octave!
	load('data_struc.mat');
end

	% search for duplicates and fix them
	data_out = cascadeRankSort(data_in);
	
    
elseif(strcmp('add',varargin))
    % not yet set up
	fprintf('not set up yet\n');
else
    fprintf('oops...\n');
end

return


%--------------------------------------------------------------------------
function fout = loadCumulativeDataFile
% Check for presence of the cumulative CANTAB data file. This is
% a bit tricky. I haven't quite worked out all the details yet...

defpath = [pathroot 'db/cantab/proc/cantab cumulative.dat'];

% % % % % TEMPORARY % % % % %
defpath = [pathroot 'db/cantab/proc/SummaryDatasheet-all.csv'];
% % % % % TEMPORARY % % % % %

if(exist(defpath,'file'))
	fprintf('Loading data...\n');
    fout = entryPrep(defpath);
else
	fout = 0;
	warning('CANTAB:fileCheck:existingCANTAB', ...
        'No cumulative CANTAB file found\n');
end

return


%--------------------------------------------------------------------------
function in_struc = entryPrep(file_path)
% Create a structure for use in determining which ID's are
% miss-typed and which are accurate. More details later. 

% /* get data from file */
data = readDataFile(file_path);

% set variables and allocate memory
n_entries = numel(data{1}); % number of entries
master = fetchMasterEntryStruc; % fetch master DB structure

% data{5} is protocol <-- this may be needed in the future
in_struc = struct('id',        data{1}, ...
                  'age',       data{2}, ...
				  'test_date', datenum(data{6}), ...
				  'sex',       data(4), ...
				  'm_rank',    nan(n_entries,length(master.id_number)), ...
				  'm_id',      zeros(n_entries,length(master.id_number)), ...
                  'specs',     struct('sort_order',cell(n_entries,1)), ...
                  'fields',    zeros(7,56));

for ii_subj = 1:n_entries
	% I don't like for loops, but I don't know of another way to
	% store data in this data structure format (or I'm short on
	% time)
	for jj_match = 1:length(master.id_number)

		% for clarity
		in_stuff = [in_struc.id(ii_subj); in_struc.test_date(ii_subj)];
		ma_stuff = [master.id_number(jj_match); master.consent_date(jj_match)];

		% compute distance in an R^2 space
		dxy = matchDistMetric(in_stuff,ma_stuff);

		% store results
		in_struc.m_rank(ii_subj,jj_match) = dxy;
		in_struc.m_id(ii_subj,jj_match)   = master.id_number(jj_match);
		
	end

	% /* sort according to distance */
    [in_struc.m_rank(ii_subj,:),qs] = sort(in_struc.m_rank(ii_subj,:));
    in_struc.m_id(ii_subj,:) = in_struc.m_id(ii_subj,qs);
    in_struc.specs(ii_subj).sort_order = qs;

end

% /* add helpful field information */ 
in_struc.fields = [
	'           id:  subject''s (supposed) ID number                   ';
	'          age:  subject age                                      ';
	'    test_date:  neuropsych. beginning testing date               ';
	'          sex:  sex of subject (assuming this is infallible)     ';
	'       m_rank:  distance from MASTER DB entries (ascending order)';
	'         m_id:  MASTER ID associated with each distance metric   ';
	'        specs:  stuff that may or may not be used                ';
	];

in_struc.protocol = data{5};
in_struc = orderfields(in_struc,[1:3 9 4:8]);

return


%--------------------------------------------------------------------------
function datacell = readDataFile(path_to_file)
% Description, description, desripciton, decsripton, deoncsoptn.

q_ints = [1:3 24:31 70:89 94:97]; % indices with numerical data
fid = fopen(path_to_file); % file pointer

% what format is data file?
is_csv = strcmp(path_to_file(end-3:end),'.csv');
is_dat = strcmp(path_to_file(end-3:end),'.dat');

if(is_csv)
    fchar = ' %q'; % quoted variables (I hate these-- so much)
    delimiter_char = ',';
elseif(is_dat)
    fchar = ' %s'; % just a chill string
    delimiter_char = '\t';
else
    error('MATLAB:DataFileFormat','File %s unrecognized format',path_to_file);
end

% extract actual data from raw file
per_line_format = repmat(fchar,1,327);
datacell = textscan(fid,per_line_format,'Delimiter',delimiter_char,'HeaderLines',1); 
fclose(fid);

% convert variables with numerical data to numbers
fconv = @(c) cellfun(@str2double,datacell{c}); % yay, for f(x) handles
for iid = q_ints, datacell{iid} = fconv(iid); end % convert to arrays

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
p = ustruc.protocol;
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
for fii = fieldnames(ustruc)'

	% don't return entries from original structure as indicated by indices
	mstruc.(fii{:}) = ustruc.(fii{:})(~qclear);

end

return


%--------------------------------------------------------------------------
function distance = matchDistMetric(src_str,trg_str)
% first index of each varargin is ID number (will need to change this to
% char before passing to 'damlevdist' since it only takes 'char' input).

% /* get Damerau-Levenshtein distance between IDs */
dtypo = damlevdist(num2str(src_str(1)),num2str(trg_str(1)));

% /* datenum component of vectors */
a = [0; ... % --------> distance from src to src
	 src_str(2)]; % --> datenum(src)
b = [dtypo; ... % ----> distance from trg to src
     trg_str(2)]; % --> datenum(trg)

% /* compute Euclidean distance between two vectors */ 
distance = norm(a - b);

return


%--------------------------------------------------------------------------
function xout = cascadeRankSort(xin)
% will type the rest later
%
% For each duplicate set in the INCOMING data IDs, the closest
% match will be identified and a request for user confirmation
% will be made. If the user decides it is an accurate match, then
% that will be chosen as the true match for that ID and pointers
% for the remaining IDs will be incremented to the next closest
% match. If the user decides that it is not an accurate match,
% then all pointers for that duplicate set are incremented. 


xworking = xin; % probably just temporary

%pointer_index = ones(n_entries,1); % try usnig bool matrix instead, if incrementing will work fine
pointer_index = false(size(xworking.m_id)); pointer_index(:,1) = true;
master_struct = loadAllids; % load master ids-struct
%q_to_remove   = false(size(xworking.id));
q_to_ignore = false(size(xworking.id));

% check for repeat entries
if(any(isRepeat(xworking.id)))
    redundancy_flag = true;
    fprintf('---> DUPLICATE ID ENTRIES FOUND...\n');
else
    redundancy_flag = false;
    fprintf('NO DUPLICATE ENTRIES FOUND\n');
end

% check for "unmatched" entried
if(any(~ismember(xworking.id,master_struct.id_number)))
    outofbounds_flag = true;    
    fprintf('---> OUT-OF-BOUNDS ID ENTRIES FOUND...\n');
else
    outofbounds_flag = false;
    fprintf('NO OUT-OF-BOUNDS ID ENTRIES FOUND\n');
end

% will this work?
first_run = 1;

% this loop is for duplicate entries
while(redundancy_flag || outofbounds_flag)
    
    % find any duplicates OR "unmatched" entries within the incoming data
    q_are_outofbounds = repmat(~ismember(xworking.id,master_struct.id_number),1,length(master_struct.id_number));
    q_are_duplicates  = repmat(isRepeat(xworking.id),1,length(master_struct.id_number));    
    
    % only point to indices that need to be changed
    q_culprit_pointer = ( q_are_outofbounds | q_are_duplicates ); 
    pointer_index = ( pointer_index & q_culprit_pointer );
    
    % ?????
    q_culprit_id = find(any(q_culprit_pointer,2) & ~q_to_ignore);
    
    %>>>>>>>>>>>>>>>>>>>>>>>>>
    for ii = 1:length(q_culprit_id)
        
        % find closest match
        q_p = find(pointer_index(q_culprit_id(ii),:) == 1) + (~first_run);
        closest_id_match = xworking.m_id(q_culprit_id(ii),q_p);
        
        % ask for confirmation to change
        qm = ( master_struct.id_number == closest_id_match );
        bool_confirmed = requestCorrectConfirmationPrompt( ...
            xworking,q_culprit_id(ii),master_struct,qm);
        
        % make appropriate changes
        if(bool_confirmed)
            pointer_index(q_culprit_id(ii),q_p) = true; % redundant?
        elseif(isnan(bool_confirmed))
            pointer_index(q_culprit_id(ii),q_p) = false; % delete
            %q_to_remove(q_culprit_id(ii)) = true;
            q_to_ignore(q_culprit_id(ii)) = true;
        else
            % rejected, move on to next pointer
            pointer_index(q_culprit_id(ii),q_p + 1) = true;
            pointer_index(q_culprit_id(ii),1:(q_p)) = false;
        end
        
        
        % clear previous entries
        pointer_index(q_culprit_id(ii),1:(q_p-1)) = false;
        imagesc(pointer_index(:,1:7)); % for debugging
        
    end

    % /* Check for any duplicate matched ID's

	% closest matches (and ranks) for those duplicates
	nearest_match = xworking.m_id(pointer_index);
    nearest_rank  = xworking.m_rank(pointer_index);
    
	% which numbers are repeat matches (only needed for duplicates)
	repeat_num = unique(nearest_match(isRepeat(nearest_match)));

    if(~isempty(repeat_num))
        for ii_set = 1:numel(repeat_num)

            % find indices of each set (don't use logical indexworkingg (why?))
            qr = nearest_match == repeat_num(ii_set);

            % which one is closest?
            ranks = nearest_rank(qr); % can this be a logical index instead?
            q_is_closest  = ( ismember(nearest_match,repeat_num(ii_set)) & ...
                ismember(nearest_rank,min(ranks)) );

            % ?....
            q_from_orig = find(q_are_duplicates | q_are_outofbounds);
            q_backtrack = q_from_orig(q_is_closest);

            % ask for input/confirmation
            bool_conf = requestCorrectConfirmationPrompt( ...
                xworking,q_backtrack,master_struct,qm);

            if(bool_conf) % user has confirmed that closest match calculated is acceptable

                % return the indices of matches, except for the closest one
                q_to_increment = ( ismember(nearest_match,repeat_num(ii_set)) & ...
                    ismember(nearest_rank,ranks(ranks > min(ranks))) );

            else % user does not agree with closest match calculated, 

                % increment all duplicates for this ID
                q_to_increment = ( ismember(nearest_match,repeat_num(ii_set)) & ...
                    ismember(nearest_rank,ranks) );
            end

            % increment pointers for "not as close" OR "rejected" matches
            [ia,ib] = find(pointer_index == 1);
            pointer_index(ia(q_to_increment),ib(q_to_increment)+1) = true;
            pointer_index(ia(q_to_increment),ib(q_to_increment))   = false; % clear old entry
     
        end % for loop
    end

	% can we break the loop?
	final_set_matrix = catExistingAndPtrNums(xworking.id,xworking.m_id,pointer_index);
	redundancy_flag  = any(isRepeat(final_set_matrix)); % check for any repeats
    outofbounds_flag = any(~ismember(final_set_matrix,master_struct.id_number));
    xworking.id = final_set_matrix;
    
    first_run = 0;
    
end % while loop

% at this point everything should be sorted
xout.id = catExistingAndPtrNums(xworking.id,xworking.m_id,pointer_index);

return


%--------------------------------------------------------------------------
function nms = catExistingAndPtrNums(orig_mat,pt_mat,ptrs)

q_pointed_entries = any(ptrs,2);

nms(~q_pointed_entries,:) = orig_mat(~q_pointed_entries);
nms( q_pointed_entries,:) = pt_mat(ptrs);

return


%--------------------------------------------------------------------------
function BOOL_yes_or_no = requestCorrectConfirmationPrompt(idata_struc,q_idata,mdata_struc,q_mdata)
% pretty simple, point and shoot
%
% TODO: in the future, I'd like to set this up to be more elegant. I'd like 
% to show multiple possible matches to a master_struct entry, showing their
% ranks and which one is closest

% Do tabs work the same way in 'fprintf' as in, say, a word
% document? If so, formatting could be simplified big time

idata = { ...
    idata_struc.id(q_idata); ...
    idata_struc.test_date(q_idata); ...
    idata_struc.sex{q_idata}
};
mdata = { ...
    mdata_struc.id_number(q_mdata); ...
    mdata_struc.initials{q_mdata}; ...
    mdata_struc.consent_date(q_mdata)
};

iheaders = {'INCOMING DATA SPECS.';'ID No.'; ''; 'Test date'; 'Gender'};
mheaders = {'MASTER DATA SPECS.';'ID No.'; 'Initials'; 'Consent date'; ''};
spacer = @(x) fprintf('%s\n',repmat('- ',1,x));

% code:
fprintf('\n%6sPLEASE CONFIRM THE FOLLOWING POSSIBLE MATCH\n',' ');
spacer(29);
fprintf('%21s%15s',iheaders{1},' ');
fprintf('%20s%10s\n',mheaders{1},' ');
spacer(29);

% ID
fprintf('  %s %13d',iheaders{2},idata{1});
fprintf('%18s %17d\n',mheaders{2},mdata{1});

% initials
fprintf('%34s',' ');
fprintf('%s%15s\n',mheaders{3},mdata{2});

% date
fprintf('%11s%17s',iheaders{4},datestr(idata{2},'mmm dd, yyyy'));
fprintf('%18s%18s\n',mheaders{4},datestr(mdata{3},'mmm dd, yyyy'));

% gender
fprintf('%8s%15s\n',iheaders{5},idata{3});
spacer(29);

while(1)
    sreply = input('Accept this match? [Y/n]: ','s');
    
    % yes is the defauls answer, just hit RETURN/ENTER to accept
    if(isempty(sreply)), sreply = 'y'; end  
    
    switch sreply
        case {'y' 'Y' 'yes' 'Yes' 'YES'}
            % accept match
            BOOL_yes_or_no = true; break;
        case {'n' 'N' 'no' 'No' 'NO'}
            % do not accept match
            BOOL_yes_or_no = false; break;
        case {'i' 'I' 'ignore' 'Ignore' 'IGNORE'}
            % do not include this ID in final output
            BOOL_yes_or_no = NaN; break;
        otherwise
            % do not understand, try again
            fprintf('\n invalid entry, please try again \n');
    end
    
end % while

clc;

return
