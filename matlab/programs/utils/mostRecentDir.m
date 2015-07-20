function s = mostRecentDir(sub_path)
% Jan Kalkus
% 03 Oct 2012: This small function finds the most recently created 
%              (or is it modified?) directory within a directory path. 
%
% TODO: do we want to add an option to parse the name of the dir to 
%       determine which is more recent? (I think so)

% check if the dir exists
if(exist(sub_path,'dir') ~= 7)
    error('MATLAB:mostRecentDir', ...
        'Directory ''%s'' not found\n',sub_path);
end

% get dir data and check if any dirs are in the path
d_struc = dir(sub_path);
if(~any([d_struc.isdir])) 
    error('MATLAB:mostRecentDir:nodirs', ...
        'No directories found in ''%s''\n',sub_path);
else
    % which entries are directories (excluding . and .. directories)
    q_isdir = [d_struc.isdir] & ...
        cellfun(@isempty,regexp('\.{1,2}',{d_struc.name}));
end

% find dir with most recent 'birth' date
q_latest = ( [d_struc.datenum] == max([d_struc(q_isdir).datenum]) );

% if timestamps are not preserved (e.g., when batch copying dirs)
if(sum(q_latest) > 1)
    s = uigetdir(sub_path,'Conflicting creation dates: please choose a folder');
    s = [s '\'];
end
    
% output the name of the dir
if(~exist('s','var'))
    s = [sub_path d_struc(q_latest & q_isdir).name '\'];
else
    return
end

return