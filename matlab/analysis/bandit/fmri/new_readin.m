% Jan Kalkus
% 2013-07-23: Not entirely sure I can recall what was happening here...
%   		  Apparently something with regular expressions. 

% convert new input to previous structure format:

% b = 
% 
%          stim_OnsetTime: [300x1 double]
%         stim_OffsetTime: [300x1 double]
%                 stim_RT: [300x1 double]
%             stim_RTTime: [300x1 double]
%               stim_RESP: [300x1 double]
%              stim_CRESP: [300x1 double]
%                stim_ACC: [300x1 double]
%     feedback_OnsetDelay: [300x1 double]
%      feedback_OnsetTime: [300x1 double]
%     feedback_OffsetTime: [300x1 double]
%            stim_jitter1: [300x1 double]
%            stim_jitter2: [300x1 double]
%                   fname: [1x80 char]
%           protocol_type: {300x1 cell}
%             chosen_stim: [300x1 double]
%             stim_switch: [300x1 double]
%             next_switch: [300x1 double]
%        missed_responses: [300x1 logical]
%      stim_NextOnsetTime: [300x1 double]
%                hrf_regs: [1x1 struct]


mork.stim_onset_time = concatUnnecessaryNameSchemeVars('^showstim.*\.OnsetTime$',data_in_struct);
mork.stim_offset_time = concatUnnecessaryNameSchemeVars('^showstim.*\.OffsetTime$',data_in_struct);
mork.RT = concatUnnecessaryNameSchemeVars('^showstim.*\.RT$',data_in_struct);
mork.RT_time = concatUnnecessaryNameSchemeVars('^showstim.*\.RTTime$',data_in_struct);

mork.response = concatUnnecessaryNameSchemeVars('^showstim.*\.RESP$',data_in_struct);
mork.accuracy = concatUnnecessaryNameSchemeVars('^showstim.*\.ACC$',data_in_struct);

mork.fb_onset_time = concatUnnecessaryNameSchemeVars('^Feedback.*\.OnsetTime$',data_in_struct);
mork.fb_offset_time = concatUnnecessaryNameSchemeVars('^Feedback.*\.OffsetTime$',data_in_struct);

mork.jitter_1 = concatUnnecessaryNameSchemeVars('^jitter1$',data_in_struct);
mork.jitter_2 = concatUnnecessaryNameSchemeVars('^jitter2$',data_in_struct);

mork.protocol = concatUnnecessaryNameSchemeVars('^Procedure$',data_in_struct);
