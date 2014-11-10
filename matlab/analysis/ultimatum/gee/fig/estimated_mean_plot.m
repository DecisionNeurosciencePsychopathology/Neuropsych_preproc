% <description> </description>
% 
% Jan Kalkus
% 19 Jul 2012

% TODO 2012-08-

% These numbers are from an SPSS GEE analysis. They are estimated means. 
% unfair offers
group_acceptance_dt.unfair.low = [ ...
    0.24 ... % control
    0.24 ... % depressed
    0.30 ... % ideator
    0.17 ... % low-leth attmp
    0.22];   % high-leth attmp

group_acceptance_dt.unfair.high = [0.26 0.29 0.24 0.32 0.20]; 

% medium fair offers
group_acceptance_dt.medium.low  = [0.31 0.39 0.41 0.27 0.35];
group_acceptance_dt.medium.high = [0.37 0.38 0.37 0.35 0.21];

% fair offers
group_acceptance_dt.fair.low    = [0.88 0.81 0.86 0.79 0.84];
group_acceptance_dt.fair.high   = [0.94 0.85 0.85 0.85 0.79];

% pop. counts
n = [22 35 26 20 26];

% // plot it 
title_txt = {'Very unfair' 'Moderately unfair' 'Fair'}; h = zeros(length(title_txt),1);
field_name = {'unfair' 'medium' 'fair'};
figure('Position',[327 274 1115 473],'PaperPositionMode','auto','PaperOrientation','Landscape');
ph = zeros(length(n),length(title_txt)); % preallocate for figure child attributes handle
for ii = 1:length(title_txt)
    
    data = [ ...
        1-group_acceptance_dt.(field_name{ii}).high; ...
        1-group_acceptance_dt.(field_name{ii}).low ...
    ];
   
    h(ii) = subplot(1,length(title_txt),ii);
    ph(:,ii) = plot(data,'LineWidth',2); 
    title([title_txt{ii} ' offers'],'FontSize',12,'FontWeight','Bold');
    
    xlabel('Stake');
    if(eq(ii,1))
        ylabel('Rejection rate (model estimated mean)','FontSize',12,'FontWeight','Bold');
    end
    
end

% adjust axes properties
min_y = 0.0;
max_y = 0.9;
jitter = 0.2;
plot_window = [1 - jitter, 2 + jitter];
set(h,'XLim',plot_window,'YLim',[min_y max_y]); % extra space on the sides
set(h,'XTick',[1 2]); % set X-tick marks
set(h,'YTick',[min_y:0.1:max_y]);
set(h,'XTickLabel',{'High' 'Low'}); % label XTick's

% complie legend text
group_txt = {...
    'Non-psychiatric controls'; ...    % 1
    'Non-suicidal depressed'; ...      % 2
    'Suicidal ideators'; ...           % 4
    'Low-lethality attempters'; ...    % 6
    'High-lethality attempters'};      % 7
for gii = 1:length(group_txt)
    
    group_txt{gii} = sprintf('%s (n = %d)',group_txt{gii},n(gii));
    
end

legend(group_txt,'Location','NorthEast','FontSize',8);

% % make pretty (adjust colors, line-styles, etc.)
% set(ph(3,:),'color',[0.7 0 0]); % ideators color
% 
% set(ph(5,:),'color',[1 0.2 0.8],'LineStyle','--','LineWidth',3); % high-lethality attempters
% 
% set(ph(4,:),'color',[0.9961 0.7216 0.0],'LineStyle','--','LineWidth',3); % low-lethality attempters
