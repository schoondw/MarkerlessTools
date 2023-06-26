function rp = resolve_path(bp,ap,string_flag)
% Recursive function for resolving path strings
% Adds ap (append path) to bp (base path) recursively, resolving . and ..
% 
% Alternative to using cd, when you don't want to actually change the
% directory.

% Options (option to add input parser later on)
opts.filesep = filesep;

% Convert to character in case of string input and set a flag to convert back
% to string.
narginchk(2,3)
if nargin < 3
    string_flag = false;
end
if isstring(bp) || isstring(ap)
    string_flag = true;
    bp = char(bp);
    ap = char(ap);
end

% Preprocess
% - Remove initial / or ./ from ap
if startsWith(ap,opts.filesep)
    ap = ap(2:end);
end

% - Remove trailing / from ap and bp
if endsWith(ap,opts.filesep)
    ap = ap(1:end-1);
end
if endsWith(bp,opts.filesep)
    bp = bp(1:end-1);
end

% Detect file separators in ap string
i_sep = strfind(ap,opts.filesep);
n_sep = length(i_sep);

% Interpret and append to path
if n_sep == 0 % Stop
    rp = apply_to_path(bp,ap,opts.filesep);
    if string_flag
        rp = string(rp);
    end
else
    ap_part = ap(1:i_sep(1)-1);
    ap_new = ap(i_sep(1)+1:end);
    bp_new = apply_to_path(bp,ap_part,opts.filesep);
    rp = resolve_path(bp_new,ap_new,string_flag); % Recursive call
end

function rp = apply_to_path(bp,ap,fsep)
% Apply change to base path
if isempty(bp)
    rp = ap;
    return
end

switch ap
    case '.'
        rp = bp;
    case '..'
        i_sep = strfind(bp,fsep);
        if isempty(i_sep)
            error('Base path too short.')
        end
        rp = bp(1:i_sep(end)-1);
    otherwise
        rp = [bp, fsep, ap];
end
