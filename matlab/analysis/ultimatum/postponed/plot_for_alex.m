% Drs. Dombrovski and Szanto wanted a figure of the findgins from the 
% Ultimatum Game GEE analysis. (Data provided in email from Dr. Dombrovski)

% Jan Kalkus
% 17 Feb 2012
%
% These numbers are from Alex, so it is very likely that they are from the 
% n = 85 subject sample.

% setup vars
if(ispc)
	ROOT_DIR = 'c:/kod/matlab/jan/';
elseif(isunix)
	ROOT_DIR = '~/tmp/disk/kod/matlab/jan/';
	if(~isdir(ROOT_DIR))
		error('MATLAB:plots_for_alex:direxist':'change dir settings');
	end
end

% the data
group_means = [0.56 0.54 0.57 0.61 0.49; ...
               0.47 0.48 0.59 0.40 0.62];
           
group_sem = [0.096 0.068 0.093 0.081 0.083; ...
             0.101 0.065 0.091 0.125 0.098];
         
stake_id  = [zeros(1,size(group_sem,2)); ...
             ones(1,size(group_sem,2))];

group_id = {'Controls';'Non-suicidal depressed';'Suicide idators'; ...
    'Low-lethality suicide attemptors';'High-lethality suicide attemptors'};

% the plot
figure('Position',[420 345 560 603],'PaperPositionMode','auto');
plot(stake_id(:,1:end-1),group_means(:,1:end-1),'-o','LineWidth',2); hold on;
plot(stake_id(:,end),group_means(:,end),'m--o','LineWidth',3, ...
    'MarkerEdgeColor',[1 0 1]); hold off;

% make it pretty
set(gca,'XLim',[-0.1 1.1],'YLim',[0.35 0.7], ...
    'XTick',[0 1],'XTickLabel',{'low' 'high'});
xlabel('Stake'); ylabel('Rejection rate %');
x = diff(group_means); legstr = cell(length(stake_id),1);
for i = 1:length(group_id)
    legstr{i} = sprintf('(\\Delta = %4.2f)  %s\n',x(i),group_id{i});
end
legend(legstr,'Location','North','FontSize',8);
title(sprintf('%s\n%s',['Perverse effect of stake on rejection rates'], ...
    ['in high lethality older suicide attemptors']),'FontSize',13);

% print it
print('-dpdf',[ROOT_DIR 'figures/ug_rejection_vs_stake_plot.pdf']); 
