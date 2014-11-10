%
%
% Jan Kalkus
% 13 Nov 2012
%
% Jan Kalkus
% 2013-05-07: updated reading in of Eprime data; new task output is incongruent
% 			  former output and former processing streams.

function [b,tmp_reg] = bandit_fmri_sub_proc( varargin )
% process behavioral data from variable-schedule 3-armed bandit task
% more details at: http://bit.ly/HvBdby

%  --  parse 'varargin' arguments  --  %
id = varargin{ find(strcmp('id',varargin))+1 };

%  --  get the data  --  %
fprintf('reading in data...\n');
raw_struct = readInData(id);

% -- organize structure and clean up vars -- %
fprintf('matching data to appropriate fields...\n');
b = convertToWorkingStruct(raw_struct);
clear raw_struct; % hopefully this will mitigate memory problems






% -- make regressors --
tr = 0.1; % 10 Hz
hemoir = spm_hrf(tr, [6,16,1,1,6,0,32]); % better than resampling and smoothing 

fprintf('computing regressors...\n');
frequency_scale_hz = 10;
feedback_end = 400;
last_trial_num = numel(b.RT); % not all trials are always completed
x = {1:100;101:200;201:last_trial_num};
for block_n = 1:3
    % this scale is in msec, but it is separated into bins of X
    % Hz (defined by 'frequency_scale' above. the resulting
    % output will be in the scale of X Hz.
    bin_size = 1/frequency_scale_hz*1000; % convert Hz to msec
    epoch_window = b.stim_onset_time(x{block_n}(1)):bin_size:b.stim_onset_time(x{block_n}(1))+694000;
    
    % for RTs
    event_beg = b.stim_onset_time(x{block_n}); event_end = b.RT_time(x{block_n});
    tmp_reg.(['regressors' num2str(block_n)]).RT = ...
        createSimpleRegressor(event_beg,event_end,epoch_window);
    
    % choice -- after stimulus presentation
    event_beg = b.stim_onset_time(x{block_n}); event_end = event_beg + 500;
    tmp_reg.(['regressors' num2str(block_n)]).choice = ...
        createSimpleRegressor(event_beg,event_end,epoch_window);
    
    % for feedback
    event_beg = b.fb_onset_time(x{block_n}); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).feedback = ...
        createSimpleRegressor(event_beg,event_end,epoch_window);
    
    
    % convolve switch regressor with RT
    event_beg = b.stim_onset_time(x{block_n}); event_end = b.stim_offset_time(x{block_n});
    tmp_reg.(['regressors' num2str(block_n)]).switch_RT = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.stim_switch(x{block_n}));
    
    % convolve next switch regressor with feedback
    event_beg = b.fb_onset_time(x{block_n}); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).switch_feedback = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.next_switch(x{block_n}));
    
    % convolve error regressor with feedback
    event_beg = b.fb_onset_time(x{block_n}); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).error_feedback = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,~b.accuracy(x{block_n}));
    
    % make an error>correct regressor convolved with feedback
    event_beg = b.fb_onset_time(x{block_n}); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).error2correct1 = ...
        1 + createSimpleRegressor(event_beg,event_end,epoch_window,(~b.accuracy(x{block_n})));
        
     % make choice and switch regressors, non-RT-convolved
    event_beg = b.stim_onset_time(x{block_n}); event_end = event_beg + 500;
    tmp_reg.(['regressors' num2str(block_n)]).switch_choice = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.stim_switch(x{block_n}));
    
    % convolve correct regressor with feedback
    event_beg = b.fb_onset_time(x{block_n}); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).correct_feedback = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.accuracy(x{block_n}));
    
    % regressor for missed responses
    event_beg = b.stim_onset_time(x{block_n}); event_end = b.stim_NextOnsetTime(x{block_n});
    tmp_reg.(['regressors' num2str(block_n)]).to_censor = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.missed_responses(x{block_n}));
    
    % getting weird negative event durations
