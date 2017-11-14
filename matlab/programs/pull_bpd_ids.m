function out_ids=pull_bpd_ids
%Function will return ids of raw data files that are in the bsocial protocol
%You should be in the raw directory for this to work

%Load in master file
T = readtable('C:\kod\Neuropsych_preproc\matlab\db\ALL_SUBJECTS_DEMO.xlsx');

%Get all current bpd ids
bpd_ids=T.ID(~cellfun(@isempty,T.B_SOCIAL));

%Get ids present
expression = '\d{4,6}';
subj=dir(pwd);
current_ids=regexp({subj.name},expression,'match')';
current_ids = current_ids(~cellfun(@isempty,current_ids));
current_ids = [current_ids{:}]';
current_ids=str2num(char(current_ids)); %Neat one liner to convert cell of strings to matrix!

%Determine which ids are in bsocial
out_ids=bpd_ids(ismember(bpd_ids,current_ids));
