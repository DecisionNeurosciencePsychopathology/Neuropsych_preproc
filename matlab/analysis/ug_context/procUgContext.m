function q = procUgContext(context_flag, baseline_flag, post_survey_flag, create_master_df, spss_flag)
%Very quick and dirty script to grab all ids ug Context has been
%administered on. Make sure to make dirs in the data folder the full
%subject id.

%% TODO make arg parser
% check argin
if(~exist('spss_flag','var') || isempty(spss_flag))
    spss_flag = false;
end

% check argin
if(~exist('baseline_flag','var') || isempty(baseline_flag))
    baseline_flag = false;
end

% check argin
if(~exist('create_master_df','var') || isempty(create_master_df))
    create_master_df = false;
end

% check argin
if(~exist('context_flag','var') || isempty(context_flag))
    context_flag = true;
end

% check argin
if(~exist('post_survey_flag','var') || isempty(post_survey_flag))
    post_survey_flag = false;
end

%% Main Code

%Set up prior vars
if baseline_flag
    ver = 'baseline';
    data_dir = [pathroot 'analysis/ug_context/data/baseline/']; % set data path for baseline
    save_str = '/ug_context_data_baseline.mat';
    get_vars = {'Rand1.Sample','Gender','StimulusCentre','Fairness_Score','StakeImg','StakeMagnitude','OpponentMagnitude','Stimuli.OnsetTime','Stimuli.RTTime','Stimuli.RT','Stimuli.RESP'};
    endoffset=27;
elseif context_flag
    ver = 'context';
    data_dir = [pathroot 'analysis/ug_context/data/']; % set data path
    save_str = '/ug_context_data.mat';
    %TODO DNR get_vars just add to the lsit for context version
    get_vars = {'Rand1.Sample','Gender','StimulusCentre','Fairness_score','StakeImg','StakeMagnitude','OpponentMagnitude','ReappraisalText','ReappraisalDirection','PunishingType','PunishingCondition','Stimuli.OnsetTime','Stimuli.RTTime','Stimuli.RT','Stimuli.RESP'};
    endoffset=32;
    
    %TODO make another if statement in which you olny process surveys, will
    %probably have to make a new function or append the funciton  "create_data_frame"
elseif post_survey_flag
     ver = 'post_survey';
     data_dir = [pathroot 'analysis/ug_context/data/']; % set data path
     save_str = '/ug_context_post_survey.mat';
     get_vars = {'descriptions.Sample','Question','description_text','Rating','rate.RT'};
     endoffset=19; %Or 17 dbl check this
     
end

%Organize raw files into subject specific folders
data_files = dir([data_dir '*.txt']);
if ~isempty(data_files)
    id_match = match_file_to_id(data_files);
    for i = 1:length(id_match)
        if isnan(id_match(i))
            continue
        else
            id = num2str(id_match(i));
            if ~exist(id,'dir')
                mkdir([data_dir id]);
                file_name = data_files(i).name;
                files_to_move = [data_dir file_name(1:end-3) '*'];
                movefile(files_to_move,[data_dir id]);
            end
        end
    end
    
    %Clean up xmls to make data storage neat
    try
        movefile([data_dir '*.xml'], [data_dir 'xmls']);
    catch
        warning('No xml files found')
    end
end

%%Transfer data to csv's%%
%numlist = cell2mat(cellfun(@(s) sscanf(s,'%d'),{dir_list.name},'UniformOutput',false));
numlist = num_scan(dir([data_dir])); %Thanks Jan!
master_df=[]; %Initialize master dataframe
for i = 1:length(numlist)
    ball.id(i) = numlist(i);
    
    %Where we want to rip the data from the txt file
    if ~post_survey_flag
        procedure = 'TrialProc1';
    else
        procedure = 'getratings';
    end
    
    %Pull the data from the eprime file
    [xout, fout] = getData(ball.id(i),data_dir,procedure,get_vars,endoffset);
    
    %Store in data in table
    if ~isempty(xout)
        df=create_data_frame(xout,ver);
        
        %Save individual files as csv
        if ~isempty(df)
            writetable(df,[fout sprintf('%d_%s.csv',ball.id(i),ver)])
        end
    else
        df=[];
    end
    
    %If we cant to compile a master dataframe
    if create_master_df && ~isempty(df)
        master_df=[master_df; df];
    end
end

save(sprintf(['C:/kod/Neuropsych_preproc/matlab/analysis/ug_context' '%s'],save_str),'ball');

if ~isempty(master_df)
   writetable(master_df,sprintf('%s_master_data_frame.csv',ver))
end

% varargout
if(nargout)
    q = ball;
end

return

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function num_out = num_scan(data_in)

num_out = zeros(length(data_in),1);

for n = 1:length(data_in) %index_array %3:(length(A))-2
    num_out(n) = str2double(data_in(n).name);
end

q_nan = isnan(num_out);
num_out = num_out(~q_nan);

return

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function m = match_file_to_id(dir_input)

% function handle for extracting ID with regular expression
fh_extracted_id = @(s) struct2cell(regexp(s,'(?<x>[0-9]{4,6}).{1,3}txt','names'));

