function J = JaccardIndex(a,b)

if(isnumeric(a)), a = num2str(a); end
if(isnumeric(b)), b = num2str(b); end

J = length(intersect(a,b))/length(union(a,b));

return
