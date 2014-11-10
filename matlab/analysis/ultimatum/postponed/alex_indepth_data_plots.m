% more plots...
clear all; 

% set OS/machine specific paths
if(ispc)
	DATA_DIR = 'L:/'; 
elseif(isunix)
	[status txt] = unix('uname -n');
	if(strcmp(txt,sprintf('kovadlina\n')));
		DATA_DIR = '~/tmp/disk/kod/devenv/L/';
	else
		DATA_DIR = '~/kod/devenv/L/';
	end
end	

% load necessary data
load([DATA_DIR 'Summary Notes/Data/Ultimatum Game/processed data/' ...
	'UGsummary_data_15-Feb-2012/group12467.mat'],'ball','group12467');
load('../../db/pt_data_simple_demographics.mat');

% organize data into quick data structure
fprintf('organizing subject data...\n');
count = 1;
for i = 1:length(ball.id)
	qdata = find(group12467(:,1) == ball.id(i));
	qdems = find(pt_data_simple_demographics(:,1) == ball.id(i));
	if(~isempty(qdata) && ~isempty(qdems))
		data_struc.id(count,1)       = ball.id(i);
		data_struc.age(count,1)      = pt_data_simple_demographics(qdems,3);
		data_struc.group_id(count,1) = group12467(i,2);
		data_struc.fairness(count,1) = {ball.trial(i).fairness};
		data_struc.stake(count,1)    = {ball.trial(i).stake};
		%data_struc.reject(count,1)   = {~ball.trial(i).accept};
        data_struc.reject(count,1)   = {ball.trial(i).accept};
		count = count + 1;
	else
		fprintf('Subject ID: %d data not found\n',ball.id(i));
	end
end

if(ispc)
	cd('c:/kod/matlab/jan/analysis/ultimatum/');
elseif(usunix)
	cd('~/kod/matlab/jan/analysis/ultimatum/');
end
save('quick_n_dirty_data_struc.mat','data_struc');

%% #####   FAIRNESS x GROUP   ##### %%

% load data
clear all; % to be safe
load('quick_n_dirty_data_struc.mat');


for fair_id = 1:3
    t = 1; u = 1; v = 1; w = 1; x = 1;
    for subj_id = 1:length(data_struc.id)
        qf = ( data_struc.fairness{subj_id} == fair_id );
        grp_id = data_struc.group_id(subj_id);
        rejrate = data_struc.reject{subj_id}(qf);
        
        switch grp_id
            case 1 % controls
                fair_struc(fair_id).group{grp_id,1}(t,1) = mean(rejrate);
                clear('rejrate'); 
                t=t+1;
            case 2 % non-suicidal depressed
                fair_struc(fair_id).group{grp_id,1}(u,1) = mean(rejrate);
                clear('rejrate');
                u=u+1;
            case 4 % suicide ideators
                fair_struc(fair_id).group{grp_id,1}(v,1) = mean(rejrate);
                clear('rejrate');
                v=v+1;
            case 6 % low-lethality suicide attempters
                fair_struc(fair_id).group{grp_id,1}(w,1) = mean(rejrate);
                clear('rejrate');
                w=w+1;
            case 7 % high-lethality suicide attempters
                fair_struc(fair_id).group{grp_id,1}(x,1) = mean(rejrate);
                clear('rejrate');
                x=x+1;
        end
    end
end

group_labels = {'Controls';'Non-suicidal depressed';'Suicide idators'; ...
    'Low-lethality suicide attemptors';'High-lethality suicide attemptors'};

% average data together for plots
for fair_level = 1:3
    for group_level = 1:length(group_labels)
        
        switch group_level
            case 3
                gid = 4;
            case 4
                gid = 6;
            case 5
                gid = 7;
            otherwise
                gid = group_level;
        end
        
        Y(group_level,fair_level) = mean(fair_struc(fair_level).group{gid});
    end
end

% plot data 
figure('Position',[100 345 560 553],'PaperPositionMode','auto');
m = plot(1:3,Y,'-o','LineWidth',2);

% make pretty
group_lineStyle = {'-' '-' '-' ':' '--'};
group_color = [
    0.0 0.7 0.2; 
    0.0 0.0 1.0; 
    0.7 0.0 0.6; 
    0.8 0.0 0.0; 
    0.8 0.0 0.0];

