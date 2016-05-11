function q = UGproceprimeALL(spss_flag)

%processes all subjects' EPrime data on the Ultimatum Game
%convert all to ANSI before running

% check argin
if(~exist('spss_flag','var') || isempty(spss_flag))
	spss_flag = false;
end

% processes Ultimatum Game data on all subjects
%fpath_root = 'data/raw/';
data_dir = [pathroot 'analysis/ultimatum/data/']; % set data path


% get ID number from directory names
%data_dir = dir(data_dir);

%numlist = cell2mat(cellfun(@(s) sscanf(s,'%d'),{dir_list.name},'UniformOutput',false));
numlist = num_scan(dir([data_dir 'raw/']));

% get trial-by-trial data for GEE analysis
fprintf('processing id number:\n');
for sub=1:length(numlist)
    if(sub == 1)
        fprintf('\t   ID\t\tMean rej. dt.\t\tRT mean (\261STDEV)\n')
    end
	fprintf('\t %6d\t\t\t',numlist(sub));

    % load subject data
    s = UGproceprime(numlist(sub));
    
    % print some stats to screen
    fprintf('%3g%%\t\t\t %4.2g (\261%4.2g)\n', ...
        round((1-mean(s.accept))*100),mean(s.RT)/1000,std(s.RT)/1000);
    
    ball.trial(sub).accept     = s.accept;
    ball.trial(sub).fairness   = s.fairness; %1=unfair; 2=med, 3=fair
    ball.trial(sub).hi_stake   = s.hi; %1=hi, 0=lo
    ball.trial(sub).offer_size = s.offer_size; % dollar value of offer
    ball.trial(sub).stake_size = s.stake_size; % dollar value of stake
    
    %get behavior
    ball.id(sub)              = numlist(sub);
    ball.beh(sub).admin_date  = s.admin_date;
    ball.beh(sub).rrfairhi    = s.rejrate.fairhi;
    ball.beh(sub).rrfairlo    = s.rejrate.fairlo;
    ball.beh(sub).rrmediumhi  = s.rejrate.medhi;
    ball.beh(sub).rrmediumlo  = s.rejrate.medlo;
    ball.beh(sub).rrunfairhi  = s.rejrate.unfairhi;
    ball.beh(sub).rrunfairlo  = s.rejrate.unfairlo;
    ball.beh(sub).rrtotal     = s.rejrate.total;
    
    %get RTs
    ball.beh(sub).medianRTfairhi   = s.specs.median.RTfairhi;
    ball.beh(sub).medianRTfairlo   = s.specs.median.RTfairlo;
    ball.beh(sub).medianRTmeduimhi = s.specs.median.RTmedhi;
    ball.beh(sub).medianRTmediumlo = s.specs.median.RTmedlo;
    ball.beh(sub).medianRTunfairhi = s.specs.median.RTunfairhi;
    ball.beh(sub).medianRTunfairlo = s.specs.median.RTunfairlo;
    
    %concatenate into data table
    ball.data(sub,:) = [ball.id(sub), s.rejrate.total ... 
		s.rejrate.fairhi,   s.rejrate.fairlo, ... 
		s.rejrate.medhi,    s.rejrate.medlo , ...
		s.rejrate.unfairhi, s.rejrate.unfairlo ...
        s.specs.median.RTfairhi,   s.specs.median.RTfairlo, ...
		s.specs.median.RTmedhi,    s.specs.median.RTmedlo, ...
		s.specs.median.RTunfairhi, s.specs.median.RTunfairlo];
end

% save file
% Changed ball.dirname to ball_dirname
spath_root = 'data/';
ball_dirname = [spath_root 'UGsummary_data'];
save([ball_dirname '/ball'],'ball');

if(spss_flag)

	ball.variables={'id' 'rrtotal' 'rrfairhi' 'rrfairlo' 'rrmediumhi' 'rrmediumlo' 'rrunfairhi' 'rrunfairlo' ...
		'medianRTfairhi' 'medianRTfairlo' 'medianRTmediumhi' 'medianRTmediumlo' 'medianRTunfairhi' ...
		'medianRTunfairlo'};

	% add path for 'save4spss' function
    addpath('//oacres3/rcn/pican/studies/suicide/PRL analyses & papers/fMRImodelcode/');
	save4spss_alt(ball.variables, ball.data, [ball_dirname '/' ...
        sprintf('UG_data_SPSS')]);
		%sprintf('UG_data_N=%d_%s',length(numlist), date)]);
    
    fprintf('SPSS file saved in: %sUG_data_SPSS\n',[ball_dirname '/']);
	%fprintf('SPSS file saved in: %sUG_data_N=%d_%s\n',[ball_dirname '/'], ...
	%	length(numlist),date);
end

% varargout
if(nargout)
    q = ball;
end

return

function num_out = num_scan(data_in)

num_out = zeros(length(data_in),1);

for n = 1:length(data_in) %index_array %3:(length(A))-2
    num_out(n) = str2double(data_in(n).name); 
end

q_nan = isnan(num_out);
num_out = num_out(~q_nan);

return
