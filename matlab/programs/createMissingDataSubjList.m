function subjs_missing_data=createMissingDataSubjList
%This script is to determine who may be missing NP3 data from our end. At
%the time this was writtne this would be Bandit, Ultimatum Game, and
%Willingness to Wait. 

%Load in the data set
load('C:\kod\Neuropsych_preproc\matlab\tmp\demogs_data.mat');
subj_data=data;

%Grab date index
expression = '^[0-9]+\/[0-9]+\/[0-9]{4}';
date_index=[];
for i = 1:length(subj_data(1,:))
    if ~isa(subj_data{1,i},'char')
        continue
    elseif regexp(subj_data{1,i},expression)==1
        date_index = i;
    end
    
    if ~isempty(date_index)
        break;
    end
end

%Determine which subjects were consented by a certain date? say 2007
date_cut_off = datetime('01-Jan-2007');
dates=datetime(subj_data(:,date_index));
date_filter = dates>date_cut_off;

%Grab the filtered ids
updated_ids = cell2mat(subj_data(date_filter));

%As of writing this the data struct containing bandit and ult data was
%called 'ball'. 
%Create bandit filter
fpath=[pathroot '\analysis\bandit\data\bandit_data.mat'];
bandit_filter=createFilter(updated_ids, fpath);

%Create ultimatum flter
fpath=[pathroot '\analysis\ultimatum\data\UGsummary_data\ball.mat'];
ultimatum_filter=createFilter(updated_ids, fpath);

%Create willingness to wait filter
%As of writing this wtw has a differnt data struct so for the time being
%just make the filter a tad differently
load([pathroot 'analysis\willingness to wait\data\wtw_data.mat'])
wtw_data=struct2cell(wtw_struct);
wtw_ids = cell2mat(wtw_data(1,:))';
wtw_filter = sort(updated_ids(ismember(updated_ids,wtw_ids)));

%Create master filter, these will be all the subjects that have data for
%all 3 games, therefore subjs not on the list are missing data for one or
%more of these games

bandit_ult_filter = bandit_filter(ismember(bandit_filter,ultimatum_filter));

master_filter = bandit_ult_filter(ismember(bandit_ult_filter,wtw_filter));

%These are all the subjects missing 'something' we can further use ismember
%to compute what exactly they are missing
subjs_missing_data = updated_ids(~ismember(updated_ids,master_filter));




function filter=createFilter(master_id_list, path_to_game_data)
a=load(path_to_game_data);
b = fieldnames(a);
try
    filter = master_id_list(ismember(master_id_list,a.(b{1}).id));
catch
    error('Something wrong with either the master struct, file pointer to game id list, or game id list')
end
    
