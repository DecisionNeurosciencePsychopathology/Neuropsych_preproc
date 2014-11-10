% this function is an adaptation of the original 'bandit_proc'
% fucntion. this function orchestrates the processing of the fMRI
% version of the bandit task
%
% Jan Kalkus
% 2013-03-14

function q = bandit_fmri_proc( varargin )


% processes 3-armed bandit data on all subjects
data_dir = [pathroot 'analysis/bandit/fmri/data/']; % set data path

% create list of subjects defined by directory names
a = ls([data_dir 'raw/']);
if(isnan(str2double(a(end))))
    numlist = str2num(a(3:end-1,:));
else
    numlist = str2num(a(3:end,:));
end

% % run single-subject proc script on each
for sub=1:length(numlist)
    
    fprintf('processing id: %6d\t\t',numlist(sub)); 

	% which variables do you want?
 
    % load subject's data
    s = bandit_fmri_sub_proc('id',numlist(sub));
    
    % print some general error counts info
%     fprintf('error counts: PS = %3d, SS = %3d, PE = %3d\n', ...
%         sum(s.errors.prob_switch_err), ...
%         sum(s.errors.spont_switch_err), ...
%         sum(s.errors.perseverative) ...
%     );

% 
%     b_all.id(sub,1) = numlist(sub);
%     % the [bellow/deleted] is redundant; we can get the same result using
%     % the stored function handle and subject by subject data:
%     %
%     %     x = ball.fx.choice_to_stimID([ball.behav.choice]);
%     %
%     % this output is not in a logical/binary format as
%     % ball.[a-c]choice were, but it is easity converted to such
% 
% 	b_all.behav(sub).choice     = s.stim_choice;
%     if(eq(sub,1)) % only need to do this once
%         % function handle converts ball.behav.choice from 'char' to 'int'
%         ball.fx.choice_to_stimID = @(c) cast(c,'uint8')-64;
%     end
%     b_all.behav(sub).bestchoice = s.best_choice;
%     b_all.behav(sub).errors.spont = s.errors.spont_switch_err;
%     b_all.behav(sub).errors.prob  = s.errors.prob_switch_err;
%     b_all.behav(sub).errors.perseverative = s.errors.perseverative;
% 
%     b_all.behav(sub).RT = s.showstim_RT;
%     b_all.behav(sub).chosen_position = s.chosen_position;
% 
%     % add routine for 'last_updated' vs. 'last_checked'
% 	b_all.last_updated = datestr(now,'yyyy-mm-dd HH:MM:SS');

end

% enter descriptive field info
% -- not done yet --

% save it
save([data_dir 'bandit_data'],'ball');

% varargout
if(nargout), q = ball; end

return
