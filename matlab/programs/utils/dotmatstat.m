function x = dotmatstat( varargin )
% Bits and bytes -- will explain later
%
% Jan Kalkus
% 09 Oct 2012

fid = fopen(varargin{:},'r');
fseek(fid,54,'bof');
d.mo = fscanf(fid,'%s',1);
d.dt = fscanf(fid,'%s',1);
fseek(fid,9,0);
d.yr = fscanf(fid,'%s',1);
fclose(fid); 

x = sprintf('%s %s %s',d.mo,d.dt,d.yr);

return