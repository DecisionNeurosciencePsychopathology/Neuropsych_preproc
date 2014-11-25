function createSubjIDlist

% Ideally, I'd like this to be more robust, allowing for overwrite or append 
% options OK, maybe not necessary (above), but instructions for obtaining the 
% master ID list from M$ Access should be listed here (under the function so 
% as to be returned when help is querried for this function). 
%
% Jan Kalkus
% 16 Feb 2012

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%	eventually, code to determine which algorithm is used to process
%	 incoming data (i.e., *.xls vs. *.txt --or even possibly *.dat)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% thanks mirosoft
if(~ispc)
	error('MATLAB:non_MS_OS', ...
        'Use of Excel libraries on non PC\nplatforms is not a great idea');
end

% read file (exported from M$ Access to *.xls file)
%fpath = [pathroot 'db/master id list.xlsx'];
fpath = 'L:/Summary Notes/Data/matlab/db/master id list.xlsx';

% import file
[num,~,raw] = xlsread(fpath); % (below) set NaN's to empty char strings
raw(cellfun(@any,cellfun(@isnan,raw(:,4),'UniformOutput',false)),4) = {''};
raw(cellfun(@any,cellfun(@isnan,raw(:,3),'UniformOutput',false)),3) = {''};
raw(:,4) = cellfun(@upper,raw(:,4),'UniformOutput',false); % all upper-case text

% organize
[unique_num, qn] = UniqueAndN(num); % handy PsychTB f(x)
subjectIDlistDB.id_number = unique_num; 
qm = zeros(length(unique_num),1); % initialize
qm( qn > 1 ) = qn( qn > 1 ); % find multiple matches in ID

for ni = 1:numel(unique_num)

    subjectIDlistDB.id_number(ni,1) = unique_num(ni);
    
    if(qm(ni)) % if this ID has multiple entries
        
        % indices in raw file corresponding to this ID
        qi = find( num == unique_num(ni))+1; % raw has extra row
        
        % grab relevand data for this subject
        data_chunk.protocol       = raw(qi,2);
        data_chunk.initials       = raw(qi,3);
        data_chunk.group          = raw(qi,4);
        data_chunk.consent        = raw(qi,5);
        
        % sort by most recent consent date for a given protocl
        [d,qsd] = sort(datenum(data_chunk.consent),1,'descend');
        
        % sanity check to make sure there are no hiccoughs
        redundant_fields = {'initials' 'group'};
        for sck = 1:numel(redundant_fields)
            ber = size(unique(data_chunk.(redundant_fields{sck})));
            if(any(ber > 1))
                error('MATLAB:redundancySanityCheck','something''s different!\n');
            end
        end
     
        % store data in structure
        subjectIDlistDB.consent_date{ni,1} = d;
        subjectIDlistDB.protocol{ni,1}     = data_chunk.protocol(qsd);
        subjectIDlistDB.initials{ni,1}     = cell2mat(unique(data_chunk.initials));
        subjectIDlistDB.comment{ni,1}      = upper(cell2mat(unique(data_chunk.group)));
        
    else
        
        % set indexing variable
        qi = find( num == unique_num(ni))+1;
        
        % grab data for this subject
        protocol    = raw(qi,2);
        initials    = raw(qi,3);
        status      = raw(qi,4);
        d           = datenum(raw(qi,5));
        
        % store it in the structure
        subjectIDlistDB.consent_date{ni,1} = d;
        subjectIDlistDB.protocol{ni,1}     = protocol;
        subjectIDlistDB.initials{ni,1}     = initials{:};
        subjectIDlistDB.comment{ni,1}      = upper(status{:});
        
    end
    
end


% --- old code ---
% subjectIDlistDB.id_number    = num;
% subjectIDlistDB.consent_date = datenum(txt(2:end,5)); % convert to date number
% subjectIDlistDB.protocol     = txt(2:end,2);
% fx = @(s) sprintf('%5.5s',sscanf(s,'%s %s')); % function handle for next line
% subjectIDlistDB.initials     = cellfun(fx,txt(2:end,3),'UniformOutput',false);
% subjectIDlistDB.comment      = upper(txt(2:end,4));
% when time permits, add a 'fields' field


% clean up comments (OTHER and OTHER PATIENT treated as same group)
subjectIDlistDB.comment = ...
    cleanupcomments('OTHER PATIENT','OTHER',subjectIDlistDB.comment);

% remove spaces and terminal period from initials
subjectIDlistDB.initials = ... 
    regexprep(regexprep(subjectIDlistDB.initials,'(\w)\.','$1'),' ','.');

l_drive = 'L:/Summary Notes/Data/matlab/';

% save file
save([pathroot 'db/subjIDlistDB.mat'],'subjectIDlistDB'); %Save local copy
save([l_drive 'db/subjIDlistDB.mat'],'subjectIDlistDB'); %Save remote copy

return

%--------------------------------------------------------------------------
function comment_cells = cleanupcomments(str_changethis,str_tothis,comment_cells)
% 2013-09-04 Jan Kalkus
% Some minor speed enhancements and syntax tidying. 

c = regexprep(comment_cells,str_changethis,str_tothis,'ignorecase');
comment_cells = c;

return
