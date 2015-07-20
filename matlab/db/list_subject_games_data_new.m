% The aim of this script is to output a LaTeX file which will display 
% who has what data.
%
% Jan Kalkus
% 2012-09-04
%
% Jan Kalkus
% 2013-11-12: updated to read IDs from processed data. This will change
%             again in the future once all the processing streams are
%             more standardized. 
% Jon Wison
% 2014-16-14: updated to read in trust game data


function list_subject_games_data_new( varargin )

% exec./debug mode
if(strcmpi('test',varargin))
    dry_run_flag = true;
else
    dry_run_flag = false;
end

% load stuff
m = loadAllids('refresh');
id_nums = unique(m.id_number);
id_nums = id_nums(id_nums ~= 999999); % silly bug (not on our end)

% pre-allocate memory
results.id         = id_nums;
results.bandit     = false(size(id_nums));
results.bart       = false(size(id_nums)); 
results.ultimatum  = false(size(id_nums));
results.willtowait = false(size(id_nums));
results.trustgame  = false(size(id_nums));

% bart 
load([pathroot 'analysis/bart/data/bart_data.mat']);
results.bart = ismember(results.id,bart_struct.id);

% bandit
load([pathroot 'analysis/bandit/data/bandit_data.mat']);
results.bandit = ismember(results.id,ball.id);

% ultimatum
load([pathroot 'analysis/ultimatum/data/UGsummary_data/ball.mat']);
results.ultimatum = ismember(results.id,ball.id);

% willingness to wait
load([pathroot 'analysis/willingness to wait/data/wtw_data.mat']);
results.willtowait = ismember(results.id,[wtw_struct.id]);

% trust game -Not Ready
load([pathroot 'analysis/trust game/data/trust_data.mat']);
results.trustgame = ismember(results.id,[tg_struct.id]);

% write it to a table
writeToTeX(results,dry_run_flag);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function writeToTeX(data,emode)

% Until I think of a better solution to this...or not
load([pathroot 'analysis/trust game/data/trust_data.mat']);

m = loadAllids;
ids = unique(m.id_number(m.id_number ~= 999999)); % silly bug (not on our end)

% wierd #Error for m.initials contingency
bad_ids = ismember(m.initials,'#Error');
m.initials(bad_ids)={''};

% open file
fid = 1;
if(~emode), fid = fopen([pathroot 'doc/who_has_games.tex'],'w'); end

% print header/preamble
fprintf(fid,'\\documentclass{article}\n');
fprintf(fid,'\\usepackage{amsmath,amssymb,latexsym,fullpage,longtable,arydshln}\n');
fprintf(fid,'\n\\begin{document}\n\n');

% print some info
fprintf(fid,'Data list last updated: September 17, 2014\n\n');
fprintf(fid,'\\LaTeX\\ file compiled on: \n\\today');

% print table stuff
fprintf(fid,'\\begin{center}\n\t\\renewcommand{\\tabcolsep}{0.12cm}\n\t');
fprintf(fid,'\\begin{longtable}{ccccccp{11mm}c}\n\n');
fprintf(fid,'\t\t& & & & & & \\textbf{Trust} & \\textbf{Game} \\\\\n');
fprintf(fid,'\t\t\\textbf{Subject N\\textsuperscript{o}}\t&\t');
fprintf(fid,'\\textbf{Initials}\t&\t');
fprintf(fid,'\\textbf{3 Armed Bandit}\t&\t');
fprintf(fid,'\\textbf{BART}\t&\t');
fprintf(fid,'\\textbf{Ultimatum Game}\t&\t');
fprintf(fid,'\\textbf{Willingness to Wait}\t&\t');
fprintf(fid,'\\text{Behav.$\\vert$}\t&\t\\text{Scanned} \\\\\n');
fprintf(fid,'\t\t\\multicolumn{2}{c}{N = %d} \t & N = %d \t & N = %d \t & N = %d \t & N = %d \t & N = %d \\\\ \\hline\n', ...
    numel(ids),sum(data.bandit),sum(data.bart),sum(data.ultimatum),sum(data.willtowait),sum(data.trustgame));
fprintf(fid,'\t\t\\endfirsthead\n\n');

