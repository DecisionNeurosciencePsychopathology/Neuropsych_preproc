function q = damlevdist(a,b)
% This function computes the Damerau-Levenshtein distance
% betweent two character strings, 'a' and 'b'. More notes and
% perhaps some tweaking later. 
%
% Jan Kalkus
% 21 May 2012

if(~ischar(a)), a = num2str(a); end
if(~ischar(b)), b = num2str(b); end

d = zeros(numel(a)+1,numel(b)+1);

d((1:numel(a))+1,1) = 1:numel(a);
d(1,(1:numel(b))+1) = 1:numel(b);

for i = 1:numel(a)
    for j = 1:numel(b)
        
        d(i+1,j+1) = min([ ...
            d(i,j+1) + 1, ... % deletion
            d(i+1,j) + 1, ... % insertion
            d(i,j) + ne(a(i),b(j))] ... % substitution
            );
        
        if( (i > 1 && j > 1) && (eq(a(i),b(j-1)) && eq(a(i-1),b(j))) )
            d(i+1,j+1) = min([ ...
                d(i+1,j+1), ...
                d(i-1,j-1) + ne(a(i),b(j))] ... % transposition
                );
        end
        
    end
end

q = d(end,end);

return
