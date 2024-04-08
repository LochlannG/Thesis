function speeds = getCyclistSpeed(mu, sig, nSig, nChoices)
% speeds = getCyclistSpeed(mu, sig, nSig, nChoices)
% Randomly generate speeds within 2 standard deviations of a given speed normal distribution
%
% Inputs:
% mu                -   Mean value of speed distribution
% sig               -   Standard deviation of speed distribution
% nSig              -   Number of standard deviations to truncate to
% nChoices          -   How many speeds are required to be chosen
%
% Outputs:
% speeds            -   Vector of speeds (1 x nChoices)
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function
    


    % Generates a normal distribution using the given parameters
    % Then truncates values to +/- nSig
    fullDist = mu + randn(nChoices*10, 1)*sig;
    reducedDist = fullDist(and(fullDist<mu+sig*nSig, fullDist>mu-sig*nSig));
    
    % determines the number of elements of vector reducedDist
    n = numel(reducedDist);

    % Picks nChoices number of speeds from the distribution
    for i = 1:nChoices

        % Returns a random integer between 1 and n
        int = randi(n);

        % Picks the speed of that integer and adds it to the output vector
        speeds(i) = reducedDist(int);
    end

end