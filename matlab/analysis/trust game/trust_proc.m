function z = trust_proc( varargin )
%Written by: Jon Wilson
%Date: ~10/1/14
%This function is currently written to load in subject ids for LaTeX file
%creation

% processes trust game data
data_dir = [pathroot 'analysis/trust game/data/']; % set data path

% get file pointer. User name will vary.
file = ['C:/Users/wilsonj3/Box Sync/Suicide studies/data/subject list.xlsx']; % set file path

% read in files
[~,~,raw_data] = xlsread(file);

% Proabably a more eloquent way but this will do for meow
% go through IDs
ids = cellfun(@MatchID,raw_data(:,1));

for i = 1:length(ids)
    raw_data{i,1} = ids(i,1); %replace with Matached Ids
end

%in case of any NaN ids
 qnan = ~cellfun(@isnan, raw_data(:,1));
 raw_data = raw_data(qnan,:);

key_data = cell2mat(raw_data(:,1));

%Create duplicate matrix
for i = 1:length(key_data)
    j(:,i) = key_data(i)==key_data(:);
end

%Find the duplicates
dup_idx=find(sum(j)>1);

for i = 1:length(dup_idx)/2
    di=ismember(key_data,key_data(dup_idx(i)));
    duplicates(i,:) = find(di==max(di));
end

for i = 1:size(duplicates,1)
    raw_data{duplicates(i,1),3}=strcat(raw_data{duplicates(i,1),3}, '/',...
        raw_data{duplicates(i,2),3});
    raw_data{duplicates(i,2),1}=NaN;
end

%Clean up NaNs
qnan = ~cellfun(@isnan, raw_data(:,1));
 raw_data = raw_data(qnan,:);

versn = raw_data(:,3);

% Load up struct
tg_struct.id = cell2mat(raw_data(:,1));
tg_struct.versn = versn;

% Save it
save([data_dir 'trust_data'],'tg_struct');

% varargout
if(nargout), z = tg_struct; end

return