set(gca,'XLim',[0.9 3.1],'YLim',[0.0 1.0],'XTick',(1:3));
set(gca,'XTickLabel',{'unfair' 'medium' 'fair'});
xlabel('Fairness level'); ylabel('Acceptance rate %');
% legend(group_labels,'Location','SouthWest','FontSize',8);
legend(group_labels,'Location','NorthWest','FontSize',8);

title(sprintf('Effect of offer fairness on acceptance rate (n = %d)', ...
    length(data_struc.id)),'FontSize',12);
for k = 1:5
    set(m(k),'LineStyle',group_lineStyle{k},'Color',group_color(k,:));
    if(k == 4), set(m(k),'LineWidth',3); end
end

% save figure
print('-dpdf','../../figures/ug_acceptance_vs_fairness.pdf');
%% #####   FAIRNESS x GROUP x STAKE   ##### %%

% load data
clear all; % to be safe
load('quick_n_dirty_data_struc.mat');

for fair_id = 1:3
    t = 1; u = 1; v = 1; w = 1; x = 1;
    for subj_id = 1:length(data_struc.id)
        qf = ( data_struc.fairness{subj_id} == fair_id );
        qs = ( data_struc.stake{subj_id} );
        grp_id = data_struc.group_id(subj_id);
        
        % assuming hi = 1 and low = 0
        rej.hi = data_struc.reject{subj_id}(qf & qs);
        rej.lo = data_struc.reject{subj_id}(qf & ~qs);
        
        switch grp_id
            case 1 % controls
                fair_struc(fair_id).group{grp_id,1}(t,1) = mean(rej.lo);
                fair_struc(fair_id).group{grp_id,1}(t,2) = mean(rej.hi);
                clear('rej'); 
                t=t+1;
            case 2 % non-suicidal depressed
                fair_struc(fair_id).group{grp_id,1}(u,1) = mean(rej.lo);
                fair_struc(fair_id).group{grp_id,1}(u,2) = mean(rej.hi);
                clear('rej');
                u=u+1;
            case 4 % suicide ideators
                fair_struc(fair_id).group{grp_id,1}(v,1) = mean(rej.lo);
                fair_struc(fair_id).group{grp_id,1}(v,2) = mean(rej.hi);
                clear('rej');
                v=v+1;
            case 6 % low-lethality suicide attempters
                fair_struc(fair_id).group{grp_id,1}(w,1) = mean(rej.lo);
                fair_struc(fair_id).group{grp_id,1}(w,2) = mean(rej.hi);
                clear('rej');
                w=w+1;
            case 7 % high-lethality suicide attempters
                fair_struc(fair_id).group{grp_id,1}(x,1) = mean(rej.lo);
                fair_struc(fair_id).group{grp_id,1}(x,2) = mean(rej.hi);
                clear('rej');
                x=x+1;
        end
    end
end

% get mean data for plots
group_labels = {'Controls';'Non-suicidal depressed';'Suicide idators'; ...
    'Low-lethality suicide attemptors';'High-lethality suicide attemptors'};

% average data together for plots
for fair_level = 1:3
    for group_level = 1:length(group_labels)
        
        switch group_level
            case 3
                gid = 4;
            case 4
                gid = 6;
            case 5
                gid = 7;
            otherwise
                gid = group_level;
        end

        Y.lo(group_level,fair_level) = mean(fair_struc(fair_level).group{gid}(:,1));
		Y.hi(group_level,fair_level) = mean(fair_struc(fair_level).group{gid}(:,2));
    end
end

% plot data 
figure('Position',[450 345 1120 553],'PaperPositionMode','auto', ...
    'PaperOrientation','Landscape');

group_lineStyle = {'-' '-' '-' ':' '--'};
group_color = [
    0.0 0.7 0.2; 
    0.0 0.0 1.0; 
    0.7 0.0 0.6; 
    0.8 0.0 0.0; 
    0.8 0.0 0.0];

for i = 1:2
	% plot data
	if(eq(1,i)), z = Y.lo; else z = Y.hi; end
	h(i) = subplot(1,2,i); m = plot(1:3,z,'-o','LineWidth',2);
	% make pretty
	set(h(i),'XLim',[0.9 3.1],'YLim',[0.0 1.0],'XTick',(1:3));
	set(h(i),'XTickLabel',{'unfair' 'medium' 'fair'});
	xlabel('Fairness level'); ylabel('Acceptance rate %');
	if(eq(i,1))
