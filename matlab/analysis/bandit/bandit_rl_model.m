function ball=bandit_rl_model(ball,params,plt)
%% This function is to calculate value from subjects choices given a set
%of parameters alpha lambda(win,loss) and inverse temperature constant Beta

%Take care of initial params
if  numel(params) < 4
    disp('Not enough parameters defaulting to generic values')
    alpha = 0.9;
    lambda_win = 0.3;
    lambda_loss = 0.1;
    beta = 10;
else
    alpha = params(1);
    lambda_win = params(2);
    lambda_loss = params(3);
    beta = params(4);
end

str =sprintf('Parameters values Alpha = %.2f, Lambda Win = %.2f, Lambda Loss = %.2f, Beta = %.2f',...
    alpha, lambda_win, lambda_loss, beta);
disp(str);

%To plot or not to plot
plot_flag =plt;


%% Load  in data if ball doesn't exisit
% try
%     load('c:\kod\Neuropsych_preproc\matlab\analysis\bandit\data\bandit_data.mat')
% catch
%     disp('Can''t find bandit data, please locate the bandit data file')
%     [FileName,PathName,FilterIndex] = ...
%         uigetfile('*.mat','Choose a file');
%     load([PathName FileName]);
% end

%Load design file
design_struct = bandit_tablet_load_design;

%%
trial_length = length(ball.behav(1,1).choice);
v_t1=0.*ones(1,trial_length);
v_t2=0.*ones(1,trial_length);
v_t3=0.*ones(1,trial_length);

v_t1(1)=0;
v_t2(1)=0;
v_t2(1)=0;

Pr1=zeros(1,trial_length);
Pr2=zeros(1,trial_length);
Pr3=zeros(1,trial_length);
delta=zeros(1,trial_length);

gamma = 0.99; % decay param for expected value when not chosen

