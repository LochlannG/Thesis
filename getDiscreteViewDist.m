function yNoise = getDiscreteViewDist(levels)
% yNoise = getDiscreteViewDist(levels)
% Randomly generate a value of view distance from the given levels
%
% Inputs:
% levels            -   Levels of view distance
% 
% Outputs:
% yNoise            -   Choice made of view distance level
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function

    % Just counts the number of elements
    n = numel(levels);

    % Returns a random integer between 1 and n
    int = randi(n);

    % Picks the level of that integer and adds it to the output vector
    yNoise = levels(int);

end