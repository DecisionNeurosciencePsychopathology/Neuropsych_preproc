function h = hash(A,p)

if(~exist('p','var') || isempty(p))
	p = 8;
end

if(~isnumeric(A))
	A = double(A);
end


hash = 0;
for n = 1:size(A,1)
	for m = 1:size(A,2)
		hash = p*hash+A(n,m);
	end
end

h = hash; 

return
