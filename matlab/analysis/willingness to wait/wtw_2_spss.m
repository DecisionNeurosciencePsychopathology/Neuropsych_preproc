% send some willingness to wait data to a SPSS importable format file
%
% 
%
% Jon Wilson
% 7 23 2014

load([pathroot 'analysis/willingness to wait/data/wtw_data.mat']);

% open file pointer and print out headers
fid = fopen([pathroot 'analysis/bandit/data/wtw2spss.dat'],'w');

fprintf(fid,'ID\bkIdx\initalTime\initialPos\designatedWait\trialResult\t');
fprintf(fid,'latency\payoff\totalEarned\timeLeft\outcomeTime\t');

%NEED MORE INFO BEFORE PROCEEDING...
%THIS SCRIPT IS NOT REALLY NEEDED


for nsubj = 1:numel(ball.id)
    
    % errors as usual
    pse  = sum(ball.behav(nsubj).errors.prob);
    sse  = sum(ball.behav(nsubj).errors.spont);
    per  = sum(ball.behav(nsubj).errors.perseverative);
    pcor = f_percent_correct(nsubj);
    
    % exploratory switch errors
    expl = nansum(ball.behav(nsubj).errors.explore_sw);
    erratic_spont = nansum(ball.behav(nsubj).errors.erratic_spont);
    
    % delta index
    delta_index = ball.behav(nsubj).delta_index;
    
    % split half errors (before and after reversal)
    before_pse = sum(ball.behav(nsubj).errors.before.prob_switch_err);
    before_sse = sum(ball.behav(nsubj).errors.before.spont_switch_err);
    before_per = sum(ball.behav(nsubj).errors.before.perseverative);
    
    after_pse  = sum(ball.behav(nsubj).errors.after.prob_switch_err);
    after_sse  = sum(ball.behav(nsubj).errors.after.spont_switch_err);
    after_per  = sum(ball.behav(nsubj).errors.after.perseverative);
    
    % percent correct
    before_pcor = 100*sum(ball.behav(nsubj).bestchoice(1:150)/numel(ball.behav(nsubj).bestchoice(1:150)));
    after_pcor  = 100*sum(ball.behav(nsubj).bestchoice(151:end)/numel(ball.behav(nsubj).bestchoice(151:end)));
    
    
    % write to file
    fprintf(fid,'%d\t%d\t%d\t%d\t%g\t',ball.id(nsubj),pse,sse,per,pcor);
    fprintf(fid,'%d\t%d\t%d\t%g\t',before_pse,before_sse,before_per,before_pcor);
    fprintf(fid,'%d\t%d\t%d\t%g\t',after_pse,after_sse,after_per,after_pcor);
    fprintf(fid,'%d\t',ball.behav(nsubj).count_to_first_C);
    fprintf(fid,'%d\t',expl);
    fprintf(fid,'%d\t%g\n',erratic_spont,delta_index);
    
end

% kill the pointer
fclose(fid);
S