%     % - - -
%     % regressor for jitter between RT and feedback
%     event_beg = b.RT(x{block_n}); event_end = b.fb_onset_time(x{block_n});
%     tmp_reg.(['regressors' num2str(block_n)]).rew_expect = ...
%         createSimpleRegressor(event_beg,event_end,epoch_window);
%         
%     % - - -
    
    % create regressors for "actions"
    event_beg = b.RT_time(x{block_n})-200; event_end = b.RT_time(x{block_n});
    for n_stim = [2 3 7]
        
        q_stim_id = ( b.response(x{block_n}) == n_stim );
        tmp_reg.(['regressors' num2str(block_n)]).(['action_' num2str(n_stim)])(:,1) = ...
            createSimpleRegressor(event_beg,event_end,epoch_window,q_stim_id);
        
    end

    % Faux expected value regressor -- with stim. onset
    % NB: when looking at the time of choice, we use the EV estimate from
    % the previous trial
    b.fauxEV = alexcausfilt(b.accuracy);
    b.fauxEVt = [0 b.fauxEV(1:end-1)];
    event_beg = b.stim_onset_time(x{block_n}); event_end = b.RT_time(x{block_n});
    tmp_reg.(['regressors' num2str(block_n)]).fauxEV_RT(:,1) = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.fauxEVt(x{block_n}));
    
    event_beg = b.stim_onset_time(x{block_n}); event_end = b.stim_onset_time(x{block_n})+200;
    tmp_reg.(['regressors' num2str(block_n)]).fauxEV_stim_onset(:,1) = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.fauxEVt(x{block_n}));
    
    % Faux expected value regressos -- with feedback
    % NB: when looking at the feedback time window, we use the EV estimate that integrates
    % the current trial
    event_beg = b.fb_onset_time(x{block_n}); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).faux_EV_feedback(:,1) = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.fauxEV(x{block_n})); 
    
    
    % Faux prediction error -- with feedback
    b.fauxPE = b.accuracy - [0 alexcausfilt(b.accuracy(1:end-1))]';
    event_beg = b.fb_offset_time(x{block_n}); event_end = event_beg+feedback_end;
    tmp_reg.(['regressors' num2str(block_n)]).fauxPE(:,1) = ...
        createSimpleRegressor(event_beg,event_end,epoch_window,b.fauxPE(x{block_n}));
    
    % -- TD model regressor --
    % 1: get boxcar for choice --> feedback
    event_beg = b.RT_time(x{block_n}); event_end = b.fb_onset_time(x{block_n});
    main_body_boxcar = createSimpleRegressor(event_beg,event_end,epoch_window);
    % 2: make boxcar for positive predition errors (duration is 400 msec.)
    event_beg = b.fb_onset_time(x{block_n}); event_end = event_beg + 400;
    q_pos_errs = ( b.fauxPE > 0 );
    pos_pred_err = createSimpleRegressor(event_beg,event_end,epoch_window,q_pos_errs(x{block_n}));
    % 3: make boxcar for negative predition errors 
    q_neg_errs = ( b.fauxPE < 0 );
    neg_pred_err = -1*createSimpleRegressor(event_beg,event_end,epoch_window,q_neg_errs(x{block_n}));
    % 4: add main boxcar and prediction error boxcars together for TD boxcar
    tmp_reg.(['regressors' num2str(block_n)]).TD_reg(:,1) = ...
        ( main_body_boxcar + 0.5*pos_pred_err + 0.5*neg_pred_err);
    % -- 0000000000000000000 --
    
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
b.value_at_stake = zeros(size(b.specs.procedure_type));

q_half   = ~cellfun(@isempty,strfind(b.specs.procedure_type,'half'));
q_normal = ~cellfun(@isempty,strfind(b.specs.procedure_type,'norm'));
q_double = ~cellfun(@isempty,strfind(b.specs.procedure_type,'double'));

b.rew_at_stake(q_half)   = 0.10;
b.rew_at_stake(q_normal) = 0.20;
b.rew_at_stake(q_double) = 0.50;

% received
b.rew_received = zeros(size(b.value_at_stake));
b.rew_received = b.value_at_stake .* b.accuracy;
% - - -

% % convolve correct regressor with feedback
% exp_duration = 694*1000*3; % 694 secs. per block, convert to msec., x3 blocks
% epoch_window = b.stim_onset_time(1):bin_size:b.stim_onset_time(1) + exp_duration;
% event_beg = b.fb_onset_time; 
% event_end = event_beg+feedback_end;
% %catted_block.correct_feedback = createAndCatRegs(event_beg,event_end,epoch_window,b.accuracy);


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
function data_out = readInData(id)
% this is a temporary and very slow solution

