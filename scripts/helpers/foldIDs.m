function foldedIDs = foldIDs(originalIDs)
    % foldedIDs = foldIDs(originalIDs)
    % Removes trailing 'L' or 'R' from each string in originalIDs,
    % except for specific hard-coded exceptions.

    % Define exceptions
    exceptions = ["ADL", "ASEL", "ASER", "GLR", "OLL", "RIR"];

    % Start with a copy
    foldedIDs = originalIDs;

    % Find elements that end with L or R, excluding exceptions
    mask = (endsWith(originalIDs, "L") | endsWith(originalIDs, "R")) & ...
           ~ismember(originalIDs, exceptions);

    % Remove last character from those elements
    foldedIDs(mask) = extractBefore(originalIDs(mask), strlength(originalIDs(mask)));

end