% extract ID (or ID fragment) from filename string
id_fragment = cellfun(fh_extracted_id,{dir_input.name});

% match fragment(s) to existing database
m  = cellfun(@MatchID,id_fragment);

return

%  --  get the data  --  %
% get_vars = {'showstim.RESP','showstim.RT','showstim.ACC'};
% [b, data_out_path] = getData(id,get_vars,varargin{:});

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function [xout, fout] = getData(id,data_dir,procedure,vars,varargin)
% reads eprime data for a given bandit subject based on ID
%varargin{1} context or baseline?

% Find the eprime file
% ss_path = ['analysis/ug_context/data/' varargin{1}];
% data_dir  = [pathroot 'analysis/ug_context/data/' varargin{1}];
file_name = ls([data_dir sprintf('%d/*.txt',id)]); %id level dir
tmp       = sprintf('%d/%s',id,file_name);
fpath     = @(~) [data_dir tmp];
fout      = [data_dir sprintf('%d/',id)];


% read in the data
try
    xout = eprimeread(fpath(),procedure,vars,0,-1,varargin{1});
catch
    fprintf('eprimeread broke for subject %s!\n',num2str(id))
    xout=[];
    return
end

% put ID in structure and make it the first field
xout.id = id;
reorderstructure(xout,'id');

return

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function dfout=create_data_frame(xin,ver)
%Go from eprime data in a struct to a table to save as a dataframe

%Grab the date SessionDate before removing the field name for the surveys
indata = fileread(xin.fname);
indata = indata(1:length(indata)/10); %Shorten it up
pattern = 'SessionDate: (\d+-\d+-\d+)';
Session_date = regexp(indata,pattern, 'tokens');
Session_date= Session_date{:}{:};


xin=rmfield(xin,'fname'); %Remove file name

if strcmp(ver,'baseline') || strcmp(ver,'context')
    dfout=process_trialProc1(xin,ver); %Process main trial data
else
    xin.Session_date = Session_date;
    dfout=process_getratings(xin); %Process ratings data
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function dfout=process_getratings(xin)
%Clean up naming conventions
xin.Trial_Number = xin.descriptions_Sample;
xin=rmfield(xin,'descriptions_Sample');
xin.id = repmat(xin.id,length(xin.Trial_Number),1);
xin.Session_date=repmat(xin.Session_date,length(xin.Trial_Number),1);
xin.ReappraisalText = xin.description_text;
xin=rmfield(xin,'description_text');
xin.Q_type = cellfun(@(x) regexp(x,'unfair|sympathy|anger','match'),xin.Question);

%Rescale the ratings
xin.Rating = xin.Rating-2;

%Reorder
xin=reorderstructure(xin,'id','Trial_Number','Question','ReappraisalText','Rating','rate_RT','Session_date','Q_type');
dfout = struct2table(xin);
try
    dfout=add_contextual_info(dfout);
catch
    fprintf('Subject %s did not run survey extraction successfully investigate...\n',num2str(xin.id(1)))
    dfout=[];
    return
end


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function dfout=process_trialProc1(xin,ver)
xin.Trial_Number = xin.Rand1_Sample;
xin=rmfield(xin,'Rand1_Sample');
xin.id = repmat(xin.id,length(xin.Trial_Number),1);


%Make play and opp stake more clear var names
xin.PlayerProposedAmount=xin.StakeMagnitude;
xin=rmfield(xin,'StakeMagnitude');
xin.OpponentProposedAmount=xin.OpponentMagnitude;
xin=rmfield(xin,'OpponentMagnitude');

%Because I'm an idiot and I forgot to keep things consistant
if strcmpi(ver,'context')
    try
        missing_idx=~cellfun(@isempty,xin.PunishingCondition);
        xin.PunishingType(missing_idx)=xin.PunishingCondition(missing_idx);
        xin=rmfield(xin,'PunishingCondition');
    catch
        fprintf('Did I fix this?')
    end
else
    xin.Fairness_score=xin.Fairness_Score;
    xin=rmfield(xin,'Fairness_Score');
end

%Recode the decision as AcceptOffer where 1 = accept 0 = reject
xin.AcceptOffer = zeros(length(xin.Trial_Number),1);
accept_idx = cellfun(@(x) strcmp(x,'q'), xin.Stimuli_RESP) | cellfun(@(x) strcmp(x,'z'), xin.Stimuli_RESP);
xin.AcceptOffer(accept_idx)=1;

xin=reorderstructure(xin,'id','Trial_Number','Fairness_score','PlayerProposedAmount','OpponentProposedAmount');
dfout = struct2table(xin);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function xout=add_contextual_info(xin)
%For the surveys add in the reappraisal direction and punishing type
load('context_list.mat') %Put this on the cloud!

for i = 1:height(context_list)
    xin_idx=~cellfun(@isempty,strfind(xin.ReappraisalText,context_list.ReappraisalText{i}));
    if any(xin_idx)
       xin.ReappraisalDirection(xin_idx,1) = context_list.ReappraisalDirection(i);
       xin.PunishingType(xin_idx,1) = {context_list.PunishingType{i}};
    end
end

%Return final table
xout = xin; 
