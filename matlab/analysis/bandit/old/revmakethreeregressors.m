function b=revmakethreeregressors(id)
%Makes regressors for all blocks of the PRL scanner task.
%Also handles subjects who only completed part of the task or had
%an unusual number of blocks.

%% for sub who had one 300-trial block, v.3 of the task
if id==115251
b=revmakeregressor115251(115251,1);
b.NumRight=b.NumRight';
b.corrchoice=b.corrchoice';
b.feed1=b.feed1';
b.feed2=b.feed2';
b.responsetrials=b.responsetrials';
b.goodchoice=b.goodchoice';
b.switch=b.switch';
b.pswitch=b.pswitch';
b.sswitch=b.sswitch';
b.pstay=b.pstay';
b.persev=b.persev';
b.persevcum=b.persevcum';
b.firstfive=b.firstfive';
b.lastfivegoodtrials=b.lastfivegoodtrials';
b.RT=b.RT;
b.onset=b.onset;
%% for sub who had 2 (138 trials, first 100 usable) and 3 (100 trials) but not 1
elseif id==209716
   for fnum=[2 3]
   beach(fnum)=revmakeregressor(id,fnum);
   end
   %actually did 238/300 trials, 9/12 blocks
   b.blockspassed=(beach(2).blockspassed + beach(3).blockspassed)*12/9;
    b.NumRight=[beach(2).NumRight(1:100); beach(3).NumRight(1:100)]';
    b.Running=[beach(2).Running(1:100); beach(3).Running(1:100)];
    b.showstim_RESP=[beach(2).showstim_RESP(1:100); beach(3).showstim_RESP(1:100)];
    b.showstim_ACC=[beach(2).showstim_ACC(1:100); beach(3).showstim_ACC(1:100)];
    b.firstfive=[beach(2).firstfive(1:20) (beach(3).firstfive+100)]';
    %just for this subject, who had 3 good blocks of lastfive
    b.lastfivegoodtrials=[beach(2).lastfivegoodtrials(1:15) beach(3).lastfivegoodtrials+100]';
    b.choice=[beach(2).choice(1:100) beach(3).choice ]';
    b.feed1=[beach(2).feed1(1:100) beach(3).feed1]';
    b.feed2=[beach(2).feed2(1:100) beach(3).feed2]';
    b.responsetrials=[beach(2).responsetrials(1:100) beach(3).responsetrials(1:100)+100]';
    b.switch=[beach(2).switch(1:100) beach(3).switch]';
    b.switchnum=300/238.*(beach(2).switchnum+beach(3).switchnum);
    b.switchnum2=beach(2).switchnum;
    b.switchnum3=beach(3).switchnum;
    b.pswitch=[beach(2).pswitch(1:100) beach(3).pswitch(1:100)]';
    b.pswitchnum=300/238.*(beach(2).pswitchnum+beach(3).pswitchnum);
    b.pswitchnum2=beach(2).pswitchnum;
    b.pswitchnum3=beach(3).pswitchnum;
    
    b.sswitch=[beach(2).sswitch(1:100) beach(3).sswitch(1:100)]';
    b.sswitchnum=300/238.*(beach(2).sswitchnum+beach(3).sswitchnum);
    b.sswitchnum2=beach(2).sswitchnum;
    b.sswitchnum3=beach(3).sswitchnum;
    
    b.pstay=[beach(2).pstay(1:100) beach(3).pstay(1:100)]';
    b.pstaynum=300/238.*(beach(2).pstaynum+beach(3).pstaynum);
    b.pstaynum2=beach(2).pstaynum;
    b.pstaynum3=beach(3).pstaynum;
    
    b.percentcorrect=mean([beach(2).percentcorrect beach(3).percentcorrect]);
    b.percentcorrect2=beach(2).percentcorrect;
    b.percentcorrect3=beach(3).percentcorrect;
    b.persev=[beach(2).persev(1:100) beach(3).persev(1:100)]';
    b.persevnum=300/238*(beach(2).persevnum+beach(3).persevnum);
    b.persevnum2=beach(2).persevnum;
    b.persevnum3=beach(3).persevnum;
    b.persevcum=[beach(2).persevcum beach(3).persevcum]';
    b.RT=[beach(2).RT(1:100);beach(3).RT]';
    b.onset=[beach(2).onset(1:100);beach(3).onset]';
        %% for sub who had 1 (X200 trials) and 3 (X100 trials)
