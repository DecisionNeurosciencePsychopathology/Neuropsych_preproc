% load the data
load([pathroot 'analysis/ultimatum/data/UG23260.mat']);
load([pathroot 'analysis/ultimatum/data/UGsummary_data_29-Oct-2012\ball.mat']);

% get acceptance rates
acc_low_stake  = mean(b.accept(b.cond.lo));
acc_high_stake = mean(b.accept(b.cond.hi));

% with fairness
U.acc_lo_stake = 1 - (ball.beh(q).rrunfairlo);
U.acc_hi_stake = 1 - (ball.beh(q).rrunfairhi);

M.acc_lo_stake = 1 - (ball.beh(q).rrmediumlo);
M.acc_hi_stake = 1 - (ball.beh(q).rrmediumhi);

F.acc_lo_stake = 1 - (ball.beh(q).rrfairlo);
F.acc_hi_stake = 1 - (ball.beh(q).rrfairhi);


% plot it
Y = [U.acc_lo_stake U.acc_hi_stake; M.acc_lo_stake M.acc_hi_stake; F.acc_lo_stake F.acc_hi_stake]';
plot([1 2],Y,'o-','LineWidth',4);
set(gca,'XLim',[0.5 2.5],'YLim',[0 1],'XTickLabel',{'Low','High'},'XTick',[1 2]);
legend('Unfair','Medium','Fair');
xlabel('Stake size'); ylabel('Acceptance rate');