% read in "raw" Excel data file
file_name = [pathroot 'analysis/bandit/fmri/data/raw/' num2str(id) '/' num2str(id) '.xlsx'];
[~, ~, rawdata] = xlsread(file_name);

% separate headers and data and add handy indexing function handle
data_out.names = rawdata(1,:)';
data_out.data  = rawdata(2:end,:);
data_out.query_field_location = @(q,d) ~cellfun(@isempty,regexp(d.names,q)); 
fh = @(s) data_out.query_field_location(s,data_out);

% rename certain header strings for slightly more consistency
for n_to_rename = {'computerplayblank','mystery'}
    for m_each_suffix = find(fh(n_to_rename{:}))'
        
        % add 'showstim' prefix to these names
        new_name = ['showstim' data_out.names{m_each_suffix}];
        data_out.names{m_each_suffix} = new_name;
        
    end
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function b_struct = convertToWorkingStruct(data_in_struct)

% add basic stimulus event data
b_struct.stim_onset_time  = concatUnnecessaryNameSchemeVars('^showstim.*\.OnsetTime$',data_in_struct);
b_struct.stim_offset_time = concatUnnecessaryNameSchemeVars('^showstim.*\.OffsetTime$',data_in_struct);
b_struct.jitter_1         = concatUnnecessaryNameSchemeVars('^jitter1$',data_in_struct);
b_struct.jitter_2         = concatUnnecessaryNameSchemeVars('^jitter2$',data_in_struct);
b_struct.fb_onset_time    = concatUnnecessaryNameSchemeVars('^Feedback[^Repeated].*\.OnsetTime$',data_in_struct);
b_struct.fb_offset_time   = concatUnnecessaryNameSchemeVars('^Feedback[^Repeated].*\.OffsetTime$',data_in_struct);

% add basic response event data
b_struct.RT               = concatUnnecessaryNameSchemeVars('^showstim.*\.RT$',data_in_struct);
b_struct.RT_time          = concatUnnecessaryNameSchemeVars('^showstim.*\.RTTime$',data_in_struct);
b_struct.response         = concatUnnecessaryNameSchemeVars('^showstim.*\.RESP$',data_in_struct);
b_struct.stim_chosen      = cell(size(b_struct.response)); % pre-allocate for later
b_struct.accuracy         = concatUnnecessaryNameSchemeVars('^showstim.*\.ACC$',data_in_struct);

% add various other variables
b_struct.specs.procedure_type = concatUnnecessaryNameSchemeVars('^Procedure$',data_in_struct);
%b_struct.specs.onset_to_onset = concatUnnecessaryNameSchemeVars('^showstim.*\.Onset$',data_in_struct);


% -- more computationally "intense" variables -- %
% add stimulus chosen and its position to structure
design_struct = bandit_fmri_load_design; % load design file

b_struct.stim_chosen(b_struct.response == 7) = design_struct.topstim(b_struct.response == 7); 
b_struct.stim_chosen(b_struct.response == 2) = design_struct.leftstim(b_struct.response == 2); 
b_struct.stim_chosen(b_struct.response == 3) = design_struct.rightstim(b_struct.response == 3); 

