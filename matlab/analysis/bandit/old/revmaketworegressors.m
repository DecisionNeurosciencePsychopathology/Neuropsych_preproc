function b=revmaketworegressors(id)
for fnum=1:2
      beach(fnum)=revmakeregressor(id,fnum);
  end
  
b.NumRight=[beach(1).NumRight; beach(2).NumRight; beach(3).NumRight];
b.Running=[beach(1).Running; beach(2).Running; beach(3).Running];
b.showstim_RESP=[beach(1).showstim_RESP; beach(2).showstim_RESP; beach(3).showstim_RESP];
b.showstim_ACC=[beach(1).showstim_ACC; beach(2).showstim_ACC; beach(3).showstim_ACC];
b.firstfive=[beach(1).firstfive beach(2).firstfive beach(3).firstfive]';
b.lastfivegoodtrials=[beach(1).lastfivegoodtrials beach(2).lastfivegoodtrials beach(3).lastfivegoodtrials]';
b.choice=[beach(1).choice beach(2).choice beach(3).choice]';
b.feed1=[beach(1).feed1 beach(2).feed1 beach(3).feed1]';
b.feed2=[beach(1).feed2 beach(2).feed2 beach(3).feed2]';

% %Alex will collate other variables
% 
% % now write to a text file
% cd ('/data/Siegle/alexreversal/matlab')
% %gdlmwrite('rl208510contrasts.regs',[regs.TASKvsREST regs.firstfiveshifted, 1-regs.firstfivetocensor],'\t');
% %gdlmwrite('rl100000contrasts.regs',[regs.TASKvsREST regs.firstfiveshifted, 1-regs.firstfivetocensor regs.firstthreeshifted 1-regs.firstthreetocensor],'\t');
% gdlmwrite(sprintf('rlmodeling%dcontrasts.regs',id),[b.NumRight b.Running b.showstim regs.firstfiveshifted, 1-regs.firstfivetocensor regs.freshifted 1-regs.fretocensor regs.pseshifted 1-regs.psetocensor regs.hishifted 1-regs.hitocensor ],'\t');
% regs.s=s;