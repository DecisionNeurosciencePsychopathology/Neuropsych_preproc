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

versn = raw_data(:,3);
%version = cell2mat(version);

% Load up struct
tg_struct.id = ids;
tg_struct.versn = versn;

% Save it
save([data_dir 'trust_data'],'tg_struct');

% varargout
if(nargout), z = tg_struct; end

return
