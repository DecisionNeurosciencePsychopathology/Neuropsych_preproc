function ball=vrblproceprimefinalALL
cd('C:\regs\bandit');
% processes 3-armed bandit data on all subjects
load IDlist091611
% % create list of subjects defined by directory names
a=ls;
a=a(3:end-1,:);
% b=cellstr(a);
% b=b(3:end);
% sublist=b(1:end-1);
%sublist=cell2mat(sublist(1:end-1));

numlist=zeros(length(a),1);
for ct=1:length(a)
numlist(ct)=str2double(a(ct,:));
end

figure(1); clf;
figure(2); clf;
% % run single-subject proc script on each
for sub=1:length(numlist)
    s=vrblproceprimefinal(numlist(sub));
    ball.id(sub)=numlist(sub);
    ball.beh(sub).choice=s.choice;
    ball.beh(sub).achoice=s.achoice;
    ball.beh(sub).bchoice=s.bchoice;
    ball.beh(sub).cchoice=s.cchoice;
    ball.beh(sub).goodchoice=s.goodchoice;
    ball.beh(sub).RT=s.showstim_RT;
    ball.beh(sub).chosenposition=s.chosenposition;
    ball.achoice(:,sub)=s.achoice;
    ball.bchoice(:,sub)=s.bchoice;
    ball.cchoice(:,sub)=s.cchoice;
    ball.goodchoice(:,sub)=s.goodchoice;
figure(1)
    subplot(5,5,sub)
plot(smooth(ball.beh(sub).achoice, 20),'g'); ylabel 'AvsC'; title(ball.id(sub)); hold;
plot(smooth(ball.beh(sub).cchoice, 20),'b');
plot(smooth(ball.beh(sub).bchoice, 20),'r'); hold off;

figure(2)
    subplot(5,5,sub)
plot(smooth(ball.beh(sub).goodchoice, 20)); axis([1 300 0 1]);
ylabel 'Correct choices';title(ball.id(sub)); hold;


end

