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


function list_subject_games_data_ver3( varargin )

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
%Make seperate results to feed into function below for NP2 tasks
results2.iowa  = false(size(id_nums));
results2.reversal  = false(size(id_nums));
results2.cantab  = false(size(id_nums));


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

% iowa
load([pathroot 'analysis/iowa/data/iowa_data.mat']);
results2.iowa = ismember(results.id,[iowa_struct.id]);

% reversal
load([pathroot 'analysis/reversal/data/rev_data.mat']);
results2.reversal = ismember(results.id,[rev_struct.ID]);

% cantab
[~,~,raw]=xlsread([pathroot 'analysis/cantab/file_out_test4_new.xls']);
results2.cantab = ismember(results.id,[raw{2:end,1}]');

% write it to a table
writeToTeX(results,dry_run_flag,results2);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function writeToTeX(data,emode,data2)

% Until I think of a better solution to this...or not
load([pathroot 'analysis/trust game/data/trust_data.mat']);


%So maybe talk to Josh to replace the initials in the main demog file but
%until then just import them via the SQL code you worte, ie SQL -> xls ->
%matlab 3/13/15 this might be obsolete!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SQL = SELECT [splash demo 2].ID, UCase(Left([fname],1) & "." & " " & Left([lname],3)) AS Initials FROM [splash demo 2] LEFT JOIN M_PERSONAL ON [splash demo 2].ID = M_PERSONAL.ID;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [~,~,ids_and_ints] = xlsread('c:\kod\Neuropsych_preproc\matlab\tmp\IDS_AND_INITIALS.xlsx');
% 
% [~, ia, ic] = unique(cell2mat(ids_and_ints(2:end,1)),'rows'); %start at two because of header possible just remove this...
% 
% m.id_number = cell2mat(ids_and_ints((ia + 1))); %Dont grab header
% m.initials = ids_and_ints((ia + 1),2);

m = loadAllids;
ids = unique(m.id_number(m.id_number ~= 999999)); % silly bug (not on our end)-- Don't think is an issue anymo

% wierd #Error for m.initials contingency -- Don't think is an issue anymo
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
fprintf(fid,'Data list last updated: Feb 29, 2016\n\n');
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

%Data is no longer used combine data1 and data2 ie NP3 and NP2, since NP2
%cannot fit on the pdf at this point (landscape in the future?)

%Because we need an access table with NP games
pairs = [fieldnames(data) struct2cell(data); fieldnames(data2) struct2cell(data2)]';
data = struct(pairs{:});
data_names = fieldnames(data);
id_len = length(data.id);
for i = 1:length(data_names)
    data_for_excel(1,i) = data_names(i);
    data_for_excel(2:id_len+1,i) = num2cell(double(data.(data_names{i})(:))); %Binary seem more readable than logical
end
xlswrite('NP_data_for_Josh', data_for_excel);


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

fclose all;

return