fprintf(fid,'\t\t\\textbf{Subject N\\textsuperscript{o}}\t&\t');
fprintf(fid,'\\textbf{Initials}\t&\t');
fprintf(fid,'\\textbf{3 Armed Bandit}\t&\t');
fprintf(fid,'\\textbf{BART}\t&\t');
fprintf(fid,'\\textbf{Ultimatum Game}\t&\t');
fprintf(fid,'\\textbf{Willingness to Wait}\t&\t');
fprintf(fid,'\\textbf{Beahv.$\\vert$Scanned} \\\\ \\hline\n');
fprintf(fid,'\t\t\\endhead\n\n');

fprintf(fid,'\t\t\\multicolumn{6}{c}{{Continued on next page\\ldots}}\n');
fprintf(fid,'\t\t\\endfoot\n\n');

fprintf(fid,'\t\t\\hline\n\t\t\\endlastfoot\n\n');

% business time
for ni = 1:numel(data.id)
    
    id_num = data.id(ni);
    
    fprintf(fid,'\t\t'); % line indentation
    fprintf(fid,'%d\t & \t',id_num); % ID number

	if(id_num == 29601) % deal (not elegantly) with some funky char business
		fprintf(fid,'%s\t & \t','D.D''A');
	else
		fprintf(fid,'%s\t & \t',m.initials{find(m.id_number == id_num,1,'first')}); % initials
	end
    
    % individual assessments

	if(0)
	%------ NOT READY YET ------
		task_names = fieldnames(data);

		for n_task = 2:numel(task_fields)
			if(data.(task_names{n_task}))
				s.(task_names{n_task}) = sprintf('\\checkmark');
			else
				s.(task_names{n_task}) = '';
			end
		end
	%------ NOT READY YET ------
	end
			

    if(data.bandit(ni))
        s.bandit = sprintf('\\checkmark');
    else
        s.bandit = '';
    end
    
    if(data.bart(ni))
        s.bart = sprintf('\\checkmark');
    else
        s.bart = '';
    end
    
    if(data.ultimatum(ni))
        s.ultim = sprintf('\\checkmark');
    else
        s.ultim = '';
    end
    
    if(data.willtowait(ni))
        s.willin = sprintf('\\checkmark');
    else
        s.willin = '';
    end
    
   %MAKE trust game preproc then come back here...
   if(data.trustgame(ni))
       ind=find(tg_struct.id==id_num);
        if strcmp(tg_struct.versn(ind),'scanner/laptop') || strcmp(tg_struct.versn(ind),'laptop/scanner')
            s.trust = sprintf('\\hspace{3.3mm} \\checkmark & \\checkmark');
        elseif strcmp(tg_struct.versn(ind),'laptop')
            s.trust = sprintf('\\hspace{3mm} \\checkmark &');
        else
           s.trust = sprintf(' & \\checkmark');
        end
   else
      s.trust = ' &  ';
   end
    
    % write line 
    fprintf(fid,'%s\t & \t%s\t & \t%s\t & \t%s\t & \t%s  \\\\ \\hdashline[1pt/2pt]\n',s.bandit,s.bart,s.ultim,s.willin,s.trust);
    
end

% close up the table
fprintf(fid,'\t\\end{longtable}\n\\end{center}\n\n');

if(0)
    %------ NOT READY YET ------
    % add some summary data
    fprintf(fid,'\\begin{center}\n\t\\begin{tabular}{ccccc}\n');
    fprintf(fid,'\t\tControls & Depressed & Ideators & Attempters & Other \\\\\n\t\t');
    group_id = {'CONTROL' 'DEPRESSION' '^IDEATOR' 'ATTEMPTER' '^OTHER$'};
    for ci = 1:numel(group_id)

        % get inds for each group
        c = sum(cell2mat(regexp(m.comment,group_id{ci})));
        fprintf(fid,'%d',c);

        if(eq(ci,numel(group_id)))
            fprintf(fid,' \n');
        else
            fprintf(fid,' & ');
        end

    end

    % close the table
    fprintf(fid,'\t\\end{tabular}\n\\end{center}\n\n');
    %------ NOT READY YET ------
end

% end the document
fprintf(fid,'\\end{document}');

% kill it
if(~emode)
    fclose(fid);
end

return
