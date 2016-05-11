function [r,p] = nancorrcoef(x,y)

[r,p] = corrcoef(x,y,'rows','complete');

return
