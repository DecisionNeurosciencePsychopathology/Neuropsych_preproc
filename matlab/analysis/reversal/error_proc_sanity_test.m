load data/rev_data.mat

subplot(2,2,1); histfit(rev_struct.spont_switch);
title('Spontaneous switch errors');
set(gca,'XLim',[0 20]);

subplot(2,2,2); histfit(rev_struct.persev_error);
title('Perseverative errors');
set(gca,'XLim',[0 40]);

subplot(2,2,3); histfit(rev_struct.prob_switch.total);
title('Probabilistic switch errors across all trials');
set(gca,'XLim',[0 30]);

subplot(2,2,4); 
hist([rev_struct.prob_switch.pre_reversal rev_struct.prob_switch.post_reversal]);
title('Probabilistic switch errors (pre- and post- reversal');
legend('pre-reversal','post-reversal');