elseif id==208401 || id==212317 || id==208510
   for fnum=[1 3]
   beach(fnum)=revmakeregressor(id,fnum);
   end
    b.blockspassed=(beach(1).blockspassed + beach(3).blockspassed);     
    b.NumRight=[beach(1).NumRight(1:200); beach(3).NumRight]';
    b.Running=[beach(1).Running(1:200); beach(3).Running];
    b.showstim_RESP=[beach(1).showstim_RESP(1:200); beach(3).showstim_RESP];
    b.showstim_ACC=[beach(1).showstim_ACC(1:200); beach(3).showstim_ACC];
    b.firstfive=[beach(1).firstfive beach(3).firstfive+200]';
    b.lastfivegoodtrials=[beach(1).lastfivegoodtrials beach(3).lastfivegoodtrials+200]';
    b.choice=[beach(1).choice(1:200) beach(3).choice ]';
    b.feed1=[beach(1).feed1(1:200) beach(3).feed1]';
    b.feed2=[beach(1).feed2(1:200) beach(3).feed2]';
    b.responsetrials=[beach(1).responsetrials beach(3).responsetrials+200]';
    b.switch=[beach(1).switch(1:200) beach(3).switch]';
    b.switchnum=(beach(1).switchnum+beach(3).switchnum);
    b.switchnum1=beach(1).switchnum;
    b.switchnum3=beach(3).switchnum;
    b.pswitch=[beach(1).pswitch(1:200) beach(3).pswitch]';
    b.pswitchnum=(beach(1).pswitchnum+beach(3).pswitchnum);
    b.pswitchnum1=beach(1).pswitchnum;
    b.pswitchnum3=beach(3).pswitchnum;
    
    b.sswitch=[beach(1).sswitch(1:200) beach(3).sswitch]';
    b.sswitchnum=(beach(1).sswitchnum+beach(3).sswitchnum);
    b.sswitchnum1=beach(1).sswitchnum;
    b.sswitchnum3=beach(3).sswitchnum;
    
    b.pstay=[beach(1).pstay(1:200) beach(3).pstay]';
    b.pstaynum=(beach(1).pstaynum+beach(3).pstaynum);
    b.pstaynum1=beach(1).pstaynum;
    b.pstaynum3=beach(3).pstaynum;
    
    
    b.percentcorrect=mean([beach(1).percentcorrect beach(3).percentcorrect]);
    b.percentcorrect1=beach(1).percentcorrect;
    b.percentcorrect3=beach(3).percentcorrect;
    b.persev=[beach(1).persev(1:200) beach(3).persev]';
    b.persevnum=(beach(1).persevnum+beach(3).persevnum);
    b.persevnum1=beach(1).persevnum;
    b.persevnum3=beach(3).persevnum;
    b.persevcum=[beach(1).persevcum(1:200) beach(3).persevcum]';
    b.RT=[beach(1).RT;beach(3).RT]';
    b.onset=[beach(1).onset;beach(3).onset]';
