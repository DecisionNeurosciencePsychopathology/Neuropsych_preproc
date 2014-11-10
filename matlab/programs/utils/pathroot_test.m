function p = pathroot( varargin )
% this function returns the path to the 'root' of what
% I use for local matlab files; the returned path will
% depend on which OS and machine this code is running

% TODO
% varargin is tacked onto the end of the root path to return a
% full path, if subsequent path is valid

if(~isempty(varargin))
	fprintf('Ignorning ''varargin'' (feature not yet implemented)\n');
end

% function handle for errors
if(isunix)
	er3po = @(x) error('MATLAB:pathroot:DirNotFound','No access to root dirs');
elseif(ispc)
	er3po = @(~) error('MATLAB:pathroot:DirNotFound','No access to root dirs');
end

% determine base of root filepath from current platform
if(ispc)

	Ldrive = '//oacres3/llmd/Summary Notes/honza/kod/matlab/';
	Jpath  = 'c:/kod/matlab/';
	stickp = 'e:/kod/matlab/';

	if(strncmp(pwd,'e:\kod\matlab',13))
		p = stickp;
	elseif(exist(Jpath,'dir') == 7)
		p = Jpath;
	elseif(exist(Ldrive,'dir') == 7)
		p = Ldrive;
	else
		er3po(1);
	end

elseif(isunix)
	
	if(exist('/media/disk/kod/','dir') == 7)% good ol' ArchLinux
		if(exist('/media/disk/kod/matlab/','dir'))
			p = '/media/disk/kod/matlab/';
		else
			er3po(1);
		end
	elseif(exist('~/kod/matlab/','dir') == 7) % last resort
		if(exist('~/kod/matlab/','dir'))
			p = '~/kod/matlab/';
		else
			er3po(1);
		end
	else
		er3po(1);
	end

else
	error('MATLAB:pathroot:unrecognizedMach','What OS are you running?');
end

return
