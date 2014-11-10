function p = pathroot( varargin )
% this function returns the path to the 'root' of what
% I use for local matlab files; the returned path will
% depend on which OS and machine this code is running

%I believe this should work for all occasions as long as the name structure
%is not modified (which it shouldn't be!).

if(~isempty(varargin))
	fprintf('Not sure if I will use this/is needed');
end


Jpath  = 'c:/kod/matlab/'; %This is just for my personal(Jon's) comp
if(exist(Jpath,'dir') == 7) 
    p = Jpath;
else 
    sep = filesep; %Grab os specific file separator
    str = pwd;
    k = strfind(str,'matlab');
    p = [str(1:k+5) sep];
end

return