% recode chars as stim IDs
q = ~cellfun(@isempty,b_struct.stim_chosen);
tmp(q') = cellfun(@(c) cast(c,'double')-64, b_struct.stim_chosen(q));
tmp(~q) = 999; % missed answers coded as 999
b_struct.stim_chosen = tmp';

% code for stimulus choice switches
b_struct.stim_switch = zeros(numel(b_struct.stim_chosen),1);
for n = 2:numel(b_struct.stim_switch)
    last_stim    = b_struct.stim_chosen(n-1);
    current_stim = b_struct.stim_chosen(n);
    b_struct.stim_switch(n) = ne(last_stim,current_stim);
end

% code choice switches on the next trial
b_struct.next_switch = [b_struct.stim_switch(2:end); 0];

% code missed responses
b_struct.missed_responses = ( b_struct.RT == 0 );

% code onset of the next trial
b_struct.stim_NextOnsetTime=[b_struct.stim_onset_time(2:end); b_struct.RT_time(end)];


% -- remove the 'break' trial types -- %
% find fields with the same size as 'b_struct.specs.procedure_type'
q_fields_to_fix = ( structfun(@numel,b_struct) == numel(b_struct.specs.procedure_type) );
q_index_to_keep = cellfun(@isempty,regexp(b_struct.specs.procedure_type,'^Break'));
b_fnames = fieldnames(b_struct);
for n = 1:length(b_fnames)
    if(q_fields_to_fix(n))
        b_struct.(b_fnames{n}) = b_struct.(b_fnames{n})(q_index_to_keep);
    end
end
b_struct.specs.procedure_type = b_struct.specs.procedure_type(q_index_to_keep);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function cat_list = concatUnnecessaryNameSchemeVars(str_regexp,data_struct)

% an even easier to use function handle
fh = @(s) data_struct.query_field_location(s,data_struct);

% get index of variables
do_not_include = ( fh('ScannerPulse') | fh('Takeabreak') );
q_data_match = ( fh(str_regexp) & ~do_not_include );

% not all data is numerical
if(any(cellfun(@ischar,data_struct.data(:,q_data_match))))
    cat_list = data_struct.data(:,q_data_match);
    return
end
    
% collapse into 1-D array
data_to_cat = cell2mat(data_struct.data(:,q_data_match));
q_is_nan = isnan(data_to_cat);
data_to_cat(q_is_nan) = 0;

% safety check: make sure no columns overlap
if(any(sum(logical(data_to_cat),2)) > 1)
    error('MATLAB:bandit_fmri:column_squeeze','columns overlap: poor regexp');
end

% no overlap means all other columns are 0
cat_list = sum(data_to_cat,2);

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function foo = createSimpleRegressor(event_begin,event_end,epoch_window,conditional_trials)

% TODO: incorporate concatenation of different blocks in this function (maybe?)

% this was not a problem earlier, but for some reason it is now: find indices that would
% result in a negative value and set them both to 0
qbz = ( event_begin == 0 ); qez = ( event_end == 0 );
event_begin( qbz | qez ) = 0; event_end( qbz | qez ) = 0;

% check if optional censoring variable was used
if(~exist('conditional_trials','var') || isempty(conditional_trials))
    conditional_trials = true(length(event_begin),1);
elseif(~islogical(conditional_trials))
    % needs to be logical format to index cells
    conditional_trials = logical(conditional_trials);
end

% this only happened recently, but it's weird
if(any((event_end(conditional_trials)-event_begin(conditional_trials)) < 0))
    error('MATLAB:bandit_fmri:time_travel','feedback is apparently received before RT');
end

% create epoch windows for each trial
epoch = arrayfun(@(a,b) a:b,event_begin,event_end,'UniformOutput',false);

% for each "epoch" (array of event_begin -> event_end), count events
per_event_histcs = cellfun(@(h) histc(h,epoch_window),epoch(conditional_trials),'UniformOutput',false);
foo = logical(sum(cell2mat(per_event_histcs),1));

% createAndCatRegs(event_begin,event_end,epoch_window);

return


% function catted_blocks = createAndCatRegs(e_beg,e_end,e_win,cond_trials)
% 
% % check if optional censoring variable was used
% if(~exist('cond_trials','var') || isempty(cond_trials))
%     cond_trials = true(length(event_begin),1);
% elseif(~islogical(cond_trials))
%     % needs to be logical format to index cells
%     cond_trials = logical(cond_trials);
% end
% 
% fh_q = @(x) ((x-1)*100)+1:x*100; % handy function handle for indexing
% % e_win{1} = b.stim_onset_time(min(fh_q(1))):bin_size:b.stim_onset_time(fh_q(1))+694000;
% %     epoch_window = b.stim_onset_time(x(block_n,1)):bin_size:b.stim_onset_time(x(block_n,1))+694000;
% 
% % execute as three blocks
% catted_blocks = ( ...
%     createSimpleRegressor(e_beg(fh_q(1)),e_end(fh_q(1)),e_win,cond_trials(fh_q(1))) + ...
%     createSimpleRegressor(e_beg(fh_q(2)),e_end(fh_q(2)),e_win,cond_trials(fh_q(2))) + ...
%     createSimpleRegressor(e_beg(fh_q(3)),e_end(fh_q(3)),e_win,cond_trials(fh_q(3)))  ...
% );
% 
% return