%%  for sub who had 1 (x200) and 2 (X100) 
elseif id==209237
   for fnum=1:2
   beach(fnum)=revmakeregressor(id,fnum);
   end
   b.blockspassed=(beach(1).blockspassed + beach(2).blockspassed);
   b.NumRight=[beach(1).NumRight; beach(2).NumRight]';
    b.Running=[beach(1).Running; beach(2).Running];
    b.showstim_RESP=[beach(1).showstim_RESP; beach(2).showstim_RESP];
    b.showstim_ACC=[beach(1).showstim_ACC; beach(2).showstim_ACC];
    b.firstfive=[beach(1).firstfive (beach(2).firstfive+200)]';
    b.lastfivegoodtrials=[beach(1).lastfivegoodtrials beach(2).lastfivegoodtrials+200]';
    b.choice=[beach(1).choice beach(2).choice ]';
    b.feed1=[beach(1).feed1 beach(2).feed1]';
    b.feed2=[beach(1).feed2 beach(2).feed2]';
    b.responsetrials=[beach(1).responsetrials beach(2).responsetrials+200]';
    b.switch=[beach(1).switch beach(2).switch]';
    b.switchnum=(beach(1).switchnum+beach(2).switchnum);
    b.switchnum1=beach(1).switchnum;
    b.switchnum2=beach(2).switchnum;
    b.pswitch=[beach(1).pswitch beach(2).pswitch]';
    b.pswitchnum=(beach(1).pswitchnum+beach(2).pswitchnum);
    b.pswitchnum1=beach(1).pswitchnum;
    b.pswitchnum2=beach(2).pswitchnum;

    b.pstay=[beach(1).pstay beach(2).pstay]';
    b.pstaynum=(beach(1).pstaynum+beach(2).pstaynum);
    b.pstaynum1=beach(1).pstaynum;
    b.pstaynum2=beach(2).pstaynum;
        
    b.sswitch=[beach(1).sswitch beach(2).sswitch]';
    b.sswitchnum=(beach(1).sswitchnum+beach(2).sswitchnum);
    b.sswitchnum1=beach(1).sswitchnum;
    b.sswitchnum2=beach(2).sswitchnum;
    
    b.percentcorrect=mean([beach(1).percentcorrect beach(2).percentcorrect]);
    b.percentcorrect1=beach(1).percentcorrect;
    b.percentcorrect2=beach(2).percentcorrect;
    b.persev=[beach(1).persev beach(2).persev]';
    b.persevnum=(beach(1).persevnum+beach(2).persevnum);
    b.persevnum1=beach(1).persevnum;
    b.persevnum2=beach(2).persevnum;
    b.persevcum=[beach(1).persevcum beach(2).persevcum]';
    b.RT=[beach(1).RT;beach(2).RT]';
    b.onset=[beach(1).onset;beach(2).onset]';
%% for all subjects with complete data
else
   for fnum=1:3
   beach(fnum)=revmakeregressor(id,fnum);
   end
    b.blockspassed=beach(1).blockspassed + beach(2).blockspassed + beach(3).blockspassed;     
