function oneForAll(varargin)
%FUNCTION_NAME - All encompassing preprocessing script for all Neuropsych data
%This function will run through every preprocessing script for Npysch 2&3
%My hope is that this will streamline the entire process so only this
%function will needed to be run
%
% Syntax:  oneForAll(varargin)
%
% Inputs:
%    input1 - None
%
% Outputs:
%    output1 - All desited matlab data files and SPSS files
%
% Example: 
%  just type oneForAll
%
% Other m-files required: Fill this out later the list will be long
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Jonathan Wilson
% 100 BTowers 
% email: wilsonjt3@chp.edu
% Website: 
% Aug 2014; Last revision: 26-Aug-2014

%------------- BEGIN CODE --------------
%%
% Check the date of the subject list to see if it needs to be updated
% Add a gui here? although this would be redundant if we use the L
% drive/new server as the new data processing hub.
updateIDList;

%Define main directory
main_dir=[pathroot 'analysis']; 

%Run Neuropsych automated data import
nadi


%% Process Bandit Data
cd(main_dir);
cd bandit
%bandit_proc
%bandit_to_spss

%% Process Ult. Data
cd(main_dir)
cd ultimatum
%UGprocorimeALL(1)

%% BART processing???
disp('this is where bart would go');

%% Process WTW Data
cd(main_dir);
cd('willingness to wait');
%wtw_preproc

%% Process Cantab Data
cd(main_dir);
cd cantab
%cantab_proc2

%% Process IOWA Data
cd(main_dir);
cd iowa
%iowa_preproc
%iowa_to_spss

%% Process Prob Rev Data 
cd(main_dir);
cd reversal
%rev_proc
%rev_to_spss
cd(main_dir);

%% Call SPSS run all cmd
cd ..
cd db
!loadAll.sps

%------------- END OF CODE --------------
