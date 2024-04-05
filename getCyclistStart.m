function starts = getCyclistStart(nCyclists)
% starts = getCyclistStart(nCyclists)
% Randomly generate nCyclists different start positions
%
% Inputs:
% nCyclists         -   Number of starts required
% 
% Outputs:
% starts            -   Vector of starts (1 x nCyclists)
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function
    

    % The different levels
    levels = [20, 40, 60];

    % Just counts the number of elements
    n = numel(levels);

    % Picks nChoices number of speeds from the levels
    for i = 1:nCyclists

        % Returns a random integer between 1 and n
        int = randi(n);

        % Picks the level of that integer and adds it to the output vector
        starts(i) = levels(int);
    end
end