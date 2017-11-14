function z = trust_proc( varargin )
%Written by: Jon Wilson
%Date: ~10/1/14
%This function is currently written to load in subject ids for LaTeX file
%creation

%------Add some way that you update the file from box!-----%

%Add code here

%----------------------------------------------------------%


%NEED to rewrite this as the xlsx file has changed format, ProTip grab
%sheet name, if behave == laptop, if scanner =  scanner. Adjust code as
%need be...

% processes trust game data
data_dir = [pathroot 'analysis/trust game/data/']; % set data path

% get file pointer. User name will vary.
%file = ['C:/Users/wilsonj3/Box Sync/Suicide studies/data/subject list.xlsx']; % set file path
%5/7/15 So just update this file from box whenever you want to run this
%script???
%file = [pwd '\subject list.xlsx']; % set file path

%Grab file directly from box
file = ['E:\Box Sync\Suicide studies\data\LEARN TG reinforcement schedules.xlsx'];

%Found this on matlab central get sheet names, for each sheet load in data
%to the rata data cell
[type,sheetname] = xlsfinfo(file); 
m=size(sheetname,2); 

raw_data = cell(1, m);
ids = cell(1, m);
tmp_ids_and_versn = cell(200,2); %This will support up to 200 subjects


for i=1:m
    Sheet = char(sheetname(1,i)) ;
    [~,~,raw_data{i}] = xlsread(file, Sheet);
    %Remove any nans
    raw_data{i}(cellfun(@(x) any(isnan(x)),raw_data{i}(:,1)),:)=[];
    
    ids{i} = cellfun(@MatchID,raw_data{i}(:,1));
    tmp = mat2cell(ids{i}(:,1),size(ids{i}(:,1),1),size(ids{i}(:,1),2));
    for j = 1:length(tmp{1}(:,1))
        raw_data{i}{j,1} = tmp{1}(j,1); %replace with Matached Ids
    end
    %in case of any NaN ids
    qnan = ~cellfun(@isnan, raw_data{i}(:,1));
    raw_data{i} = raw_data{i}(qnan,:);
    
    if i==1
        intrvl=0;
        endwin(1,i) = size(raw_data{i},1);
        startwin=1;
    else
        intrvl=endwin(1,i-1);
        startwin=1+intrvl;
        endwin(1,i) = startwin + size(raw_data{i},1)-1;
    end
    
    switch lower(Sheet)
        case 'pilot'
            ver = 'laptop';
        case 'behavioral'
            ver = 'laptop';
        case 'scanner'
            ver = 'scanner';
        otherwise
            error('Something is wrong check the excel file!')
    end
    
    temp_data(:,i) = {[raw_data{i}(:,1),cellstr(repmat(ver,length(raw_data{i}(:,1)),1))]};

   % tmp_ids_and_versn(startwin:endwin(i),1:2)=raw_data{i}(:,1:2:3);
    tmp_ids_and_versn(startwin:endwin(i),1:2)=temp_data{i};
    
    %
    
end

ids_and_versn = tmp_ids_and_versn(1:endwin(i),:);

% Proabably a more eloquent way but this will do for meow
% go through IDs
% ids = cellfun(@MatchID,raw_data(:,1));

% for i = 1:length(ids)
%     raw_data{i,1} = ids(i,1); %replace with Matached Ids
% end



key_data = cell2mat(ids_and_versn(:,1));

%Create duplicate matrix
for i = 1:length(key_data)
    h(:,i) = key_data(i)==key_data(:);
end

%Find the duplicates...double check this from time to time as sof 5/7/15
%there wad only 1 duplicate, I'm not sure this code will hold up if there
%are more than just one pair...
dup_idx=find(sum(h)>1);

for i = 1:length(dup_idx)/2
    di=ismember(key_data,key_data(dup_idx(i)));
    duplicates(i,:) = find(di==max(di));
end

for i = 1:size(duplicates,1)
    ids_and_versn{duplicates(i,1),2}=strcat(ids_and_versn{duplicates(i,1),2}, '/',...
        ids_and_versn{duplicates(i,2),2});
    ids_and_versn{duplicates(i,2),1}=NaN;
end

%Clean up NaNs
qnan = ~cellfun(@isnan, ids_and_versn(:,1));
 ids_and_versn = ids_and_versn(qnan,:);
% 
%  versn = raw_data(:,3);

% Load up struct
tg_struct.id = cell2mat(ids_and_versn(:,1));
tg_struct.versn = ids_and_versn(:,2);

% Save it
save([data_dir 'trust_data'],'tg_struct');

% varargout
if(nargout), z = tg_struct; end

return
