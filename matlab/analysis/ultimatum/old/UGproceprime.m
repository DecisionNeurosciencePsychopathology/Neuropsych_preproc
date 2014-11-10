function b=UGproceprime(id)
% process behavioral data from the Ultimatum Game
% more details at:
% https://docs.google.com/document/d/1PMKYY8J_ZPp5nxeQGQKNbKiyQF7_rxYskzlLD41n2qU/edit?hl=en&authkey=CPvE6q4J#

%% Find the eprime file - MODIFY PATHS IF NEEDED
cd('L:\Summary Notes\Data\Ultimatum Game\Data');
dir=sprintf('%d',id);
cd(dir)
flist=ls;
fname=flist(4,1:end);


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
% 
% fname=sprintf('vrbl041911-%s-1.txt',id5);

b=readeprime(fname,'TrialProc1',{'Condition', 'Offer.RT', 'Offer.ACC'}, 0,-1,20);
b.RT=b.Offer_RT;
b.accept=b.Offer_ACC;

%convert condition to string
unfairhi=strcmp(' UH', b.Condition);
unfairlo=strcmp(' UL', b.Condition);
fairhi=strcmp(' FH', b.Condition);
fairlo=strcmp(' FL', b.Condition);
bhi=strcmp(' BH', b.Condition);
blo=strcmp(' BL', b.Condition);

fair=(fairhi==1 | fairlo==1);
unfair=(unfairhi==1 | unfairlo==1);
med=(bhi==1 | blo==1);
b.fairness=unfair+2.*med+3.*fair;
hi=(fairhi==1 | unfairhi==1 | bhi==1);
b.hi=hi;
%calculate rejection rates (rr) for each level of fairness and stake size
b.rrfairhi=(sum(b.accept==0 & fairhi==1)./sum(fairhi));
b.rrfairlo=(sum(b.accept==0 & fairlo==1)./sum(fairlo));
b.rrmedhi=(sum(b.accept==0 & bhi==1)./sum(bhi));
b.rrmedlo=(sum(b.accept==0 & blo==1)./sum(blo));
b.rrunfairhi=(sum(b.accept==0 & unfairhi==1)./sum(unfairhi));
b.rrunfairlo=(sum(b.accept==0 & unfairlo==1)./sum(unfairlo));

b.medianRTfairhi=median(b.RT(fairhi==1));
b.medianRTfairlo=median(b.RT(fairlo==1));
b.medianRTmedhi=median(b.RT(bhi==1));
b.medianRTmedlo=median(b.RT(blo==1));
b.medianRTunfairhi=median(b.RT(unfairhi==1));
b.medianRTunfairlo=median(b.RT(unfairlo==1));


b.id=id;

cd('L:\Summary Notes\Data\Ultimatum Game\processed data');
fname=sprintf('UG%d',id);
save(fname);
end

