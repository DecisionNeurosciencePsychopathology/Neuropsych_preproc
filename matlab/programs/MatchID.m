function m = MatchID(id_input,varargin)
% This function will attempt to match a given numerical input 
% to existing ID's in the database. The user is prompted to choose
% which of the possible matches are the closest. 
%
% This function calls 'CheckID' which computes the similarity of 
% the input to the mast list of IDs. 
%
%
% Jan Kalkus
% 2013-08-14 
%
% Jan Kalkus
% 2013-12-06: did I squish a persistent bug? --need to check
%
% Jan Kalkus
% 2014-04-10: added support for 'debug' input option as well
%             as use of Jaccard index for matching


% supress output (or not)
quiet_flag = false; debug_flag = false;
if(any(strcmpi('quiet',varargin))), quiet_flag = true; end
if(any(strcmpi('debug',varargin))), debug_flag = true; end

% standardize the input --does this fix the bug?
if(isnumeric(id_input)), id_input = num2str(id_input); end

% most of the complicated work is done here
closest_match = CheckID(id_input);

% check resutls
if(numel(closest_match) > 1) % multiple matches
	top_rank = closest_match(1,2); % closest match(es) rank(s)
	if(top_rank > 2 || any(eq(top_rank,closest_match(2:end,2))))
		
		% if there is more than one match competing for the
		% closest match, require user input to choose match
		if(~debug_flag), clc; end;
        fprintf('\n\t--> Matches for fragment: %s\n',id_input);
		rs = get_usr_response(closest_match); 
		if(rs > 0), m = closest_match(rs,1); else m = NaN; end
		
	else
		
		% if there is only one number with the highest rank,
		% automatically choose that one as the correct id
		m = closest_match(1,1);
		fprintf('--> %s matched to ID: %d <--\n',id_input,m);
        if(debug_flag)
            fprintf('\tscore = %0.5g\n',top_rank);
        end
		
	end
else % only one result, input is an exact match
	m = closest_match;
    if(not(quiet_flag))
        fprintf('%8d is a perfect ID match (yay!)\n',closest_match);
    end
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function r = get_usr_response(id_matches)
% subfunction for interacting with user and recording their choice

% only present top, conflicting matches
%q = ( (id_matches(:,2) - id_matches(1,2)) < 2*std(id_matches(:,2)) );
%id_matches = id_matches(q,:);

% print out matches and their ranks
fprintf('\n\toption\t  id number\t\tscore\n\n');
for opti = 1:size(id_matches,1)
    id_num  = id_matches(opti,1); id_rank = id_matches(opti,2);
    fprintf('\t  (%d)\t  \t%d\t\t%5.4f\n',opti,id_num,id_rank);
end, fprintf('\n');

% acquire user response
usr_resp = zeros;
while(~usr_resp)
    prompt = sprintf('\tPlease choose one of the above options\n\n\tchoice (return = ignore): ');
    usr_resp = input(prompt);
    if(~isnumeric(usr_resp))
        usr_resp = 0; 
    elseif(usr_resp > size(id_matches,1))
        fprintf('\t>>> Response option value (%d) to large, try again.\n',usr_resp);
        usr_resp = 0;
    elseif(usr_resp < 0) % ignore this entry
        fprintf('\n\tskipping entry...\n\n');
    end
end

% return the user choice
r = usr_resp; 

return

