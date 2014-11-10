function newdata=alexcausfilt(data)
%applies a causal filter with a kernel of [1 1 1], no edge
newdata(1)=data(1);
for i=2:length(data)
    if i==2
    newdata(i)=mean(data(i-1:i));
    elseif i==3
    newdata(i)=mean(data(i-2:i));
    else
    newdata(i)=mean(data(i-3:i));
    end
end

% 
% hi=.8;
% lo=.2;
% prob(1:25)=hi;
% prob(26:50)=lo;
% Eprob=alexcausfilt(prob);
% 
% for ct=1:1000
%     z=rand(size(Eprob));
% if abs(r(Eprob,bestrew))<.01
%     bestrew=z
% end
% 
% 
% for i=1:length(Eprob)
%     if Eprob(i)>.5
%         bestprob(i)=Eprob(i);
%     else bestprob(i)=1-Eprob(i);
%     end
% end
% 
% bestvalue=bestprob.*bestrew;