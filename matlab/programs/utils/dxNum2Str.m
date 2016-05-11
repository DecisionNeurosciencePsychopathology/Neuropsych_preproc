function dx_str = dxNum2Str( varargin )

% load diagnosis data
dx_data = loadDxData;

% find match (if any)
q_match = strcmp(varargin{:},dx_data{1}(:,1));

% get the text description
txt_match = dx_data{1}(q_match,2);
if(sum(q_match) == 1); txt_match = txt_match{:}; end

% handle output
if(nargout)
    dx_str = txt_match;
elseif(~isempty(txt_match))
    fprintf(' %6s\t%s\n',varargin{:},txt_match);
end

return


function dx_data = loadDxData

% get filename and initialize file pointer
filename = [pathroot 'db/DSM-IV codes.dat'];
fid = fopen(filename,'r');

% return data and close file pointer
dx_data = textscan(fid,'%s %s','delimiter','\t','CollectOutput',true);
fclose(fid);

return


function resolveNullMatch(entry_num,dx_list)

% this will come in handy here
%score = arrayfun(@(s) damlevdist(entry_num,s),dx_list);

return