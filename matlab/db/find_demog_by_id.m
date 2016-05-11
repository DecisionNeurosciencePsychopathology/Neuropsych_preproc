function task_data = find_demog_by_id(task_data)
%Basically I just had to do this once for WTW because I'm pretty sure the
%other tasks have the demographics already stored in their mat files but if
%the problem every arises again just load in the main demog db in the SPSS
%dir, then load in whatever ever task .mat file and use the code to search
%for whatever you need it to.


% db = 'c:\kod\Neuropsych_preproc\SPSS\data\demogs_data.mat'
% 
% db = [pathroot 'db/splash_demo_2.xlsx'];



% [~,~,db]=xlsread(db);
% headers = [db(1,:)];
% db(1,:)='';

%Loads the demog data into workspace
load('c:\kod\Neuropsych_preproc\SPSS\data\demogs_data.mat');

% data was the variable name when you loaded demog.mat
ids = [data{:,1}]'; %<- handy trick to get cell numbers to doubles

%Find where the group string is
for k = 1:size(data,2)
    if ischar(data{1,k})
        if any(strcmpi(data{1,k},{'CONTROL', 'ATTEMPTER', 'DEPRESSION', 'IDEATOR'}))
            stat_idx=k;
        end
    end
end
%Hard code here for breverity
stat_idx = 10;


tots=0;
%Produce number of subjects in each PT TYPE

% for j = {'CON', 'ATT', 'DEP', 'IDE'}
%     idx=0;
%     demos=0;
%     for i = 1:length(task_data.id)
%         if(isempty(task_data.id(i))) %skip it if its empty
%             continue
%         end
%         %idx=find(task_data(i).id==ids); 
%         idx=find(task_data.id(i)==ids); 
%         if~isempty(idx) && ~isempty(data{idx,stat_idx}) && (strcmpi(data{idx,stat_idx}(1:3),j)) 
%             %demos(i)=task_data(i).id;
%             demos(i)=task_data.id(i);
%         end
%     end
%     disp(j)
%     num_demos=(find(demos));
%     disp(size(num_demos,2));
%     tots = tots + size(num_demos,2);
% end

%The groups(1-5) for the data
for i = 1:length(task_data.id)
    if(isempty(task_data.id(i))) %Need to follow DRY here but fix later, spending to much time on this
        continue
    end
    idx=find(task_data.id(i)==ids);
    task_data.group_15(i,1)=[data{idx,stat_idx}];
end




%The groups(1-7) for the data
for i = 1:length(task_data.id)
    if(isempty(task_data.id(i))) %Need to follow DRY here but fix later, spending to much time on this
        continue
    end
    idx=find(task_data.id(i)==ids);
    task_data.group_17(i,1)=[data{idx,stat_idx+1}];
end

%Spit out demos
controls = sum(task_data.group_15==1);
depressed = sum(task_data.group_15==2);
ideators = sum(task_data.group_15==4);
attempters = sum(task_data.group_15 ==5);
lowattempters = sum(task_data.group_17 ==6);
highattempters = sum(task_data.group_17 ==7);

str = sprintf('\nControls = %d\nDepressed controls = %d\nIdeators = %d\nAttempters = %d\n(LowLeth = %d, HighLeth = %d)',...
    controls, depressed,ideators, attempters, lowattempters, highattempters);
disp(str)

task_data.demos = [controls depressed ideators attempters lowattempters highattempters];

tots; %Stopping poit to QC code
return



% for i = 1:length(idz)
%     idx=find(idz(i)==ids);
%     zz{idx,2}=[data{idx,11}];
% end



% for i = 1:length(task_data)
%     idx=find(task_data(i).id==ids);
%     task_mat(i,:)=data(idx,:);
% end
% 
% 
% 
% num_demos=(find(demos));
% 
% 
% for i = 1:length(task_data)
% wtw_ids(i,1)=task_data(i).id;
% end
% wtw_ids=sort(wtw_ids);
% 
% for i = 1:length(drop_ids)
% am_member(i,1)=ismember(drop_ids(i),wtw_ids);
% end