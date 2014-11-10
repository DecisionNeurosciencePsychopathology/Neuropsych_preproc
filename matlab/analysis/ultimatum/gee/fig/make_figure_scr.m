% This is a script to create figures based on the rejection (and
% acceptance) rates for subjects in the GEE analysis. 
%
% NB: this is a quick script, it is not very dynamic; it would be
% a good idea to turn this into a function that can produce
% results with minimal user interaction. 
%
% Jan Kalkus
% 24 Apr 2012

% get ids for specific subset of subjects
s = load('data/GEEdata60+.mat');
% valid_ids = unique(s.data_struc.geedata(:,1));

% actually only want to use 85 subjects from original analysis 
t = load([pathroot 'db/original_85_UG_analysis_ids.mat']);
valid_ids = t.ids_old;

% get group number by ID
group_num = zeros(size(valid_ids));
for idii = valid_ids'
    
    x = s.data_struc.geedata; % less work (for me)
    q = ( valid_ids == idii ); % index
    group_num(q) = unique(x(x(:,1) == idii,2)); % group num. for given ID
    
end

% load UG data file
fpath = [pathroot 'analysis/ultimatum/data/UGsummary_data_12-Apr-2012/ball.mat'];
load(fpath);
    
% get data for each group
for groupjj = unique(group_num)'
    
    % prepare variables
    ids_in_group = valid_ids(group_num == groupjj);
    gfdname = sprintf('group%d',groupjj);
    count = 1;
    
    for idskk = ids_in_group'
        
        % index of current ID in 'ball' structure
        qid = ( ball.id == idskk );
        
        for stakemm = {'hi' 'lo'}
            
            % output field name
            foname = sprintf('%sStake',stakemm{:});
            
            for fairnn = {'fair' 'med' 'unfair'}
                
                % retreive data from 'ball' structure
                finame = sprintf('rr%s%s',fairnn{:},stakemm{:});
                fair_struc.(gfdname).(foname).(fairnn{:})(count,1) = ball.beh(qid).(finame);
                
            end
        end

        count = count + 1; % heterogeneous group sample sizes

    end
end
        
% average data
group_types = unique(group_num);
for jj = {'unfair' 'med' 'fair'}
    for kk = 1:length(group_types)

        gname = sprintf('group%d',group_types(kk)); % group/field name
        
        a = fair_struc.(gname).hiStake.(jj{:}); % hight stake
        b = fair_struc.(gname).loStake.(jj{:}); % low stake
        
        rejrt.(jj{:})(kk,1:2) = [mean(a), mean(b)]; % mean rejection rates

    end
end

% plot it
title_txt = {'Unfair' 'Medium' 'Fair'}; h = zeros(3,1);
field_name = {'unfair' 'med' 'fair'};
figure('Position',[327 274 1115 473],'PaperPositionMode','auto','PaperOrientation','Landscape');
ph = zeros(5,3); % preallocate for figure child attributes handle
for ii = 1:3
   
    h(ii) = subplot(1,3,ii);
    ph(:,ii) = plot(rejrt.(field_name{ii})','LineWidth',2); 
    title([title_txt{ii} ' offers'],'FontSize',12,'FontWeight','Bold');
    
    xlabel('Stake');
    if(eq(ii,1))
        ylabel('Rejection rate','FontSize',12,'FontWeight','Bold');
    end
    
end

% adjust axes properties
jitter = 0.2;
plot_window = [1 - jitter, 2 + jitter];
set(h,'XLim',plot_window,'YLim',[0 0.9]); % extra space on the sides
set(h,'XTick',[1 2]); % set X-tick marks
set(h,'XTickLabel',{'High' 'Low'}); % label XTick's

% complie legend text
group_txt = {'Controls'; ...           % 1
    'Depressed'; ...                   % 2
    'Ideators'; ...                    % 4
    'Low-lethality attempters'; ...    % 6
    'High-lethality attempters'};      % 7
for gii = 1:length(group_types)
    
    n = sum(group_num == group_types(gii));
    group_txt{gii} = sprintf('%s (n = %d)',group_txt{gii},n);
    
end

legend(group_txt,'Location','NorthEast','FontSize',8);

% % make pretty (adjust colors, line-styles, etc.)
% set(ph(3,:),'color',[0.7 0 0]); % ideators color
% 
% set(ph(5,:),'color',[1 0.2 0.8],'LineStyle','--','LineWidth',3); % high-lethality attempters
% 
% set(ph(4,:),'color',[0.9961 0.7216 0.0],'LineStyle','--','LineWidth',3); % low-lethality attempters
