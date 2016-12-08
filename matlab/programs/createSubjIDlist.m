function createSubjIDlist

%3/13/2015 as part of the major overhaul, I've simplified this and made
%updateIDList.m do the heavy lifting this is just a hard coded function that
%will break (possibly) on if the database in the Y drive is changed
%around.

%origin dir
origin = pwd;

if(~isdeployed)
    cd(fileparts(which(mfilename))); %if not in directory, move here
end

%Load in data file
data_file = [pathroot 'tmp\demogs_data.mat'];
load(data_file);


%move to db dir
cd ../db
load('subjIDlistDB.mat')


%Replace and save new ids, hard coded....I know this can lead to trouble
%You could look into passing in the index variable from updateIDList, I
%believe that var has all the header info you'd need to kind of map where
%each of these variables are... just a thought.
subjectIDlistDB.id_number = data.ID;
subjectIDlistDB.consent_date = data.BASELINECONSENTDATE;
subjectIDlistDB.initials = data.INITIALS;
subjectIDlistDB.comment = data.COMMENT;
save subjIDlistDB.mat subjectIDlistDB
cd(origin)