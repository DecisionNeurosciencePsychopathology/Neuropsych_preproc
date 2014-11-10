% This is used to load the necessary files (custom functions)
%
% It needs to be updated such than anyone can use it to load
% directory tree, i.e., it must recognize on which platform 
% and in which location it is running (e.g., local HD or the
% shared drive) and load the appropriate files using the 
% appropriate directory branches (is available). 
%
% At the moment, this is only setup to run on my (Jan's) 
% local computer.

fprintf('\n\t ----> loading ''main'' directory tree data...\n\n');

% Add paths for general programs
if(ispc)
	if(exist('c:/kod/matlab/','dir') == 7)
		addpath(genpath('c:/kod/matlab/programs/'));
		addpath(genpath('c:/kod/matlab/db/'));
        addpath(genpath('c:/kod/matlab/toolboxs/'));
        addpath('c:/kod/matlab/work/');
    elseif(exist('l:/Summary Notes/Data/matlab/','dir') == 7)
		addpath(genpath('l:/Summary Notes/Data/matlab/programs/'));
		addpath(genpath('l:/Summary Notes/Data/matlab/db/'));
        addpath('l:/Summary Notes/Data/matlab/work/');
	elseif(exist('\\oacres3\llmd\','dir') == 7)
		s = '\\oacres3\llmd\Summary Notes\data\';
		addpath(genpath([s 'matlab/programs/']));
		addpath(genpath([s 'matlab/db/']));
        addpath([s '/matlab/work/']);
	else
		fprintf('can''t find any needed paths\n');
	end
elseif(isunix)
	addpath(genpath('~/kod/matlab/programs/'));
	addpath(genpath('~/kod/matlab/db/'));
    addpath('~/kod/matlab/work/');
end

% Change to working directory
cd(pathroot); clear all;

format short g;
dbstop if error;

