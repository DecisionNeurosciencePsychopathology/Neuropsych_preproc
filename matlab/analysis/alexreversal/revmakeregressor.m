whichfunction b=revmakeregressor(id,filenum)
% make regressors for Alex's reversal task
% usage: revmakeregressor(id,filenum) NB: id uses only the last 5 digits
%  e.g., revmakeregressor(10106,3)

%% Find the eprime file - MODIFY PATHS IF NEEDED
%cd C:\eprime
%convert the 6-digit ID to a 5-digit eprime ID
if id>209999 && id<300000
    id5=sprintf('%d',(id-200000));
elseif id<209999 && id>200999
    id5=sprintf('0%d',(id-200000));
elseif id<200999 && id>200099
    id5=sprintf('00%d',(id-200000));
elseif id<200099 && id>200009
    id5=sprintf('000%d',(id-200000));
elseif id<200009 && id>200000
    id5=sprintf('0000%d',(id-200000));
elseif id<100000
    id5=sprintf('%d',id);
elseif id>109999 && id<200000
    id5=sprintf('%d',(id-100000));
elseif id>880000
    id5=sprintf('%d',(id-800000));
end
    subdir=sprintf('%d',id);
cd(subdir)
if id==209716
    fname=sprintf('alexRevlearnHiLo2-%s-%d.txt',id5,filenum);
else
    fname=sprintf('alexRevlearnHiLo4_one_block-%s-%d.txt',id5,filenum);
end
%%  read in the data
b=readeprime(fname,'trial',{'NumRight','Running','showstim.RESP','showstim.CRESP','showstim.ACC','showstim.OnsetTime','showstim.RT','Valid', 'TrialType'},0,-1,22);
%b.runrevtrial=readeprime(fname,'runrevtrial',{'NumRight', 'Running','showstim.RESP','showstim.ACC','showstim.OnsetTime','showstim.RT','Valid'},0,-1,22);

b.RT=b.showstim_RT;
b.onset=b.showstim_OnsetTime;
%% Need to 
%% Find the reversals
reversals=[];
for ct=1:length(b.Running)-1
  runningstr=char(b.Running(ct)); nextrunningstr=char(b.Running(ct+1));
  if strcmp(char(runningstr(1:end-1)),'OneValid') && strcmp(char(nextrunningstr(1:end-1)),'OneValid');
    reversals=[reversals; ct+1];
  end
end
%% find the first five 
b.firstfive=[];
for ct=1:length(reversals)
   b.firstfive=[b.firstfive reversals(ct):reversals(ct)+4];
end

%% find the blocks where subject reached learning criterion
trialnum=[1:length(b.NumRight)]';
learn=8;
for ct=1:length(reversals-1)
    %first see where they reached learning criterion in blocks before
    %reversals
    learnedafterreversal=find(b.NumRight==learn & trialnum>reversals(ct) & trialnum<(reversals(ct)+25), 1);
    if isempty(learnedafterreversal)==1
        b.pass(ct)=0;
    else
        b.pass(ct)=1;
    end
    b.postcriterion=find(b.NumRight>=learn);
end
for ct=length(reversals)
    %see where they reached learning criterion after the last reversal of
    %the session
    learnedafterreversal=find(b.NumRight==6 & trialnum>reversals(ct), 1);
    if isempty(learnedafterreversal)==1
        b.pass(ct)=0;
    else
        b.pass(ct)=1;
    end
end
b.postcriterion=find(b.NumRight>=learn);

b.blockspassed=sum(b.pass);
    
%l=16 %trial # at first reversal
%p=25 %distance between reversals
%firstfive=[l:(l+4) (l+p):(l+p+4) (l+2*p):(l+2*p+4) (l+3*p):(l+3*p+4) ]
% 
%% find the last five
goodtrials=find((b.NumRight>0) & (b.showstim_ACC>0));
lastfivegoodtrials=[];
for ct=1:length(reversals)
    %goodtrialsbeforereversal=(b.NumRight>0) & (b.showstim_ACC>0) & (trialnum<reversals(ct));
    %let's try a more accurate way of doing this: we'll take correct,
    %non-punished trials only for blocks passed
    goodtrialsbeforereversal=(b.NumRight>4) & (b.showstim_ACC>0) & (trialnum<reversals(ct));
    goodtrialslist=find(goodtrialsbeforereversal);
    %not sure what to do with poorly performing subjects here
    if length(goodtrialslist)>4
         lastfivegoodtrials=[lastfivegoodtrials; goodtrialslist(end-4:end)];
    end
end
b.lastfivegoodtrials=lastfivegoodtrials';


%% based on data, censor first fives that don't have a last five - NOT DONE YET

