function qx = isRepeat(x)
% returns a logical index of repeat entries

u = unique(x); % braump
qx = ismember(x,u(histc(x,u) > 1));

return
