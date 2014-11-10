%
% Jan Kalkus
% 17 Jan 2013

% load most recent UG data file
load([mostRecentDir([pathroot 'analysis/ultimatum/data/']) 'ball.mat']);
load([pathroot 'db/n129.mat']);

% pring headers
fid = fopen('money_earned.dat','w');
fprintf(fid,'ID\tmoney\treject\t');
fprintf(fid,'reject_hi_stake\treject_lo_stake\tmoney_hi_stake\tmoney_lo_stake\t');
% fprintf(fid,'reject_unfair\treject_medfair\treject_fair\t');
fprintf(fid,'money_unfair\tmoney_medfair\tmoney_fair\t');

fprintf(fid,'reject_high_stake_ufair\treject_high_stake_mfair\treject_high_stake_fair\t');
fprintf(fid,'reject_low_stake_ufair\treject_low_stake_mfair\treject_low_stake_fair\t');

fprintf(fid,'money_high_stake_ufair\tmoney_high_stake_mfair\tmoney_high_stake_fair\t');
fprintf(fid,'money_low_stake_ufair\tmoney_low_stake_mfair\tmoney_low_stake_fair\n');


for sub_i = 1:numel(ug_n129)

    % find only data for n = 129 sample members
    q = ismember(ball.id,ug_n129(sub_i));

    id = ball.id(q);
    fprintf(fid,'%6d\t',id);
    
    % total results
    total_money_earned = sum(ball.trial(q).offer_size(ball.trial(q).accept));
    total_reject_dt    = 1-mean(ball.trial(q).accept);
    fprintf(fid,'%5.2f\t%4.2f\t',total_money_earned,total_reject_dt);
    
    
    % acceptance rates by stake
    q_hi_stake = ball.trial(q).hi_stake;
    reject_dt_hi_stake = 1-mean(ball.trial(q).accept(q_hi_stake));
    reject_dt_lo_stake = 1-mean(ball.trial(q).accept(~q_hi_stake));
    fprintf(fid,'%4.2f\t',reject_dt_hi_stake,reject_dt_lo_stake);
    
    % money earned by stake
    money_earned_hi_stake = sum(ball.trial(q).offer_size(q_hi_stake & ball.trial(q).accept));
    money_earned_lo_stake = sum(ball.trial(q).offer_size(~q_hi_stake & ball.trial(q).accept));
    fprintf(fid,'%5.2f\t%5.2f\t',money_earned_hi_stake,money_earned_lo_stake);
    
    
%     % acceptance rates by fairness
%     reject_dt_ufair = mean(ball.trial(q).accept(ball.trial(q).fairness == 1));
%     reject_dt_mfair = mean(ball.trial(q).accept(ball.trial(q).fairness == 2));
%     reject_dt_fair  = mean(ball.trial(q).accept(ball.trial(q).fairness == 3));
%     fprintf(fid,'%4.2f\t',reject_dt_ufair,reject_dt_mfair,reject_dt_fair);
    
    % money earned by fairness
    money_earned_ufair = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 1 & ball.trial(q).accept));
    money_earned_mfair = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 2 & ball.trial(q).accept));
    money_earned_fair  = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 3 & ball.trial(q).accept));
    fprintf(fid,'%5.2f\t',money_earned_ufair,money_earned_mfair,money_earned_fair);
    
    
    % acceptance rate by fairness by stake
    reject_high_stake_ufair = 1-mean(ball.trial(q).accept(ball.trial(q).fairness == 1 & q_hi_stake));
    reject_high_stake_mfair = 1-mean(ball.trial(q).accept(ball.trial(q).fairness == 2 & q_hi_stake));
    reject_high_stake_fair  = 1-mean(ball.trial(q).accept(ball.trial(q).fairness == 3 & q_hi_stake));
    fprintf(fid,'%4.2f\t',reject_high_stake_ufair,reject_high_stake_mfair,reject_high_stake_fair);
    
    reject_low_stake_ufair = 1-mean(ball.trial(q).accept(ball.trial(q).fairness == 1 & ~q_hi_stake));
    reject_low_stake_mfair = 1-mean(ball.trial(q).accept(ball.trial(q).fairness == 2 & ~q_hi_stake));
    reject_low_stake_fair  = 1-mean(ball.trial(q).accept(ball.trial(q).fairness == 3 & ~q_hi_stake));
    fprintf(fid,'%4.2f\t',reject_low_stake_ufair,reject_low_stake_mfair,reject_low_stake_fair);
    
    % now the same, but for money earned
    money_high_stake_ufair = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 1 & ball.trial(q).accept & q_hi_stake));
    money_high_stake_mfair = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 2 & ball.trial(q).accept & q_hi_stake));
    money_high_stake_fair  = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 3 & ball.trial(q).accept & q_hi_stake));
    fprintf(fid,'%5.2f\t',money_high_stake_ufair,money_high_stake_mfair,money_high_stake_fair);
    
    money_low_stake_ufair = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 1 & ball.trial(q).accept & ~q_hi_stake));
    money_low_stake_mfair = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 2 & ball.trial(q).accept & ~q_hi_stake));
    money_low_stake_fair  = sum(ball.trial(q).offer_size(ball.trial(q).fairness == 3 & ball.trial(q).accept & ~q_hi_stake));
    fprintf(fid,'%5.2f\t',money_low_stake_ufair,money_low_stake_mfair,money_low_stake_fair);
    fprintf(fid,'\n');
    
end

fclose(fid);

%      1     1   359   241