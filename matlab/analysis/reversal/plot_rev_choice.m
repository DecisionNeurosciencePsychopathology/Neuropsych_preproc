% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function plot_rev_choice(id,w)
%
% Jan Kalkus
% 2014-04-22


% load data
load([pathroot 'analysis/reversal/data/rev_data.mat']);
q = ( rev_struct.ID == id );

% smoothing window
if(~exist('w','var') || isempty(w)), w = 8; end

% smooth choice ratio response
smoothed_choices = filtfilt(ones(1,w)/w,1,rev_struct.specs.stim_choice{q});

% persev. errors
current_stim  = rev_struct.specs.stim_choice{q}(2:end);
previous_stim = rev_struct.specs.stim_choice{q}(1:end-1);
persev_error = [false; (current_stim == previous_stim) & (current_stim == 1)];
qpse = find(persev_error(41:end));

% plot data
figure;
n_trials = size(rev_struct.specs.RT{q},1);
discrete_choices = rev_struct.specs.stim_choice{q};
[ax,~,h2] = plotyy(1:n_trials,smoothed_choices,1:n_trials,discrete_choices);
hold on; plot(qpse+40,ones(size(qpse))+0.2,'rx'); hold off;

% make the axes, markers, etc. look pretty
title(sprintf('Subject: %d',id));
set(h2,'Marker','.','LineStyle','.');
set(ax(2),'YLim',[0.75 2.25],'YTick',[1 2]);
set(get(ax(1),'Ylabel'),'String','Stim. choice ratio');
set(get(ax(2),'Ylabel'),'String','Discrete stim. choices');

return
