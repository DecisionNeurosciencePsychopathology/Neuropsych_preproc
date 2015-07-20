function corrplot(x,y,s)

[r,p] = nancorrcoef(x,y);
plot(x,y,'.'); lsline;

t = sprintf('r = %2.2f (p = %2.2g)',r(2),p(2));

if(nargin > 2 && ~isempty(t))
    t = sprintf('%s\nr = %2.2f (p = %2.2g)',s,r(2),p(2));
end
    
title(t);

return
