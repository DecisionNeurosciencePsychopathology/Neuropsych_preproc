%Create afsp ids first from list
load('afsp_ids.mat')

%Run process_cantab_data.m
df=process_cantab_data;

c_tab = df;
ids=[c_tab.SubjectID];
%ids=cellfun(@str2num, ids);
c_tab(~ismember(ids,afsp_ids),:)=[];