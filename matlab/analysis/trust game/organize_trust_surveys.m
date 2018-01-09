%Organize raw files into subject specific folders
function organize_trust_surveys
data_dir = 'E:\Box Sync\Project Trust Game\data\trust_survey\';
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

function m = match_file_to_id(dir_input)

% function handle for extracting ID with regular expression
fh_extracted_id = @(s) struct2cell(regexp(s,'(?<x>[0-9]{4,6}).{1,3}txt','names'));

% extract ID (or ID fragment) from filename string
id_fragment = cellfun(fh_extracted_id,{dir_input.name});

% match fragment(s) to existing database
m  = cellfun(@MatchID,id_fragment);

return