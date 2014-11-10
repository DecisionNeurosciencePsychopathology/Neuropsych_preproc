function mv( varargin )
% My attempt to duplicate the UNIX/Linux 'mv' program as well as
% DOS's MOVE command. I just want a way to move files from MATLAB
%
% Jan Kalkus
% 03 Oct 2012

% 29 Oct 2012
% apparently there is already a function for this called
% 'copyfile' --> work on migrating to thin instead

% this command apparently works on M$ as well
[s w] = unix(['mv -i ' sprintf('%s ',varargin{:})]);

% non-zero exit status means there was an error
if(s), warning('MATLAB:mv:errrr','%s\n',w); end
    
return