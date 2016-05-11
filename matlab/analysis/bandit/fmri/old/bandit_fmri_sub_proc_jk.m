%
%
% Jan Kalkus
% 13 Nov 2012

function [b,tmp_reg] = bandit_fmri_sub_proc_jk( varargin )
% process behavioral data from variable-schedule 3-armed bandit task
% more details at: http://bit.ly/HvBdby

%  --  parse 'varargin' arguments  --  %
id = varargin{ find(strcmp('id',varargin))+1 };

%  --  get the data  --  %
fprintf('reading in data...\n');
a = readinRawData(id);

% -- organize structure and clean up vars -- %
fprintf('matching data to appropriate fields...\n');
b = convertAstructToBstruct(a);

% -- add stimulus chosen and its position to structure -- %
design_struct = bandit_fmri_load_design; % load design file

b.chosen_stim = cell(numel(design_struct.Procedure),1); % pre-allocate

b.chosen_stim(b.stim_RESP == 7) = design_struct.topstim(b.stim_RESP == 7); 
b.chosen_stim(b.stim_RESP == 2) = design_struct.leftstim(b.stim_RESP == 2); 
b.chosen_stim(b.stim_RESP == 3) = design_struct.rightstim(b.stim_RESP == 3); 

% recode chars as stim IDs
q = ~cellfun(@isempty,b.chosen_stim);
tmp(q') = cellfun(@(c) cast(c,'double')-64, b.chosen_stim(q));
tmp(~q) = 999; % missed answers coded as 999
b.chosen_stim = tmp;

% -- code for stimulus choice switches -- %
b.stim_switch = zeros(numel(b.chosen_stim),1);
for n = 2:numel(b.stim_switch)
    last_stim    = b.chosen_stim(n-1);
    current_stim = b.chosen_stim(n);
    b.stim_switch(n) = ne(last_stim,current_stim);
end

% -- code choice switches on the next trial
b.next_switch = [b.stim_switch(2:end); 0];

% remove the 'break' trial types
q_to_fix  = ( structfun(@numel,b) == numel(b.protocol_type) );
q_to_keep = ~cellfun(@isempty,b.protocol_type);
b_fnames = fieldnames(b);
for n = 1:length(b_fnames)
    if(q_to_fix(n))
        b.(b_fnames{n}) = b.(b_fnames{n})(q_to_keep);
    end
end

% code missed responses
b.missed_responses = ( b.stim_RT == 0 );

% code onset of the next trial
b.stim_NextOnsetTime=[b.stim_OnsetTime(2:300); b.stim_RTTime(300)];

% -- make regressors --
tr = 0.1; % 10 Hz
hemoir = spm_hrf(tr, [6,16,1,1,6,0,32]); % better than resampling and smoothing 

fprintf('computing regressors...\n');
frequency_scale_hz = 10;
feedback_end = 400;
x = [1:100;101:200;201:300];
for block_n = 1:3
    % this scale is in msec, but it is separated into bins of X
    % Hz (defined by 'frequency_scale' above. the resulting
    % output will be in the scale of X Hz.
    bin_size = 1/frequency_scale_hz*1000; % convert Hz to msec
    epoch_window = b.stim_OnsetTime(x(block_n,1)):bin_size:b.stim_OnsetTime(x(block_n,1))+694000;
    
    % for RTs
    event_beg = b.stim_OnsetTime(x(block_n,:)); event_end = b.stim_RTTime(x(block_n,:));
    tmp_reg.(['regressors' num2str(block_n)]).RT = ...
        createSimpleRegressor(event_beg,event_end,epoch_window);
    
    % choice -- after stimulus presentation
    event_beg = b.stim_OnsetTime(x(block_n,:)); event_end = event_beg + 500;
    tmp_reg.(['regressors' num2str(block_n)]).choice = ...
        createSimpleRegressor(event_beg,event_end,epoch_window);
    
    % for feedback
    event_beg = b.feedback_OnsetTime(x(block_n,:)); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).feedback = ...
        createSimpleRegressor(event_beg,event_end,epoch_window);
    
    
    % convolve switch regressor with RT
    event_beg = b.stim_OnsetTime(x(block_n,:)); event_end = b.stim_OffsetTime(x(block_n,:));
    tmp_reg.(['regressors' num2str(block_n)]).switch_RT = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.stim_switch(x(block_n,:)));
    
    % convolve next switch regressor with feedback
    event_beg = b.feedback_OnsetTime(x(block_n,:)); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).switch_feedback = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.next_switch(x(block_n,:)));
    
    % convolve error regressor with feedback
    event_beg = b.feedback_OnsetTime(x(block_n,:)); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).error_feedback = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,~b.stim_ACC(x(block_n,:)));
    
    % make an error>correct regressor convolved with feedback
    event_beg = b.feedback_OnsetTime(x(block_n,:)); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).error2correct1 = ...
        1 + createSimpleRegressor(event_beg,event_end,epoch_window,(~b.stim_ACC(x(block_n,:))));
        
     % make choice and switch regressors, non-RT-convolved
    event_beg = b.stim_OnsetTime(x(block_n,:)); event_end = event_beg + 500;
    tmp_reg.(['regressors' num2str(block_n)]).switch_choice = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.stim_switch(x(block_n,:)));
    
    % convolve correct regressor with feedback
    event_beg = b.feedback_OnsetTime(x(block_n,:)); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).correct_feedback = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.stim_ACC(x(block_n,:)));
    
    % regressor for missed responses
    event_beg = b.stim_OnsetTime(x(block_n,:)); event_end = b.stim_NextOnsetTime(x(block_n,:));
    tmp_reg.(['regressors' num2str(block_n)]).to_censor = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.missed_responses(x(block_n,:)));
    
    % - - -
    % regressor for jitter between RT and feedback
    event_beg = b.stim_RT(x(block_n,:)); event_end = b.feedback_OnsetTime(x(block_n,:));
    tmp_reg.(['regressors' num2str(block_n)]).rew_expect = ...
        createSimpleRegressor(event_beg,event_end,epoch_window);
        
    % - - -
    
    % create regressors for "actions"
    event_beg = b.stim_RTTime(x(block_n,:))-200; event_end = b.stim_RTTime(x(block_n,:));
    for n_stim = [2 3 7]
        
        q_stim_id = ( b.stim_RESP(x(block_n,:)) == n_stim );
        tmp_reg.(['regressors' num2str(block_n)]).(['action_' num2str(n_stim)])(:,1) = ...
            createSimpleRegressor(event_beg,event_end,epoch_window,q_stim_id);
        
    end

    % Faux expected value regressor -- with stim. onset
    % NB: when looking at the time of choice, we use the EV estimate from
    % the previous trial
    b.fauxEV = alexcausfilt(b.stim_ACC);
    b.fauxEVt = [0 b.fauxEV(1:end-1)];
    event_beg = b.stim_OnsetTime(x(block_n,:)); event_end = b.stim_RTTime(x(block_n,:));
    tmp_reg.(['regressors' num2str(block_n)]).fauxEV_RT(:,1) = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.fauxEVt(x(block_n,:)));
    
    event_beg = b.stim_OnsetTime(x(block_n,:)); event_end = b.stim_OnsetTime(x(block_n,:))+200;
    tmp_reg.(['regressors' num2str(block_n)]).fauxEV_stim_onset(:,1) = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.fauxEVt(x(block_n,:)));
    
    % Faux expected value regressos -- with feedback
    % NB: when looking at the feedback time window, we use the EV estimate that integrates
    % the current trial
    event_beg = b.feedback_OnsetTime(x(block_n,:)); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).faux_EV_feedback(:,1) = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.fauxEV(x(block_n,:))); 
    
    
    % Faux prediction error -- with feedback
    b.fauxPE = b.stim_ACC - [0 alexcausfilt(b.stim_ACC(1:end-1))]';
    event_beg = b.feedback_OffsetTime(x(block_n,:)); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).fauxPE(:,1) = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.fauxPE(x(block_n,:)));
    
    
    % HRF-convolve all the event regressors
    hrfregs = fieldnames(rmfield(tmp_reg.regressors1,'to_censor'));
    for n = 1:numel(hrfregs)
        % b.hrfreg1.RT
        tmp_reg.(['hrfreg' num2str(block_n)]).(hrfregs{n}) = ...
            conv(1*tmp_reg.(['regressors' num2str(block_n)]).(hrfregs{n}),hemoir);
        
        % cut off the tail after convolution and downsample
        tmp = gsresample(tmp_reg.(['hrfreg' num2str(block_n)]).(hrfregs{n}),10,.5);
        tmp_reg.(['hrfreg' num2str(block_n)]).(hrfregs{n}) = tmp(1:347);
    end
    
    % shift the tocensor regressor by the HRF lag = 5 seconds
    tmp_reg.(['hrfreg' num2str(block_n)]).to_censor = ...
        gsresample( ...
            [zeros(50,1)' tmp_reg.(['regressors' num2str(block_n)]).to_censor(1:end-51)], ...
        10,.5);
    
end

% - - -
% regressor for expected value
% at stake 
b.value_at_stake = zeros(size(b.protocol_type));

q_half   = ~cellfun(@isempty,strfind(b.protocol_type,'half'));
q_normal = ~cellfun(@isempty,strfind(b.protocol_type,'norm'));
q_double = ~cellfun(@isempty,strfind(b.protocol_type,'double'));

b.rew_at_stake(q_half)   = 0.10;
b.rew_at_stake(q_normal) = 0.20;
b.rew_at_stake(q_double) = 0.50;

% received
b.rew_received = zeros(size(b.value_at_stake));
b.rew_received = b.value_at_stake .* b.stim_ACC;
% - - -

% convolve correct regressor with feedback
exp_duration = 694*1000*3; % 694 secs. per block, convert to msec., x3 blocks
epoch_window = b.stim_OnsetTime(1):bin_size:b.stim_OnsetTime(1) + exp_duration;
event_beg = b.feedback_OnsetTime; 
event_end = event_beg+feedback_end;
catted_block.correct_feedback = createAndCatRegs(event_beg,event_end,epoch_window,b.stim_ACC);


% concatenate HRF convolved variables
fnm = fieldnames(tmp_reg.regressors1)';
for ct=1:length(fnm)
    b.hrf_regs.(fnm{ct}) = [tmp_reg.hrfreg1.(fnm{ct}) tmp_reg.hrfreg2.(fnm{ct}) tmp_reg.hrfreg3.(fnm{ct})];
end

% flip and round to_censor for AFNI 1=analyze, 0=censor
b.hrf_regs.to_censor = 1-(ceil(b.hrf_regs.to_censor));


% save individual file
save(sprintf([pathroot 'analysis/bandit/fmri/data/%d.mat'],id),'b');
% save(sprintf('C:/regs/bandit%d.mat',id),'b');
% 
% cd('C:\regs')
% gdlmwrite(sprintf('bandit%d.regs',id),[b.hrf_regs.to_censor' ... %0 trials with responses
%     b.hrf_regs.RT' b.hrf_regs.feedback' ... % 1 RT    2 feedback
%     b.hrf_regs.switch_RT'... %3 switch convolved with RT window
%     b.hrf_regs.error_feedback' ...%4 error convolved with feedback window
%     b.hrf_regs.correct_feedback' ...%5 correct convolved with feedback window
%     b.hrf_regs.action_2' ...%6 right index 
%     b.hrf_regs.action_3' ...%7 right middle
%     b.hrf_regs.action_7' ...%8 left index 
%     b.hrf_regs.error2correct1' ...%9 error=2, correct=1
%     b.hrf_regs.choice' ...%10 "choice" - 500ms following stimulus presentation
%     b.hrf_regs.switch_choice' ...%11 switch convolved with "choice" - 500ms following stimulus presentation
%     b.hrf_regs.switch_feedback' ...%12 switch convolved with feedback
%     b.hrf_regs.faux_EV_feedback' ...%13 estimated EV at feedback
%     b.hrf_regs.fauxPE' ...%14 estimated PE at feedback       
% ],'\t');

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function data_out = readinRawData(id_number)

% This experiment's output is not as straight-forward. You'll
% need to run an instance of 'eprimeread' for each row below (at
% minimum).
%
% Procedure     stimulus prefix         response prefix
% ---------------------------------------------------------------
% halfproc:     showstimhalf.*          FeedbackHalf.*
% normalproc:   showstimnormal.*        FeedbackNormal.*
% doubleproc:   showstimdouble.*        FeedbackDouble.*
%
% comphalf:     computerplayblank.*     FeedbackRepeatedHalf.*
% compnorm:     computerplayblank.*     FeedbackRepeatedNorm.*
% compdouble:   computerplayblank.*     FeedbackRepeatedDouble.*
%
% mystnorm:     mystery.*               FeedbackMystery.*


procs.names = {'halfproc','normalproc','doubleproc', ...
    'comphalf','compnorm','compdouble', ...
    'mystnorm'};

n = 0;
n = n+1; procs.prefixes{n} = {'showstimhalf','FeedbackHalf'};
n = n+1; procs.prefixes{n} = {'showstimnormal','FeedbackNormal'};
n = n+1; procs.prefixes{n} = {'showstimdouble','FeedbackDouble'};
n = n+1; procs.prefixes{n} = {'computerplayblank','FeedbackRepeatedHalf'};
n = n+1; procs.prefixes{n} = {'computerplayblank','FeedbackRepeatedNorm'};
n = n+1; procs.prefixes{n} = {'computerplayblank','FeedbackRepeatedDouble'};
n = n+1; procs.prefixes{n} = {'mystery','FeedbackMystery'};

procs.suffixes.stim   = {'OnsetTime','OffsetTime','RT','RTTime','RESP','CRESP','ACC'};
procs.suffixes.feedbk = {'OnsetDelay','OnsetTime','OffsetTime'};

for n_proc = 1:numel(procs.names)
    get_vars = {};
    
    for n_stim_suffix = 1:numel(procs.suffixes.stim)
        tmp = sprintf('%s.%s',procs.prefixes{n_proc}{1},procs.suffixes.stim{n_stim_suffix});
        get_vars(end+1) = {tmp};
    end
    
    for n_fb_suffix = 1:numel(procs.suffixes.feedbk)
        tmp = sprintf('%s.%s',procs.prefixes{n_proc}{2},procs.suffixes.feedbk{n_fb_suffix});
        get_vars(end+1) = {tmp};
    end
    
    % this variable keeps track of trial numbers
    get_vars{end+1} = 'stimlist';
    get_vars{end+1} = 'jitter1'; get_vars{end+1} = 'jitter2';
    
    data_out.(procs.names{n_proc}) = getfmriData(id_number,get_vars,procs.names{n_proc});
    data_out.(procs.names{n_proc}).showstim_jitter1 = data_out.(procs.names{n_proc}).jitter1;
    data_out.(procs.names{n_proc}).showstim_jitter2 = data_out.(procs.names{n_proc}).jitter2;
    data_out.(procs.names{n_proc}) = rmfield(data_out.(procs.names{n_proc}),{'jitter1','jitter2'});
    
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function xout = getfmriData(id,vars,procedure)
% reads eprime data for a given bandit subject based on ID

% Find the eprime file
data_dir  = [pathroot 'analysis/bandit/fmri/data/raw/'];
file_name = ls([data_dir sprintf('%d/*.txt',id)]);
fpath     = @(~) [pathroot sprintf('analysis/bandit/fmri/data/raw/%d/%s',id,file_name)];

% read in the data (make sure range to search raw text is correct)
xout = eprimeread(fpath(),procedure,vars,0,-13,18);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function B_struct = convertAstructToBstruct( A_struct )

% prepare structure for storage
n_trials = maximumTrialNum(A_struct,'stimlist'); % get maximum number of trials in experiment
B_struct = preallocateStruct(fieldnames(rmfield(A_struct.halfproc,{'fname','stimlist'})),n_trials);

% some by-hand pre-allocations/assignements
B_struct.fname = A_struct.halfproc.fname; % carry over the filename
B_struct.protocol_type = cell(n_trials,1); % preallocate space for keeping track of trial type

for n = fieldnames(A_struct)'
    for m = fieldnames(rmfield(A_struct.(n{:}),{'fname','stimlist'}))'
        % grab trial number index for given "protocol"
        q_trial_index = A_struct.(n{:}).stimlist;
        
        % now we need to match current fieldnames in the
        % structure (b) with variable names of read-in data
        new_fieldname = matchDataToField(fieldnames(rmfield(B_struct,{'fname','protocol_type'})),m);
        
        % not all protocols' variables overlap, leading to empty
        % arrays/cell arrays -- we need to convert them to arrays
        % of NaNs if they're found. (if a variable is missing for
        % a given protocol, that will result in an empty cell
        % array -- just check for a cell array.)
        tmp = A_struct.(n{:}).(m{:}); % get the array
        if(iscell(tmp)), tmp = nan(size(tmp)); end
        
        % store into new structure
        B_struct.(new_fieldname)(q_trial_index) = tmp;
        
        % store the type of trial
        B_struct.protocol_type(q_trial_index) = n(:);
    end
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function nmax = maximumTrialNum(a_secondary_structure,target_fieldname)
% by secondary structure, I mean something like the following:
% (there may be an actual term for this. I am unaware of it.)
% the "secondary" fieldname (target_fieldname) must be consistent
%
% root          // root
%    .foo_ax    // primary
%        .bar   // secondary
%    .foo_by
%        .bar

