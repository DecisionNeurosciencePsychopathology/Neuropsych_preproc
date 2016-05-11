% Add the ratio of acceptace rate for high- to low-stake
% offers to the GEE file. 
%
% Jan Kalkus
% 08 Nov 2012

% load necessary data
load([pathroot 'db/n129.mat']);
load([pathroot 'analysis/ultimatum/data/UGsummary_data_29-Oct-2012/ball.mat']);

% gather what you need
q = ismember(ball.id,ug_n129);
accept_rate = [ball.trial(q).accept];
hi_stake    = [ball.trial(q).stake];
hi_lo_ratio = zeros(length(hi_stake),1);

for subj_i = 1:numel(ug_n129)
    q_stake = hi_stake(:,subj_i);
    hi_rate = mean(accept_rate(q_stake,subj_i));
    lo_rate = mean(accept_rate(~q_stake,subj_i));

    hi_lo_ratio(subj_i,1) = (hi_rate/lo_rate); % WARNING: we do have values of Inf
end

% execute
makeSparseGEE('use-ids',ug_n129,'add-vars',hi_lo_ratio,'var-names','accept_by_stake_ratio');