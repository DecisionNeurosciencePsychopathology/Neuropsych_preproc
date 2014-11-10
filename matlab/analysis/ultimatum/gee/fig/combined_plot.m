% Dr. Szanto wanted a combined figure of the two separate figures
% that showed stats. for rejection rate by stake by fairness. 
%
% Jan Kalkus
% 24 Aug 2012

% First, plot rejection rate by stake size, with one plot for
% each level of fairness

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
title_txt = {'Fair' 'Moderately unfair' 'Very unfair'}; h1 = zeros(length(title_txt),1);
field_name = {'fair' 'medium' 'unfair'};
figure('Position',[146 39 1062 855],'PaperPositionMode','auto','PaperOrientation','Landscape');
ph = zeros(length(n),length(title_txt)); % preallocate for figure child attributes handle
for ii = 1:length(title_txt)
    
    data = [ ...
        1-group_acceptance_dt.(field_name{ii}).high; ...
        1-group_acceptance_dt.(field_name{ii}).low ...
        ];
   
    h1(ii) = subplot(2,3,ii+3);
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
set(h1,'XLim',plot_window,'YLim',[min_y max_y]); % extra space on the sides
set(h1,'XTick',[1 2]); % set X-tick marks
set(h1,'YTick',[min_y:0.1:max_y]);
set(h1,'XTickLabel',{'High' 'Low'}); % label XTick's

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

legend(group_txt,'Location','SouthEast','FontSize',7);

% % % % % % % % % %
% Second, plot the other view of the figure

% data from estimated means output by GEE analysis

s.low = [ ...
    0.88 0.81 0.86 0.79 0.84; % fair
    0.31 0.39 0.41 0.27 0.34; % med fair
    0.24 0.24 0.30 0.17 0.22  % unfair
];

s.high = [ ...
    0.94 0.85 0.85 0.85 0.79;
    0.37 0.38 0.37 0.35 0.21;
    0.26 0.29 0.24 0.32 0.20
];

%figure('position',[327 274 1115 473],'paperpositionmode','auto','paperorientation','landscape');
h(1) = subplot(2,3,1.5);
plot(100*(1-s.low),'LineWidth',2);
ylabel('Estimated mean rejection rate (percentage)');
title('Low Stakes','FontSize',12,'FontWeight','Bold');

h(2) = subplot(2,3,2.5);
plot(100*(1-s.high),'LineWidth',2);
title('High Stakes','FontSize',12,'FontWeight','Bold');

leg_txt = { ...
    'Non-psychiatric controls'; ...
    'Non-suicidal depressed'; ...
    'Suicidal ideators'; ...
    'Low-lethality attempters'; ...
    'High-lethality attempters' ...
};

%legend(leg_txt);

% pretty figure settings
min_y = 0;
max_y = 90;
jitter = 0.1;
plot_window = [1 - jitter, 3 + jitter];

set(h,'XLim',plot_window,'YLim',[min_y max_y]);
set(h,'XTick',[1:3]);
set(h,'YTick',[min_y:10:max_y]);
set(h,'XTickLabel',{'Fair' 'Moderately unfair' 'Very  Unfair'});