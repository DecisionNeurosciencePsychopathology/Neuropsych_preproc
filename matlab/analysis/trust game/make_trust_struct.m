function z=make_trust_struct( varargin )
%Script that pulls trust game off of Box, which from what I gather on
%8/15/2016 is the most up to date storage location for trust subjects' data



%There is a bug in which subject 215438 is not appearing in the databasse
%talk to Josh!? 10/4/2016



%NOTE 115438 appear twice remove it

% processes trust game data
data_dir = [pathroot 'analysis/trust game/data/']; % set data path

%grab behavioral and scan ids
behav_ids = grab_ids('E:\Box Sync\Project Trust Game\data\processed\beha_behavior\trust*.mat');
scan_ids = grab_ids('E:\Box Sync\Project Trust Game\data\processed\scan_behavior\trust*.mat');

%Combine the data into a cell
tmp={behav_ids, repmat(cellstr('laptop'),length(behav_ids),1)};
tmp(2,:)={scan_ids, repmat(cellstr('scanner'),length(scan_ids),1)};

%Move to output struct
tg_struct.id = [tmp{1,1}; tmp{2,1}];
tg_struct.versn = [tmp{1,2}; tmp{2,2}];

% Save it
save([data_dir 'trust_data'],'tg_struct');

% varargout
if(nargout), z = tg_struct; end


function ids=grab_ids(file_str)
files = glob(file_str);
ids = regexp(files,'[0-9]{4,6}','match'); %regexp
ids=[ids{:}].';
ids = cellfun(@MatchID,ids(:,1)); %Match them (Thanks Jan!)