figure(3); clf;
plot(smooth(mean(ball.goodchoice(:,IDlist091611(:,2)<5)')))
hold
plot(smooth(mean(ball.goodchoice(:,IDlist091611(:,2)>4)')),'r')



fname=sprintf('bandit-N=%d-%s',length(numlist),date);
save(fname,'ball');
cd('\\oacres3\rcn\pican\studies\suicide\Crdt\processed data')
save(fname,'ball');

return

function b=vrblproceprimefinal(id)
% process behavioral data from variable-schedule 3-armed bandit task
%BE SURE THAT THE .TXT FILE IS ANSI!
% more details at:
% https://docs.google.com/document/d/1PMKYY8J_ZPp5nxeQGQKNbKiyQF7_rxYskzlLD41n2qU/edit?hl=en&authkey=CPvE6q4J#

% % Find the eprime file - MODIFY PATHS IF NEEDED
cd('C:\regs\bandit');
%cd('\\oacres3\rcn\pican\studies\suicide\Crdt\Eprime data');
%convert the 6-digit ID to a 5-digit eprime ID
% if id>209999 && id<300000
%     id5=sprintf('%d',(id-200000));
% elseif id<209999 && id>200999
%     id5=sprintf('0%d',(id-200000));
% elseif id<200999 && id>200099
%     id5=sprintf('00%d',(id-200000));
% elseif id<200099 && id>200009
%     id5=sprintf('000%d',(id-200000));
% elseif id<200009 && id>200000
%     id5=sprintf('0000%d',(id-200000));
% elseif id<100000
%     id5=sprintf('%d',id);
% elseif id>109999 && id<200000
%     id5=sprintf('%d',(id-100000));
% end
id=sprintf('%d',id);
cd(id);

%fname=sprintf('Bandit_vrbl_052411_USE_THIS_ONE-%s-1.txt',id5);
fname=ls('*txt');
% %  read in the data
b=readeprime(fname,'trialproc',{'showstim.RESP', 'showstim.RT', 'showstim.ACC'}, 0,-10,10);
%b.id=id;

% % recode chosenposition numerically, counterclockwise 1=top, 2=left,
% % 3=right

choiceright=strcmp(b.showstim_RESP, ' right')+strcmp(b.showstim_RESP,' {RIGHTARROW}');
choiceleft=strcmp(b.showstim_RESP, ' left')+strcmp(b.showstim_RESP,' {LEFTARROW}');
choicetop=strcmp(b.showstim_RESP, ' top')+strcmp(b.showstim_RESP,' {UPARROW}');
b.chosenposition=choicetop+2.*choiceleft+3.*choiceright;
% % get our design file
cd('\\oacres3\rcn\pican\studies\suicide\Crdt\processed data');
load designwithaposition.mat
chosenposition=b.chosenposition;
b.achoice=chosenposition==aposition;
b.bchoice=chosenposition==bposition;
b.cchoice=chosenposition==cposition;
b.choice=b.achoice+2.*b.bchoice+3.*b.cchoice;

% % find Hsch - stimulus with objectively highest reward probability, based
% % on a 10-trial moving average
aprob10=zeros(300,1);
for ct=1:10
aprob10(ct)=mean(arew(1:ct));
end
for ct=11:300
aprob10(ct)=mean(arew(ct-10:ct));
end

bprob10=zeros(300,1);
for ct=1:10
bprob10(ct)=mean(brew(1:ct));
end
for ct=11:300
bprob10(ct)=mean(brew(ct-10:ct));
end

cprob10=zeros(300,1);
for ct=1:10
cprob10(ct)=mean(crew(1:ct));
end
for ct=11:300
cprob10(ct)=mean(crew(ct-10:ct));
end

Hsch=zeros(300,1);
for ct=1:300
prob=[aprob10(ct), bprob10(ct), cprob10(ct)];
maxprob=max(prob);
if maxprob==prob(1)
    Hsch(ct)=1;
  
end
if maxprob==prob(2)
    Hsch(ct)=2;
end
if maxprob==prob(3)
    Hsch(ct)=3;
end
end

b.goodchoice=zeros(300,1);
for ct=1:300
    if b.choice(ct)==Hsch(ct)
        b.goodchoice(ct)=1;
    else b.goodchoice(ct)=0;
    end
end

% figure(1)
% plot(smooth(b.achoice, 20),'g'); ylabel 'AvsC'; title(id); hold;
% plot(smooth(b.cchoice, 20),'b');
% plot(smooth(b.bchoice, 20),'r'); hold off;
% 
% figure (2)
% plot(smooth(b.goodchoice, 20)); ylabel 'Correct choices'

% % will later add RL model-estimated most-rewarding stimulus


% % save ss regs for each subject

cd('\\oacres3\rcn\pican\studies\suicide\Crdt\processed data');
% gdlmwrite(sprintf('discount%d.regs',s.ID(snum)),[s.hrfregs(snum).task' ... %0
%     s.regsshifted(snum).first5' s.tocensorshifted(snum).first5' ... % 1 2 first five
%     s.regsshifted(snum).e1' s.regsshifted(snum).task' ... % 3 4 stimulus 1 value
%     s.regsshifted(snum).goodvalue' ... %5 selected stimulus value
%     s.regsshifted(snum).NumRight' ...%6 consecutive correct
%     s.regsshifted(snum).pswitch' s.tocensorshifted(snum).pswitch' ... % 7 8 probabilistic switch errors
%     s.regsshifted(snum).persev' s.tocensorshifted(snum).persev' ...% 9 10 perseverative errors
%     s.regsshifted(snum).prob1' ... % 11 probability of model choice for stim 1
%     s.regsshifted(snum).goodprob' ... % 12 probability of model choice for selected stimulus
%     s.regsshifted(snum).feed' ... % 13 feedback (correct vs. incorrect)
%     s.regsshifted(snum).delta'],'\t'); % 14 prediction error (delta)
% savefname=sprintf('%s',id);
% save(savefname, 'b');
end


return