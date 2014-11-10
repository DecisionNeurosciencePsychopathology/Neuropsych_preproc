% For each subject, get the highest vascular score, their
% neurological comment (highest rated?), and TIA status
%
% Jan Kalkus
% 08 Oct 2012

% load the file
[num,txt,raw] = xlsread([pathroot 'db/misc/2012_10_01 CIRS subscales.xls']);

% get date numbers from text entries (not actually using these?)
d   = cellfun(@datenum,raw(2:end,2));
ids = unique(num(:,1)); 

for idi = 1:numel(ids) 
    
    % get indices of current ID
    q = [false; ismember(num(:,1),ids(idi))];
    raw_subsec = raw(q,:);
    
    % vascular and neuro scores and comments
    max_vasc  = nanmax(cell2mat(raw_subsec(:,4))); 
    max_neuro = nanmax(cell2mat(raw_subsec(:,6)));
    q_useable = cellfun(@(x) any(~isnan(x)),raw_subsec(:,7));
    fack = @(x) eq(x,max_neuro);
    q_max_nu = ( cellfun(fack,raw_subsec(:,6)) & q_useable );
    raw_max_nu_str = raw_subsec(q_max_nu,7);
    
    if(any(q_max_nu))
        
        % organize all neuro comments, only concatenating unique
        % entries, separating them with semicolons
        tmp = unique(upper(raw_max_nu_str));
        unique_comments = sprintf('%s; ',tmp{:});
        
    else
        
        unique_comments = '';
        
    end
    
    % get TIA status (same idea as above for neuro comments)
    q_searchable_entries = ~cellfun(@any,cellfun( ...
        @isnan,raw_subsec(:,7),'UniformOutput',false));
    neuro_comments = raw_subsec(q_searchable_entries,7);
    q_tia = cellfun(@any,strfind(neuro_comments,'TIA')); 
    
    if(any(q_tia))
        
        % gather and organize TIA comments si existen
        tia_status = true;
        tmp = unique(upper(neuro_comments(q_tia)));
        tia_comments = sprintf('%s; ',tmp{:});
        
    else
       
        tia_status = false;
        tia_comments = '';
        
    end
    
    % organize output
    final_struc.id(idi)            = ids(idi);
    final_struc.max_vascular(idi)  = max_vasc;
    final_struc.max_neuro(idi)     = max_neuro;
    final_struc.neuro_comment{idi} = unique_comments;
    final_struc.TIA(idi)           = tia_status;
    final_struc.TIA_comment{idi}   = tia_comments;
    
end

% output into cell format
output_cell = cell(numel(final_struc.id,numel(fieldnames(final_struc))));
fnames = fieldnames(final_struc);

for ni = 1:numel(final_struc.id)
    
    for fi = 1:numel(fnames)
        
        if(iscell(final_struc.(fnames{fi})))
            
            output_cell{ni,fi} = final_struc.(fnames{fi}){ni};
            
        else

            output_cell{ni,fi} = final_struc.(fnames{fi})(ni);
            
        end
        
    end
    
end

% write to tab-delimited ASCII file
fid = fopen('output_file.dat','w');

fprintf(fid,'ID\tmax vascular\tmax neuro\tneuro comments\ttia status\ttia comments\n');

% print each line of data
for ri = 1:size(output_cell,1)
        
    fprintf(fid,'%d\t%d\t%d\t%s\t%d\t%s\n',output_cell{ri,1}, ...
        output_cell{ri,2},output_cell{ri,3},output_cell{ri,4},output_cell{ri,5},output_cell{ri,6});
    
end

fclose(fid); % snuff'd
