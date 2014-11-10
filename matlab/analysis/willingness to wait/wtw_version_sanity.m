% willingness to wait sanity check (check for different versions of data)

data_path_root = [pathroot 'analysis/willingess to wait/data/raw/'];
data_files = dir([data_path_root '*.mat']);

for data_file_id = 1:length(data_files)
    % code
    load([data_path_root data_files(data_file_id).name]);
    
    % general info.
    wtw_meta_struc.id(data_file_id,1) = str2double(dataHeader.id);
    wtw_meta_struc.test_date(data_file_id,:) = dataHeader.sessionTime;
    
    % a bit more descriptive
    
    wtw_meta_struc.payoff_range(data_file_id,1:2) = [ ...
        max(Struct2Vect(trialData,'payoff')) ...
        min(Struct2Vect(trialData,'payoff'))];
    wtw_meta_struc.ntrials(data_file_id,1) = length(trialData);
    wtw_meta_struc.nsecsDur(data_file_id,1) = max( ...
        max(Struct2Vect(trialData,'outcomeTime')), ...
        max(Struct2Vect(trialData,'timeLeft')));
    
    % everything else
    wtw_meta_struc.specs(data_file_id) = dataHeader;
    wtw_meta_struc.trialByTrial{data_file_id} = trialData;
end

save('wtw_meta_struct','wtw_meta_struc');