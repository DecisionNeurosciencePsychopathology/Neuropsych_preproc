function vout = CheckID(id)
% Not sure when or why I started this, but I finished it up as a
% quick ID matcher for fragments or corrupted IDs.
%
% Jan Kalkus
% 25 Sep 2012
%
% Jan Kalkus
% 2014-04-08: updated scoring algorithm to compute Euclidean
%             distance between Damerau-Levenshtein distance
%             and Jaccard index for more precise matching. 


% standardize the input --does this fix the bug?
if(isnumeric(id)), id = num2str(id); end

% call master list of IDs
subjIDstruct = loadAllids;
subj_ids = subjIDstruct.id_number;

% compare against records (compute Damerau-Levenshtein distance
% between input data and existind IDs)
%score = arrayfun(@(x) damlevdist(id,x),subj_ids);
[score,dam_lev_d,jacc_i] = multiDimScore(subj_ids,id); 

% if there is a perfect match, stop, we're done
if(any(score == 0))
    the_match = unique(subj_ids(score == 0));
    if(nargout)
        vout = the_match;
    else
        fprintf('%d: that''s an exact match.\n',the_match);
    end
    return; % end it here
end

% in case there are fewer than 5 IDs, deal with that
if(numel(score) < 5), q_end = numel(score); else q_end = 5; end

% get closest matches
[ranked_score,ranked_index] = sort(score);

% output options
if(nargout)
    vout = [subj_ids(ranked_index(1:q_end)) ranked_score(1:q_end)];
else    
    fprintf('Closest matches to ''%s'' :\n\n',id);
    fprintf('  id number\t\tScore\t\t\tD-L dist\tJaccard\n');
    fprintf('  \t%6g\t\t%5.3f\t\t\t   %d\t\t  %3.2f\n', ...
		[ ...
			subj_ids(ranked_index(1:q_end)) ...
			ranked_score(1:q_end) ...
			dam_lev_d(ranked_index(1:q_end)) ...
			jacc_i(ranked_index(1:q_end)) ...
		]');
    fprintf('\n');
end

return


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function [s,d,j] = multiDimScore(id_list,id_to_match)
% compute the Euclidean distance between Damerau-Levenshtein 
% Distance and Jaccard index values to compute a final score.


d = arrayfun(@(x) damlevdist(x,id_to_match),id_list);
j = arrayfun(@(y) 1-JaccardIndex(y,id_to_match),id_list);

% this is faster than the method below
s = sqrt(d.^2 + j.^2); 

%tic; s = cellfun(@norm,num2cell([d j],2)); toc;

return

