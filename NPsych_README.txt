Last Modified: 11/10/2014

Neuro_Psych 2 & 3 preprocessing how to:

1) Go to the matlab root dir, this dir needs to contain the folders: db, programs, toolboxes, and work for the NP scripts to run properly. 
Just run remote_startup.m in matlab/work/ <- this will load all the needed paths

2) You may need Psychtoolbox installed specifically the fx UniqueAndN. I did however just copy and paste the fx to programs/utils so I believe this should
just take care of the need to install this toolbox. (I need to test this on another comp)

3) some data files maybe required for scripts to opertate correctly (ie subjects' IDs)

I believe it should be that simple but I'm probably overlooking some detail or didn't change some hard coded path somewhere.

(SPSS load files will need to be modified)