nmax = 0;
for n = fieldnames(a_secondary_structure)'
    nmax = max([ nmax; a_secondary_structure.(n{:}).(target_fieldname) ]);
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function sout = preallocateStruct(fieldnames_to_trim,n_trials)
% this function takes the 'a' structure and uses it to make and
% preallocate memory for the final data structure
%
% instead of simply trimming off all of the fieldname before the
% underscore, you must parse which are stimulus and feedback
% related variables

for n = fieldnames_to_trim'
    % set index
    q = strfind(n{:},'_')+1;
    if(isempty(q))
        q = 1;
        prefix = [];
    elseif(regexp(n{:},'Feedback'))
        prefix = 'feedback';
    else
        prefix = 'stim';
    end
    
    new_fieldname = [prefix '_' n{:}(q:end)];
    sout.(new_fieldname) = nan(n_trials,1);
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function matched_struc_fieldname = matchDataToField(struct_fieldnames,in_var)

if(iscell(in_var)), in_var = cell2mat(in_var); end % convert to string

% preallocate and preset variables
fieldname_parts   = regexp(struct_fieldnames,'_','split');
bool_is_match     = false(size(struct_fieldnames));
front_matches     = bool_is_match;
back_matches      = bool_is_match;

for q_index = 1:numel(struct_fieldnames)
    
    front_chunk = fieldname_parts{q_index}{1};
    back_chunk  = fieldname_parts{q_index}{2};
    
    % function handle because I'm lazy (case insensitive)
    matchVarName = @(s) ~isempty(strfind(lower(in_var),lower( s )));
    
    % check if front chunk matches anything in the variable name
    front_matches(q_index) = matchVarName(front_chunk);
    if(~front_matches(q_index))
        odd_man_out = ( matchVarName('mystery') | matchVarName('computer') );
        if(odd_man_out && strcmp(front_chunk,'stim') && ~matchVarName('feedback'))
            front_matches(q_index) = true;
        end
    end
    
    % check if the back chunk matches
    back_matches(q_index) = ~isempty(regexp(in_var,['_' back_chunk '$'],'once'));
    
    % see which fieldname is a match with the variable
    bool_is_match(q_index) = ( front_matches(q_index) & back_matches(q_index) );
    
