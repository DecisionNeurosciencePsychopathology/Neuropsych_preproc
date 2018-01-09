function df=process_cantab_data()
%Take all summary datasheets from CATNAB task and merge them into one data frame 

data_files=glob([pathroot 'analysis\cantab\data\processed_files\*.csv']);

%Initialize table
df = readtable(data_files{1},'ReadVariableNames',true);

for i = 2:length(data_files)
    try
        df_tmp=readtable(data_files{i},'ReadVariableNames',true);
        %df = [df; df_tmp];
        df = outerjoin(df,df_tmp,'MergeKeys', true);
    catch
        df_tmp=convert_table_data_to_cell(df_tmp);

        df = outerjoin(df,df_tmp,'MergeKeys', true);
        
    end
    
end

%Remove the duplicates

%Filter data some red flags if they are missing 
no_session_date=cellfun(@(x) isempty(x),df.SessionStartTime);
no_age=cellfun(@(x) isempty(x),df.Age) | cellfun(@(x) strcmp(x,'0'),df.Age);
no_gender=cellfun(@(x) isempty(x),df.Gender);
no_battery=cellfun(@(x) isempty(x),df.Battery);

%Filter data based on first round exclusions
%filter_first_round = [no_session_date + no_age + no_gender + no_battery]>0; This was causing some AFSP ids to dissapear becasue there are not ages filled in for them
filter_first_round = no_session_date>0;
df(filter_first_round,:)=[];

%Save the unfiltered version of this dat frame to resolve case by case basis issues
save('unfiltered_cantab_data','df');

%Filter based on Battery
% regular expression string to match our protocols
proto_pattern = '^suicide|^protect|(^additional tests battery)';

% return matches
qproto = ~cellfun(@isempty,regexpi(df.Battery,proto_pattern));
df(~qproto,:)=[];

% go through IDs -- only keep the matches
q_valid_id = cellfun(@MatchID,df.SubjectID);
q_valid_filter = isnan(q_valid_id);
df(q_valid_filter,:) = [];
df.SubjectID = q_valid_id(~isnan(q_valid_id));

%Filter duplicates
df=filter_by_admin_date(df);

%Remove all warnings columns
variables=df.Properties.VariableNames;
warning_cols=cellfun(@(x) strfind(x,'Warning'), variables', 'UniformOutput', 0);
warning_cols=~cellfun(@isempty, warning_cols);
df(:,warning_cols)=[];

%Save as new dataframe
writetable(df,'cantab_compiled.csv');
save('cantab_compiled.mat','df');


function my_table=convert_table_data_to_cell(my_table)
%Function will loop through all data in table and convert it to cell string
%if need be

        variables=my_table.Properties.VariableNames;
        for k=1:length(variables)
            colData = my_table.(k);
            if ~iscell(colData(1))
                my_table.(variables{k})=cellstr(num2str(colData));
            end
        end
        %df_tmp.SubjectID=cellstr(num2str(df_tmp.SubjectID));


function df=filter_by_admin_date(df)
[unique_names]=unique(df.SubjectID);

for i = 1:length(unique_names)
    unique_subject_idx=ismember(df.SubjectID,unique_names(i));
    
    if sum(unique_subject_idx) > 1 %Only is ther are indeed dups
        %Go based on most recent admin date
        [~,max_idx]=max(cellfun(@(x) (datenum(x)),df.SessionStartTime(unique_subject_idx)));
        
        %Remove duplicates
        filter_me=find(unique_subject_idx);
        filter_me(max_idx)=[];
        df(filter_me,:)=[];
    end
end
