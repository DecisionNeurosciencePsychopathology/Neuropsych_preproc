function c = UGproceprime(id)
% /* This is a subfunction called by the function 'UGprocprimeALL' */ // H.
% 
% process behavioral data from the Ultimatum Game
% more details at: http://bit.ly/HvBdby // H.

% Find the eprime file 
fpath_root = 'data/raw/';
flist = dir([fpath_root sprintf('%d/',id) '*.txt']); % 'readeprime' reads text 
fname = [fpath_root sprintf('%d/',id) flist.name]; % full path to file (no 'cd')

% read in the e-prime file data (replaces former 'readeprime' function)
a = eprimeread(fname,'TrialProc1',{'Condition','Offer.RT','Offer.ACC','Offer'},0,-1,20);

% parse offer and stake size data present in stimuli filenames
str_parse = cellfun(@(s) sscanf(s,'%*2s_%gof%g.bmp'),a.Offer,'UniformOutput',0);

%Grab dsate Ult game was administered
filetext = fileread(fname);
expr=('[0-9]{2}-[0-9]{2}-[0-9]{4}');
admin_date = regexp(filetext,expr,'match','once');

% start organizing
b.id         = id;
formatOut = 'mm/dd/yy';
b.admin_date = datestr(datetime(admin_date,'InputFormat', 'MM-dd-yyyy'),formatOut); %Oh matlab the hoops you must jump through...
b.RT         = a.Offer_RT;
b.accept     = logical(a.Offer_ACC);
b.offer_size = cellfun(@(a) a(1), str_parse);
b.stake_size = cellfun(@(a) a(2), str_parse);

% store conditions by trial 
% NOTE: the older 'readeprime' included an extra space in some
% of the labels (e.g., ' BH', ' BL'); the newer 'eprimeread'
% eliminates these, so corresponding changes have been made to
% this function.
b.cond.hi       = strcmp('BH', a.Condition); % what exactly does "BH" stand for?
b.cond.lo       = strcmp('BL', a.Condition); % B = medium fairness?
b.cond.unfairhi = strcmp('UH', a.Condition);
b.cond.unfairlo = strcmp('UL', a.Condition);
b.cond.fairhi   = strcmp('FH', a.Condition);
b.cond.fairlo   = strcmp('FL', a.Condition);

unfair = (b.cond.unfairhi | b.cond.unfairlo);
med    = (      b.cond.hi | b.cond.lo      );
fair   = (  b.cond.fairhi | b.cond.fairlo  );

b.fairness = unfair+2.*med+3.*fair; % is this math right?
%b.fairness = (unfair+2).*(med+3).*(fair); % <-- same result as prev line?
b.hi = (b.cond.fairhi | b.cond.unfairhi | b.cond.hi); % how is this any different from 'b.cond.hi'?

% calculate rejection rates for each level of fairness and stake size
b.rejrate.fairhi   = (sum(~b.accept & b.cond.fairhi)./sum(b.cond.fairhi));
b.rejrate.fairlo   = (sum(~b.accept & b.cond.fairlo)./sum(b.cond.fairlo));
b.rejrate.medhi    = (sum(~b.accept & b.cond.hi)./sum(b.cond.hi));
b.rejrate.medlo    = (sum(~b.accept & b.cond.lo)./sum(b.cond.lo));
b.rejrate.unfairhi = (sum(~b.accept & b.cond.unfairhi)./sum(b.cond.unfairhi));
b.rejrate.unfairlo = (sum(~b.accept & b.cond.unfairlo)./sum(b.cond.unfairlo));
b.rejrate.total    = (sum(~b.accept)/length(b.accept));

% stats., etc.
b.specs.median.RTfairhi   = median(b.RT(b.cond.fairhi));
b.specs.median.RTfairlo   = median(b.RT(b.cond.fairlo));
b.specs.median.RTmedhi    = median(b.RT(b.cond.hi));
b.specs.median.RTmedlo    = median(b.RT(b.cond.lo));
b.specs.median.RTunfairhi = median(b.RT(b.cond.unfairhi));
b.specs.median.RTunfairlo = median(b.RT(b.cond.unfairlo));

% other
b.specs.raw.file_name  = fname;
b.specs.raw.conditions = a.Condition;

n = 0;
n=n+1; b.fields{n,1} = '        id:   subject ID number                   ';
n=n+1; b.fields{n,1} = '        RT:   reaction times by trial             ';
n=n+1; b.fields{n,1} = '    accept:   did subject accept offer (per trial)';
n=n+1; b.fields{n,1} = 'offer_size:   dollar value offered from stake     ';
n=n+1; b.fields{n,1} = 'stake_size:   dollar value of stake               ';
n=n+1; b.fields{n,1} = '      cond:   conditions per trial                ';
n=n+1; b.fields{n,1} = '  fairness:   per trial fairness index            ';
n=n+1; b.fields{n,1} = '        hi:   not entirely sure...                ';
n=n+1; b.fields{n,1} = '   rejrate:   rejection-rate per condition        ';
n=n+1; b.fields{n,1} = '     specs:   various extra variables and datum   ';

% save data
proc_data_path = [pathroot 'analysis/ultimatum/data/'];
save([proc_data_path sprintf('UG%d',id)],'b'); % save only 'b' struct

% do not return if not requested
if(nargout > 0)
	c = b;
end

return