%%
%Grab subjects choices and run update equations
for i = 1:length(ball.id) %subject Loop
    choice = ball.behav(1,i).choice_numeric;
    r = ball.behav(1,i).stim_ACC;
    choice_hist(:,i) = choice;
    r_hist(:,i) = r;
    best_choice = nan(1,trial_length)';
    best_choice_value = zeros(1,trial_length)';
    lose_switch = nan(1,trial_length)';
    subj_model_predicted = zeros(1,trial_length)';
    for j = 2:trial_length %Begin trial Loop
        
        %Did I win?
        if r(j)>0
            lambda = lambda_win;
        else
            lambda = lambda_loss;
        end
        %v_t(j) = alpha*v_t(j-1) + lambda*(r(j-1) - v_t(j-1));
        
        %Calculate expected value EV(t) = ALPHA*EV(t-1) + LAMBDA*DELTA
        if choice(j)==1
            v_t1(j) = alpha*v_t1(j-1) + lambda*(r(j) - v_t1(j-1));
            v_t2(j) = gamma.*v_t2(j-1);
            v_t3(j) = gamma.*v_t3(j-1);
            delta(j) = r(j) - v_t1(j-1);
        elseif choice(j) ==2
            v_t2(j) = alpha*v_t2(j-1) + lambda*(r(j) - v_t2(j-1));
            v_t1(j) = gamma.*v_t1(j-1);
            v_t3(j) = gamma.*v_t3(j-1);
            delta(j) = r(j) - v_t2(j-1);
        elseif choice(j) ==3
            v_t3(j) = alpha*v_t3(j-1) + lambda*(r(j) - v_t3(j-1));
            v_t1(j) = gamma.*v_t1(j-1);
            v_t2(j) = gamma.*v_t2(j-1);
            delta(j) = r(j) - v_t3(j-1);
        else
            v_t1(j) = v_t1(j-1);
            v_t2(j) = v_t2(j-1);
            v_t3(j) = v_t3(j-1);
            delta(j) = 0;
        end
        
        %% calculate probability of chosing a given stimulus
        Pr1=exp(beta.*(v_t1))./(exp(beta.*(v_t1))+exp(beta.*(v_t2))+ exp(beta.*(v_t3)));
        Pr2=exp(beta.*(v_t2))./(exp(beta.*(v_t1))+exp(beta.*(v_t2))+ exp(beta.*(v_t3)));
        Pr3=exp(beta.*(v_t3))./(exp(beta.*(v_t1))+exp(beta.*(v_t2))+ exp(beta.*(v_t3)));
        
        
        %determine probablistically best choice
        best_choice(Pr1> Pr2 & Pr1> Pr3)=1;
        best_choice(Pr2> Pr1 & Pr2> Pr3)=2;
        best_choice(Pr3> Pr2 & Pr3> Pr1)=3;
        
        %determine value based best choice
        best_choice_value(v_t1> v_t2 & v_t1> v_t3 & v_t1> 0.5)=1;
        best_choice_value(v_t2> v_t1 & v_t2> v_t3 & v_t2> 0.5)=2;
        best_choice_value(v_t3> v_t2 & v_t3> v_t1 & v_t3> 0.5)=3;
        
        %Grab choices so they are easier to reads
        current_choice = choice(j);
        prev_choice = choice(j-1);
        
        %So if at t-1 subj recieved an error while choice(-1) = the best choice
        %(according to the model) and the on the subsequent trial the subject
        %recieved an error again, r(t)=0, and switched their choice, while the
        %previous best choice was still the same, we have a lose switch error.
        if r(j-1)==0 && prev_choice == best_choice_value(j-1);
            if current_choice ~= prev_choice && best_choice_value(j) == best_choice_value(j-1) %&& best_choice_value(j)>0
                lose_switch(j) = 1;
            end
        end
        
        
    end %End trial Loop
    

    
    
    
    %Pr1=exp(beta.*(v_t1))./(exp(beta.*(v_t1))+exp(beta.*(v_t2))+ exp(beta.*(v_t3)));
    %Pr2=exp(beta.*(v_t2))./(exp(beta.*(v_t1))+exp(beta.*(v_t2))+ exp(beta.*(v_t3)));
    %Pr3=exp(beta.*(v_t3))./(exp(beta.*(v_t1))+exp(beta.*(v_t2))+ exp(beta.*(v_t3)));
    
    %determine probablistically best choice
    %     best_choice = nan(1,trial_length)';
    %     best_choice(Pr1> Pr2 & Pr1> Pr3)=1;
    %     best_choice(Pr2> Pr1 & Pr2> Pr3)=2;
    %     best_choice(Pr3> Pr2 & Pr3> Pr1)=3;
    
    subj_model_predicted = (best_choice==choice);    
    
    %% calculate expected value for CHOSEN stimulus (not for model fitting)
    %find the trials where sub chose each stimulus
    chose1=(choice==1);
    chose2=(choice==2);
    chose3=(choice==3);
    echosen=[v_t1.*chose1'+v_t2.*chose2'+v_t3.*chose3']';
    etotal=v_t1+v_t2+v_t3;
    
    
    %% Save each meteric in subject's behavorial struct
    ball.behav(1,i).v_t = [v_t1' v_t2' v_t3'];
    ball.behav(1,i).delta = delta';
    ball.behav(1,i).Prs = [Pr1' Pr2' Pr3'];
    ball.behav(1,i).lose_switch = lose_switch;
    ball.behav(1,i).echosen = echosen;
    ball.behav(1,i).subj_model_predicted = subj_model_predicted;
    
    
    %% Plot some subjects QC check
%     figure(17)
%     clf
    if plot_flag == 1
        
        figure(55)
        clf
        plot(smooth(subj_model_predicted), 'LineWidth',10)
        title('Did subject pick the highest model predicted choice?')
        
        figure(70)
        clf
        smoothie = 20;
        subplot(3,1,1)
        plot(smooth(design_struct.Arew,smoothie), 'r--','LineWidth',2);
        hold on
        plot(smooth(chose1,smoothie), 'b', 'LineWidth',2);
        plot(smooth(v_t1,smoothie), 'k','LineWidth',2);
        axis([0 300 0 1.1])
        title(['Arew vs EV A ' num2str(ball.id(i))]);
        subplot(3,1,2)
        plot(smooth(design_struct.Brew,smoothie), 'r--','LineWidth',2);
        hold on
        plot(smooth(chose2,smoothie), 'b', 'LineWidth',2);
        plot(smooth(v_t2,smoothie), 'k','LineWidth',2);
        axis([0 300 0 1.1])
        title('Brew vs EV B');
        subplot(3,1,3)
        plot(smooth(design_struct.Crew,smoothie), 'r--','LineWidth',2);
        hold on
        plot(smooth(chose3,smoothie), 'b', 'LineWidth',2);
        plot(smooth(v_t3,smoothie), 'k','LineWidth',2);
        axis([0 300 0 1.1])
        title('Crew vs EV C');
        
        input('Press ENTER to continue...');
        
    end
    
    v_t1=0.*ones(1,trial_length);
    v_t2=0.*ones(1,trial_length);
    v_t3=0.*ones(1,trial_length);
    
end %end Subject Loop
tmp=0;

%% get the reward on each trial.
% r=s.feed;% 1=win, 0=loose
%
% for ct=1:length(s.choice)-1
%     %% Calculate the reward/punishment expectancies associated with each stimulus
%     %% On rewarded trials, apply the learning rate for rewards
%     if s.feed(ct)>0
%         if s.choice(ct)==1
%             e1(ct+1)=e1(ct)+ AlphaWin.*(r(ct)-e1(ct));
%             e2(ct+1)=LossDecay.*e2(ct);%-(e1(ct)-e1(ct-1))/2;
%             e3(ct+1)=LossDecay.*e3(ct);%-(e1(ct)-e1(ct-1))/2;
%             delta(ct)=r(ct)-e1(ct);
%         elseif s.choice(ct)==2
%             e2(ct+1)=e2(ct)+ AlphaWin.*(r(ct)-e2(ct));
%             e1(ct+1)=LossDecay.*e1(ct);%-(e2(ct)-e2(ct))/2;
%             e3(ct+1)=LossDecay.*e3(ct);%-(e2(ct)-e2(ct))/2;
%             delta(ct)=r(ct)-e2(ct);
%         elseif s.choice(ct)==3
%             e3(ct+1)=e3(ct)+ AlphaWin.*(r(ct)-e3(ct));
%             e1(ct+1)=LossDecay.*e1(ct);%-(e3(ct)-e3(ct))/2;
%             e2(ct+1)=LossDecay.*e2(ct);%-(e3(ct)-e3(ct))/2;
%             delta(ct)=r(ct)-e3(ct);
%         elseif s.choice(ct)==999 %meaning a no-response trial
%             e1(ct+1)=e1(ct);
%             e2(ct+1)=e2(ct);
%             e3(ct+1)=e3(ct);
%             delta(ct)=0;
%         end
%         %% On punished trials, apply the learning rate for punishments
%
%     elseif s.feed(ct)==0
%         if s.choice(ct)==1
%             e1(ct+1)=e1(ct)+ AlphaLoss.*(r(ct)-e1(ct));
%             e2(ct+1)=WinDecay.*e2(ct);%+(e1(ct)-e1(ct))/2;
%             e3(ct+1)=WinDecay.*e3(ct);%+(e1(ct)-e1(ct))/2;
%             delta(ct)=r(ct)-e1(ct);
%         elseif s.choice(ct)==2
%             e2(ct+1)=e2(ct)+ AlphaLoss.*(r(ct)-e2(ct));
%             e1(ct+1)=WinDecay.*e1(ct);%+(e2(ct)-e2(ct))/2;
%             e3(ct+1)=WinDecay.*e3(ct);%+(e2(ct)-e2(ct))/2;
%             delta(ct)=r(ct)-e2(ct);
%         elseif s.choice(ct)==3
%             e3(ct+1)=e3(ct)+ AlphaLoss.*(r(ct)-e3(ct));
%             e1(ct+1)=WinDecay.*e1(ct);%+(e3(ct)-e3(ct))/2;
%             e2(ct+1)=WinDecay.*e2(ct);%+(e3(ct)-e3(ct-2))/2;
%             delta(ct)=r(ct)-e3(ct);
%         elseif s.choice(ct)==999 %meaning a no-response trial
%             e1(ct+1)=e1(ct);
%             e2(ct+1)=e2(ct);
%             e3(ct+1)=e3(ct);
%             delta(ct)=0;
%         end
%     end
%
%
%
%
%
%
