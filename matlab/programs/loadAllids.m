function A = loadAllids( varargin )
% Hey, we need a description here. How about load all the available ID's
% after the creation of the subject ID list?
%
% Jan Kalkus
% 16 Feb 2012

% arg-check
if(~isempty(varargin) && length(varargin) < 2)
	if(strcmp('refresh',varargin))
		% compile db from latest list
		fprintf('Checking/compiling new DB from list...\n');
		createSubjIDlist;
	else
		warning('MATLAB:loadAllids:ArgCheck','option ''%s'' unrecognized\n',varargin);
	end
elseif(length(varargin) > 1)
	error('MATLAB:loadAllids:ArgCheck','too many arguments');
end

% load the file
A = load([pathroot 'db/subjIDlistDB.mat']);
A = A.subjectIDlistDB;

return