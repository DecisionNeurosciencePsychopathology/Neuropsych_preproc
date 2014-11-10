function makeSparseGEE( varargin )
% the earlier script I wrote was too specific and depended on one
% unique file. bad move. this one writes out the trial-by-trial
% ultimatum game data, with one row per subject and one column
% per trial. 
%
% Jan Kalkus
% 10 Jul 2012
% 
% Updated with a support for a few 'varargin' options. I should
% update the main function description when I get a chance. 
% 07 Nov 2012

% function handles for the lazy (me)
f_argpos = @(x) find(strcmp(x,varargin),1);
f_argchk = @(y) isempty(f_argpos(y));

if(f_argchk('use-dir'))
    % get latest file
    dname = mostrecentUGdir([pathroot 'analysis/ultimatum/data/']);
    fpath = [pathroot 'analysis/ultimatum/data/' dname '/ball.mat'];
else
    % a yet to come option (though perhaps not entirely
    % necessary, we'll see)
    q = f_argpos('use-dir')+1;
    fprintf('don''t have that functionality built-in yet\n');
    fprintf('...but if you did, q = ''%s'', by the way.\n',varargin{q});
	clear('q'); % recycle variable
end

% load UG data file
load(fpath);

% use a subset or all of the ID's
if(f_argchk('use-ids'))
    id = [ball.id]'; % use all ID's
else
    q  = f_argpos('use-ids')+1;
    id = ball.id(ismember(ball.id,varargin{q}))';
	clear('q'); % recycle variable
end

if(f_argchk('add-vars'))
    % check for additional variables to add
    extra_vars_flag = false;
else
    extra_vars_flag = true;
    q = f_argpos('add-vars')+1;
    extra_vars = varargin{q};
    clear('q'); % recyle!
    if(f_argchk('var-names'))
        % make dummy var-names
        nvars = size(extra_vars,2);
        f_name_vars = @(w) sprintf('VAR%g',w);
        var_names = arrayfun(f_name_vars,1:nvars,'UniformOutput',false);
    else
        q = f_argpos('var-names')+1;
        var_names = varargin{q};
        clear('q'); 

		% check that the number of variables and number of 
        % variables names are the same.
        var_name_count_fail = ne(size(extra_vars,2),numel(var_names));
        
        % check that the number of instances of extra variables
        % match the number of ID's being used
        var_id_count_match_fail = ne(size(extra_vars,1),numel(id));
        
		if(var_name_count_fail || var_id_count_match_fail)
            if(ischar(var_names))
                % if only one var name is entered, the above
                % condition will be true and subsequent
                % operations below would fail
                var_names = {var_names};
            else
                whos('id','extra_vars','var_names'); % see what the counts are
                error('MATLAB:makeGEE:var_count_fail', ...
                    'variable name and/or instance count(s) do not match');
            end
		end
    end
end

% sanity-check, beacuse I'm paranoid
if(numel(id) ~= numel(unique(id)))
	error('MATLAB:makeSparseGEE:dubs','Dubs? Czech ''em.');
end

% the brunt of the writing is done here (well, soon after here)
q_this_is_relevant_to_my_interests = ismember(ball.id,id);
q_that_variable_name_is_too_long   = q_this_is_relevant_to_my_interests;
q_relevant_to_my_interests         = q_that_variable_name_is_too_long;

if(extra_vars_flag)       
    if(iscell(extra_vars))
        % ...too bad
        error('MATLAB:makeGEE:no_cell_support','cell structures not yet supported');
    else
        % create typical array structure for data matrix
        butt_load_of_data = [ ...
            id        repmat(1:24,numel(id),1) ...
            [ball.trial(q_relevant_to_my_interests).accept]' ...
            [ball.trial(q_relevant_to_my_interests).fairness]' ...
            [ball.trial(q_relevant_to_my_interests).stake]' ...
            ones(numel(id),24) ...
            extra_vars ...
        ];
    end
else
    % FUN FACT: a 'butt' is an actual unit of measurement
    % check it out for yourself: http://wolfr.am/mRjVgm
    butt_load_of_data = [ ...
        id        repmat(1:24,numel(id),1) ...
        [ball.trial(q_relevant_to_my_interests).accept]' ...
        [ball.trial(q_relevant_to_my_interests).fairness]' ...
        [ball.trial(q_relevant_to_my_interests).stake]' ...
        ones(numel(id),24) ...
    ];
end

% prep for file-writing (don't open file until we're all ready)
fname = sprintf('gee_sparse_file-N=%d.dat',numel(id));
out_file = [pathroot '/analysis/ultimatum/gee/data/' fname];
fid = fopen(out_file,'w'); 
printFileHeaders(fid);

if(extra_vars_flag) % print extra var. names (if applicable)
    fseek(fid,-1,0); % step back one to add more variable names in header
    fprintf(fid,'\t%s',var_names{:}); % print extra variable names
    fprintf(fid,'\n');
end

% actually print out the data to a file
for row_i = 1:numel(id)
	fprintf(fid,'%g\t',butt_load_of_data(row_i,:)); % print row of data
	fseek(fid,-1,0); fprintf(fid,'\n'); % replace trailing \t with \n
end

% kill it 
fclose(fid);

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
function printFileHeaders(fid)

fprintf(fid,'ID\t');
for ii = {'trial','accept','fairness','stake','const'};
    for jj = 1:24
        fprintf(fid,'%s%d\t',ii{:},jj);
    end
end

fseek(fid,-1,0); % move back one posistion
fprintf(fid,'\n'); % print 'newline' instead of 'tab'

return
