% Welcome to cal.
% This program was designed as an attempt to at least mimmic, if
% not eventually replace the current calendar and scheduling
% system we have for patients. 
%
% The upside to this system is that we control it. The downside
% is that we are responsible for maintaining it. This should not
% be much of a problem, however, since we must send an email
% requesting and ID assignemet that includes practically
% everything which will go into the calendar. 
%
% Here goes nothing. 
%
% Jan Kalkus
% 2012-09-20

debug_flag = true;

% // Make sure the database is up to date
m = loadAllids('refresh');

