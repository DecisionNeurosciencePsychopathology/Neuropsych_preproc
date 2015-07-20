function s=UGproceprimeALL
%processes all subjects' EPrime data on the Ultimatum Game
%convert all to ANSI before running

cd('L:\Summary Notes\Data\Ultimatum Game\Data');
% processes Ultimatum Game data on all subjects
   
a=ls;
a=a(3:end,:); %SWATHI WILL REMOVE KELLEY'S PEOPLE AND DELETE '-2'

numlist=zeros(length(a),1);
for ct=1:length(a)
    numlist(ct)=str2double(a(ct,:));
end
for sub=1:length(numlist)
    s=UGproceprime(numlist(sub));
    
    %get trial-by-trial data for GEE analysis
    
    ball.trial(sub).accept=s.accept;
    ball.trial(sub).fairness=s.fairness; %1=unfair; 2=med, 3=fair
    ball.trial(sub).stake=s.hi; %1=hi, 0=lo
    
    %get behavior
    ball.id(sub)=numlist(sub);
    ball.beh(sub).rrfairhi=s.rrfairhi;
    ball.beh(sub).rrfairlo=s.rrfairlo;
    ball.beh(sub).rrmedhi=s.rrmedhi;
    ball.beh(sub).rrmedlo=s.rrmedlo;
    ball.beh(sub).rrunfairhi=s.rrunfairhi;
    ball.beh(sub).rrunfairlo=s.rrunfairlo;
    
    %get RTs
    ball.beh(sub).medianRTfairhi=s.medianRTfairhi;
    ball.beh(sub).medianRTfairlo=s.medianRTfairlo;
    ball.beh(sub).medianRTmedhi=s.medianRTmedhi;
    ball.beh(sub).medianRTmedlo=s.medianRTmedlo;
    ball.beh(sub).medianRTunfairhi=s.medianRTunfairhi;
    ball.beh(sub).medianRTunfairlo=s.medianRTunfairlo;
    
    %concatenate into data table
    
    ball.data(sub,:)=[ball.id(sub) s.rrfairhi s.rrfairlo s.rrmedhi s.rrmedlo s.rrunfairhi s.rrunfairlo ...
        s.medianRTfairhi s.medianRTfairlo s.medianRTmedhi s.medianRTmedlo s.medianRTunfairhi s.medianRTunfairlo];
end

ball.dirname=sprintf('UGsummary_data_%s',date);
mkdir(ball.dirname)
cd(ball.dirname)
save ball
ball.variables={'id' 'rrfairhi' 'rrfairlo' 'rrmedhi' 'rrmedlo' 'rrunfairhi' 'rrunfairlo' ...
    'medianRTfairhi' 'medianRTfairlo' 'medianRTmedhi' 'medianRTmedlo' 'medianRTunfairhi' 'medianRTunfairlo'};
% save4spss(ball.variables, ball.data, sprintf('UG_data_N=%d_%s',length(numlist), date));