%     b.NumRight=[beach(1).NumRight(1:100); beach(2).NumRight(1:100); beach(3).NumRight(1:100)]';
%     b.Running=[beach(1).Running(1:100); beach(2).Running(1:100); beach(3).Running(1:100)];
%     b.showstim_RESP=[beach(1).showstim_RESP(1:100); beach(2).showstim_RESP(1:100); beach(3).showstim_RESP(1:100)];
%     b.showstim_ACC=[beach(1).showstim_ACC; beach(2).showstim_ACC; beach(3).showstim_ACC];

    b.NumRight=[beach(1).NumRight; beach(2).NumRight; beach(3).NumRight]';
    b.Running=[beach(1).Running; beach(2).Running; beach(3).Running];
    b.showstim_RESP=[beach(1).showstim_RESP; beach(2).showstim_RESP; beach(3).showstim_RESP];
    b.showstim_ACC=[beach(1).showstim_ACC; beach(2).showstim_ACC; beach(3).showstim_ACC];

    b.firstfive=[beach(1).firstfive (beach(2).firstfive+100) (beach(3).firstfive+200)]';
    b.lastfivegoodtrials=[beach(1).lastfivegoodtrials beach(2).lastfivegoodtrials+100 beach(3).lastfivegoodtrials+200]';
    b.choice=[beach(1).choice beach(2).choice beach(3).choice]';
    b.feed1=[beach(1).feed1 beach(2).feed1 beach(3).feed1]';
    b.feed2=[beach(1).feed2 beach(2).feed2 beach(3).feed2]';
    b.responsetrials=[beach(1).responsetrials beach(2).responsetrials+100 beach(3).responsetrials+200]';
    b.switch=[beach(1).switch beach(2).switch beach(3).switch]';
    b.switchnum=beach(1).switchnum+beach(2).switchnum+beach(3).switchnum;
    b.switchnum1=beach(1).switchnum;
    b.switchnum2=beach(2).switchnum;
    b.switchnum3=beach(3).switchnum;
    b.pswitch=[beach(1).pswitch beach(2).pswitch beach(3).pswitch]';
    b.pswitchnum=beach(1).pswitchnum+beach(2).pswitchnum+beach(3).pswitchnum;
    b.pswitchnum1=beach(1).pswitchnum;
    b.pswitchnum2=beach(2).pswitchnum;
    b.pswitchnum3=beach(3).pswitchnum;
    
    b.sswitch=[beach(1).sswitch beach(2).sswitch beach(3).sswitch]';
    b.sswitchnum=beach(1).sswitchnum+beach(2).sswitchnum+beach(3).sswitchnum;
    b.sswitchnum1=beach(1).sswitchnum;
    b.sswitchnum2=beach(2).sswitchnum;
    b.sswitchnum3=beach(3).sswitchnum;

    b.pstay=[beach(1).pstay beach(2).pstay beach(3).pstay]';
    b.pstaynum=beach(1).pstaynum+beach(2).pstaynum+beach(3).pstaynum;
    b.pstaynum1=beach(1).pstaynum;
    b.pstaynum2=beach(2).pstaynum;
    b.pstaynum3=beach(3).pstaynum;
    
    b.percentcorrect=mean([beach(1).percentcorrect beach(2).percentcorrect beach(3).percentcorrect]);
    b.percentcorrect1=beach(1).percentcorrect;
    b.percentcorrect2=beach(2).percentcorrect;
    b.percentcorrect3=beach(3).percentcorrect;
    b.persev=[beach(1).persev beach(2).persev beach(3).persev]';
    b.persevnum=beach(1).persevnum+beach(2).persevnum+beach(3).persevnum;
    b.persevnum1=beach(1).persevnum;
    b.persevnum2=beach(2).persevnum;
    b.persevnum3=beach(3).persevnum;
    b.persevcum=[beach(1).persevcum beach(2).persevcum beach(3).persevcum]';
    b.RT=[beach(1).RT;beach(2).RT;beach(3).RT]';
    b.onset=[beach(1).onset;beach(2).onset;beach(3).onset]';
end
b.NumRight=b.NumRight';
%%    
% figure(1);
% subplot(5,1,1); plot(b.NumRight); hold on; plot(b.persevcum, 'r') %title('%d-ConsecutiveCorrect',id); 
% subplot(5,1,2); plot(b.switch); %title('switch');
% %subplot(5,1,3); plot(b.persevcum);% title('CumulativePerseverativeErrors');
% subplot(5,1,4); barh(b.percentcorrect); axis([0 1 0 1]); xlabel 'PercentCorrect';
% subplot(5,1,5); barh(b.pswitchnum); axis([0 100 0 1]); xlabel 'ProbabilisticSwitches';


% %Alex will collate other variables
% 
% % now write to a text file
% cd ('/data/Siegle/alexreversal/matlab')
% %gdlmwrite('rl208510contrasts.regs',[regs.TASKvsREST regs.firstfiveshifted, 1-regs.firstfivetocensor],'\t');
% %gdlmwrite('rl100000contrasts.regs',[regs.TASKvsREST regs.firstfiveshifted, 1-regs.firstfivetocensor regs.firstthreeshifted 1-regs.firstthreetocensor],'\t');
% gdlmwrite(sprintf('rlmodeling%dcontrasts.regs',id),[b.NumRight b.Running b.showstim regs.firstfiveshifted, 1-regs.firstfivetocensor regs.freshifted 1-regs.fretocensor regs.pseshifted 1-regs.psetocensor regs.hishifted 1-regs.hitocensor ],'\t');
% regs.s=s;