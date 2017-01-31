function data_out = generate_demogaphics_from_list(id_list,export_option)
%funciton will generate the typical demographics for a list of ids
%Inputs: id list - required
%        export_options - optional ('csv','xlsx',type 'help writetable' for more options)
%
%Outputs: data_out - Matlab Table format data structure


%Arg check
narginchk(1,2)

%Default value
if nargin<=1
    export_option='none';
end

%Load in demogaphics from tmp (this was created with updateIdList.m at the time of writing this)
load([pathroot 'tmp/demogs_data.mat']) %var name is data

%Grab indices from subject list
[in_mlist,subj_list_idx]=ismember(id_list,data.ID);

%Check if any subjects from the list are not in the master list and let the
%user know
if any(in_mlist==0)
    fprintf('Subject %d was not found in the master list!\n',id_list(~in_mlist))
    subj_list_idx = subj_list_idx(in_mlist); %Pull only existing subjs
end

%Return output var
data_out = data(subj_list_idx,:);

%Save the data if export option id available
if ~strcmp(export_option,'none')
    input_str=input('Enter name to save file: ');
    try
        writetable(data_out,[input_str '.' export_option]) 
    catch
        fprintf('Something went wrong, check writetable options for more info\n')
        fprintf('Saving file as "data_out.txt"\n')
        writetable(data_out)
    end
end

