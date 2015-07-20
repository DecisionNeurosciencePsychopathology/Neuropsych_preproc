m = loadAllids;
did_list = dir('l:/Summary Notes/Data/Willingness to Wait/data/*.mat');

id_number = unique(m.id_number);

qx = false(length(id_number),1); dt = zeros(size(qx));
for iid = 1:length(id_number)
    for jen = 1:length(did_list)
   
        % check which id's are in file name strings of stored data
        if(any(strfind(did_list(jen).name,num2str(id_number(iid)))))
            qx(iid) = true;

            % get date of assessment
            dt(iid) = datenum(dotmatstat([pathroot ...
                'analysis/willingness to wait/data/raw/' did_list(jen).name]));
        end
        
    end
end

fprintf('\tYou have ''Willingness to Wait'' data for %d subjects\n',numel(id_number(qx)));

% save data as *.dat file to merge with SPSS demographics data
fid0 = fopen('./spss/tmp_wtw_dems_to_merge.dat','w');
fid1 = fopen('./spss/tmp_wtw_dems_w_date.dat','w');

fprintf(fid0,'ID\tbool_has_wtw_data\n');
fprintf(fid1,'ID\tbool_has_wtw_data\twtw_date\tconsent_date\n');
x = id_number(qx);
d = dt(qx);

for ili = 1:numel(x)
    
    fprintf(fid0,'%d\t%d\n',x(ili),1);
    if(d(ili)), tmp = datestr(d(ili)); else tmp = ''; end
    % --- <yuck> ---
    if(d(ili))
        qa = find(m.id_number == x(ili));
        %c = datestr(unique(m.consent_date( m.consent_date == max(m.consent_date{qa}(1))) ));
        c = cellfun(@any,cellfun(@(y) y == max(m.consent_date{qa}(1)),m.consent_date,'UniformOutput',false));
    else
        c = '';
    end
    % --- </yuck> ---
    fprintf(fid1,'%d\t%d\t%s\t%s\n',x(ili),1,tmp,c);
    
end

fclose(fid0);
fclose(fid1);