% 		legend(group_labels,'Location','SouthWest','FontSize',8);
        legend(group_labels,'Location','NorthWest','FontSize',8);
		ttle = 'low';
	else
		ttle = 'high';
	end
	title(sprintf('Effect of fairness on acceptance\nrate of %s-stake offers (n = %d)', ...
		ttle,length(data_struc.id)),'FontSize',12);
    for k = 1:5
        set(m(k),'LineStyle',group_lineStyle{k},'Color',group_color(k,:));
        if(k == 4), set(m(k),'LineWidth',3); end
    end
end

print('-dpdf','../../figures/ug_acceptance_vs_fairness_by_stake.pdf');

%% #####   FAIRNESS x GROUP x STAKE x TRIAL   ##### %%

% We meet at last...
% load data
clear all; % to be safe
load('quick_n_dirty_data_struc.mat');

for fair_id = 1:3
    t = 1; u = 1; v = 1; w = 1; x = 1;
    for subj_id = 1:length(data_struc.id)
        qf = ( data_struc.fairness{subj_id} == fair_id );
        qs = ( data_struc.stake{subj_id} );
        grp_id = data_struc.group_id(subj_id);
        
        rej.hi = nan(1,24); rej.lo = nan(1,24);
        % assuming hi = 1 and low = 0
        rej.hi(qf & qs) = data_struc.reject{subj_id}(qf & qs);
        rej.lo(qf & ~qs) = data_struc.reject{subj_id}(qf & ~qs);
        
        switch grp_id
            case 1 % controls
                fair_struc(fair_id).group{grp_id,1}(t,1:24,1) = rej.lo;
                fair_struc(fair_id).group{grp_id,1}(t,1:24,2) = rej.hi;
                clear('rej'); 
                t=t+1;
            case 2 % non-suicidal depressed
                fair_struc(fair_id).group{grp_id,1}(u,1:24,1) = rej.lo;
                fair_struc(fair_id).group{grp_id,1}(u,1:24,2) = rej.hi;
                clear('rej');
                u=u+1;
            case 4 % suicide ideators
                fair_struc(fair_id).group{grp_id,1}(v,1:24,1) = rej.lo;
                fair_struc(fair_id).group{grp_id,1}(v,1:24,2) = rej.hi;
                clear('rej');
                v=v+1;
            case 6 % low-lethality suicide attempters
                fair_struc(fair_id).group{grp_id,1}(w,1:24,1) = rej.lo;
                fair_struc(fair_id).group{grp_id,1}(w,1:24,2) = rej.hi;
                clear('rej');
                w=w+1;
            case 7 % high-lethality suicide attempters
                fair_struc(fair_id).group{grp_id,1}(x,1:24,1) = rej.lo;
                fair_struc(fair_id).group{grp_id,1}(x,1:24,2) = rej.hi;
                clear('rej');
                x=x+1;
        end
    end
end

% get mean data for plots
group_labels = {'Controls';'Non-suicidal depressed';'Suicide idators'; ...
    'Low-lethality suicide attemptors';'High-lethality suicide attemptors'};

for fair_level = 1:3
    for group_level = 1:length(group_labels)
        
        switch group_level
            case 3
                gid = 4;
            case 4
                gid = 6;
            case 5
                gid = 7;
            otherwise
                gid = group_level;
        end

        tmp = nanmean(fair_struc(fair_level).group{gid}(:,:,1));
        Y.fair(fair_level).lo(group_level,:) = [ ...
            nanmean(tmp(1:4))   nanmean(tmp(5:8))   nanmean(tmp(9:12)) ...
            nanmean(tmp(13:16)) nanmean(tmp(17:20)) nanmean(tmp(21:24))];
        
        tmp = nanmean(fair_struc(fair_level).group{gid}(:,:,2));
		Y.fair(fair_level).hi(group_level,:) = [ ...
            nanmean(tmp(1:4))   nanmean(tmp(5:8))   nanmean(tmp(9:12)) ...
            nanmean(tmp(13:16)) nanmean(tmp(17:20)) nanmean(tmp(21:24))];
    end
end

% plot data 
figure('Position',[194 31 781 963],'PaperPositionMode','auto', ...
    'PaperOrientation','Portrait');
fair_tags = {'unfair' 'medium' 'fair'};

