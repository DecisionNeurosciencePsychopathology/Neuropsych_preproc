% This is used to load the necessary files (custom functions)
%
%So until I figure out a more clever way to load in the needed dirs/subdirs
%I propose this solution, running this script in the ..kod/matlab dir
%should add the needed paths to do NP preproc.
%Written by: Jonathan Wilson/Jan Kalkus
%Created: 11/10/2014

fprintf('\n\t ----> loading ''main'' directory tree data...\n\n');

% Add paths for general programs
root = pwd;
if strcmp(root(end-5:end),'matlab')
    fprintf('\n\t found root dir! \n\n');
elseif strcmp(root(end-3:end),'work')
    fprintf('\n\t found root dir! \n\n');
    cd ..
    root = pwd;
else
    fprintf('Can''t find preproc root please find the dir in README');
    root = uigetdir; %have user grab directory 
end

% just as a double check to make sure we're in the right place
dir_names = dir(root);
for i = 1:length(dir_names)
    checker(i,:)=strcmp(dir_names(i).name,'analysis');
end

if ~any(checker)
    error('No analysis dir found, please consult README')
end
    
%add needed paths
addpath(genpath(fullfile(root, 'programs')));
addpath(genpath(fullfile(root, 'db')));
addpath(genpath(fullfile(root, 'toolboxs')));
addpath(fullfile(root, 'work'));


% Change to working directory
cd(root); clear all;

format short g;
dbstop if error;