%find AHA1 (first time subject tries to reverse)
%aha1=[];
%for ct=1:length(reversals)
%    NumRightNext=NumRight(ct+1)
%    if (b.NumRight(ct)=0) & (b.NumRightNext(ct)>0) & (trialnum<reversals(ct)+5)
%    aha1=[aha1; ct+1]
%end

%make regressors for choice and feedback for modeling

%% see if the correct stimulus was on the left or right 
for ct=1:length(b.TrialType)
b.corrleft(ct)=strcmp(b.TrialType(ct), ' BA');
end

%% For blocks that have been aborted or ran too long (v.2 or 3)
if length(b.Running)<139 && length(b.Running)>100
    blocklength=100;
else
    blocklength=length(b.Running);
end
%% which stimulus was reinforced?
b.corrchoice=[];
for ct=1:blocklength
   if b.showstim_CRESP(ct)==2 && b.corrleft(ct)==1
       b.corrchoice(ct)=2;
   elseif b.showstim_CRESP(ct)==7 && b.corrleft(ct)==1
       b.corrchoice(ct)=1;
   elseif b.showstim_CRESP(ct)==2 && b.corrleft(ct)==0
       b.corrchoice(ct)=1;
   elseif b.showstim_CRESP(ct)==7 && b.corrleft(ct)==0
       b.corrchoice(ct)=2;
   end
end
%% Choice
b.choice=[];
for ct=1:blocklength
   if b.showstim_CRESP(ct)==b.showstim_RESP(ct)
       b.choice(ct)=b.corrchoice(ct);
   elseif abs(b.showstim_CRESP(ct)-b.showstim_RESP(ct))==5
       b.choice(ct)=3-b.corrchoice(ct);
   else
       b.choice(ct)=3;
   end
end

%% Feedback for each stimulus
b.feed1=[];
b.feed2=[];
for ct=1:blocklength
    %showstim.ACC: 0=error, 1=correct
   if b.choice(ct)<3
     if (2-b.showstim_ACC(ct))==b.choice(ct)
         b.feed1(ct)=1;
         b.feed2(ct)=2;
     else
         b.feed1(ct)=2;
         b.feed2(ct)=1;
     end
   else
       b.feed1(ct)=999;
       b.feed2(ct)=999;
   end
end
b.responsetrials=find(b.choice<3);
b.goodchoice=find(b.choice(b.responsetrials));
%% Switches
b.switch=[];
b.switchnum=0;
for ct=2:length(b.choice)
       if b.choice(ct)~=b.choice(ct-1) && b.choice(ct)<3
           b.switch(ct)=1;
           b.switchnum=b.switchnum+1;
       elseif b.choice==3
           b.switch(ct)=-999;
       else
           b.switch(ct)=0;
       end
end
%% Probabilistic switches
b.pswitch=[];
b.pswitchnum=0;
for ct=2:blocklength
       if b.choice(ct)~=b.choice(ct-1) && b.Valid(ct-1)==0 && b.choice(ct)<3
           b.pswitch(ct)=1;
           b.pswitchnum=b.pswitchnum+1;
       elseif b.choice==3
           b.pswitch(ct)=-999;
       else
           b.pswitch(ct)=0;
       end
end

%% Probabilistic non-switches (subject gets probabilistic error but stays)
b.pstay=[];
b.pstaynum=0;
for ct=2:blocklength
       if b.choice(ct)==b.choice(ct-1) && b.Valid(ct-1)==0 && b.choice(ct)<3
           b.pstay(ct)=1;
           b.pstaynum=b.pstaynum+1;
       elseif b.choice==3
           b.pstay(ct)=-999;
       else
           b.pstay(ct)=0;
       end
end

%% Spontaneous switches (after chosen stimulus is reinforced)
b.sswitch=[];
b.sswitchnum=0;
for ct=2:blocklength
       if b.choice(ct)~=b.choice(ct-1) && b.Valid(ct-1)==1 && b.showstim_ACC(ct-1)==1 && b.choice(ct)<3;
           b.sswitch(ct)=1;
           b.sswitchnum=b.sswitchnum+1;
       elseif b.choice==3
           b.sswitch(ct)=-999;
       else
           b.sswitch(ct)=0;
       end
end

%% Perseverative errors
b.persev=[];
b.persevnum=0;
b.persev=((b.switch'==0)&(b.NumRight(1:blocklength)==0))';
b.persevnum=sum(b.persev);
%how many perseverative errors do they make in a row?
b.persevcum(1)=0;
for ct=2:length(b.persev)
if b.persev(ct)==1
    b.persevcum(ct)=b.persevcum(ct-1)+1;
else
    b.persevcum(ct)=0;
end
end
b.persevcum=b.persevcum;

%% Percent correct
b.percentcorrect=length(goodtrials)/length(b.responsetrials);