group_lineStyle = {'-' '-' '-' ':' '--'};
group_color = [
    0.0 0.7 0.2; 
    0.0 0.0 1.0; 
    0.7 0.0 0.6; 
    0.8 0.0 0.0; 
    0.8 0.0 0.0];

sp_index = [1 2;3 4;5 6];
for j = 1:2 % stake level
    for i = 1:3 % fairness level
        % plot data
        if(eq(1,j)), z = Y.fair(i).lo; else z = Y.fair(i).hi; end
        h(i,j) = subplot(3,2,sp_index(i,j)); 
        m = plot(1:length(z),z,'-','LineWidth',1.5); hold on;
        plot(1:length(z),mean(z),':k','LineWidth',1); hold off;
        xlabel('Trial'); ylabel('Acceptance rate %');
        if(eq(sp_index(i,j),6))
%             legend({group_labels{:} 'Average'}','Location','NorthEast','FontSize',7);
            legend({group_labels{:} 'Average'}','Location','SouthEast','FontSize',7);
            
        end
        if(eq(j,1))
            ttle = 'low';
        else
            ttle = 'high';
        end
        title(sprintf('Effect of {\\bf%s} offers on acceptance rate\nof {\\bf%s}-stake offers (n = %d)', ...
        	fair_tags{i},ttle,length(data_struc.id)),'FontSize',10);
        for k = 1:5
            set(m(k),'LineStyle',group_lineStyle{k},'Color',group_color(k,:));
            if(k == 4), set(m(k),'LineWidth',3); end
        end
    end
end

set(h,'XLim',[0.8 length(z)+0.2],'YLim',[0.0 1.0]);
set(h,'XTickLabel',(4:4:24));

print('-dpdf','../../figures/ug_acceptance_vs_fairness_by_stake_by_trial.pdf');

%% #####   ONE MORE THING... (REJECTION RATE by STAKE)##### %%

% load data
clear all; % to be safe
load('quick_n_dirty_data_struc.mat');

for stake_id = 1:2
    t = 1; u = 1; v = 1; w = 1; x = 1;
    for subj_id = 1:length(data_struc.id)
        qs = ( data_struc.stake{subj_id} == (stake_id-1) );
        grp_id = data_struc.group_id(subj_id);
        rejrate = data_struc.reject{subj_id}(qs);
        
        switch grp_id
            case 1 % controls
                stake_struc(stake_id).group{grp_id,1}(t,1) = mean(rejrate);
                t=t+1;
            case 2 % non-suicidal depressed
                stake_struc(stake_id).group{grp_id,1}(u,1) = mean(rejrate);
                u=u+1;
            case 4 % suicide ideators
                stake_struc(stake_id).group{grp_id,1}(v,1) = mean(rejrate);
                v=v+1;
            case 6 % low-lethality suicide attempters
                stake_struc(stake_id).group{grp_id,1}(w,1) = mean(rejrate);
                w=w+1;
            case 7 % high-lethality suicide attempters
                stake_struc(stake_id).group{grp_id,1}(x,1) = mean(rejrate);
                x=x+1;
        end
        clear('rejrate'); 
    end
end

group_labels = {'Controls';'Non-suicidal depressed';'Suicide idators'; ...
    'Low-lethality suicide attemptors';'High-lethality suicide attemptors'};

% average data together for plots
for stake_level = 1:2
    for group_level = 1:length(group_labels)
        
        switch group_level
            case 3
                gid = 4;
            case 4
                gid = 6;
            case 5
                gid = 7;
            otherwise
                gid = group_level;
        end
        
        Y(group_level,stake_level) = mean(stake_struc(stake_level).group{gid});
    end
end

% plot data 
figure('Position',[100 345 560 553],'PaperPositionMode','auto');
plot(1:2,Y,'-o','LineWidth',2);

% make pretty
set(gca,'XLim',[0.9 2.1],'YLim',[0.3 0.8],'XTick',(1:3),'YTick',0.3:0.1:0.8);
set(gca,'XTickLabel',{'low' 'high'});
xlabel('Stake level'); ylabel('Acceptance rate %');
legend(group_labels,'Location','SouthWest','FontSize',8);
title(sprintf('Effect of offer stake on acceptance rate (n = %d)', ...
    length(data_struc.id)),'FontSize',12);

% save figure
print('-dpdf','../../figures/ug_acceptance_vs_stake.pdf');