end

% make sure there is only one match, otherwise we have a problem
if(sum(bool_is_match) > 1)
    % if there are multiple matches...
    keyboard
else
    matched_struc_fieldname = struct_fieldnames{bool_is_match};
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function foo = createSimpleRegressor(event_begin,event_end,epoch_window,conditional_trials)

% TODO: incorporate concatenation of different blocks in this function (maybe?)

% check if optional censoring variable was used
if(~exist('conditional_trials','var') || isempty(conditional_trials))
    conditional_trials = true(length(event_begin),1);
elseif(~islogical(conditional_trials))
    % needs to be logical format to index cells
    conditional_trials = logical(conditional_trials);
end

% create epoch windows for each trial
epoch = arrayfun(@(a,b) a:b,event_begin,event_end,'UniformOutput',false);

% for each "epoch" (array of event_begin -> event_end), count events
per_event_histcs = cellfun(@(h) histc(h,epoch_window),epoch(conditional_trials),'UniformOutput',false);
foo = logical(sum(cell2mat(per_event_histcs),1));

% createAndCatRegs(event_begin,event_end,epoch_window);

return


function catted_blocks = createAndCatRegs(e_beg,e_end,e_win,cond_trials)

% check if optional censoring variable was used
if(~exist('cond_trials','var') || isempty(cond_trials))
    cond_trials = true(length(event_begin),1);
elseif(~islogical(cond_trials))
    % needs to be logical format to index cells
    cond_trials = logical(cond_trials);
end

fh_q = @(x) ((x-1)*100)+1:x*100; % handy function handle for indexing
% e_win{1} = b.stim_OnsetTime(min(fh_q(1))):bin_size:b.stim_OnsetTime(fh_q(1))+694000;
%     epoch_window = b.stim_OnsetTime(x(block_n,1)):bin_size:b.stim_OnsetTime(x(block_n,1))+694000;

% execute as three blocks
catted_blocks = ( ...
    createSimpleRegressor(e_beg(fh_q(1)),e_end(fh_q(1)),e_win,cond_trials(fh_q(1))) + ...
    createSimpleRegressor(e_beg(fh_q(2)),e_end(fh_q(2)),e_win,cond_trials(fh_q(2))) + ...
    createSimpleRegressor(e_beg(fh_q(3)),e_end(fh_q(3)),e_win,cond_trials(fh_q(3)))  ...
);

return

