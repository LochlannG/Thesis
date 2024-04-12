function [accepted, logical] = getStarts(testLengthM, maxStartDistance, closestDist, rate)
% [accepted, logical] = getStarts(testLengthM, startDistance, rate)
% Pseudo-randomly generate a number of points in the sample space of testLengthM
% determined by the rate parameter. The minimum distance these points can
% be from each other is determined by the 'closestDist' parameter
%
% Inputs:
% testLengthM       -   Length of test in meters
% startDistance     -   Distance that an object start from
% closestDist       -   The closest acceptable distance two points can be chosen
% rate              -   Expected number of objects
%
% Outputs:
% accepted          -   A sorted list of n samples in space 0:testLengthM-startDistance
% logical           -   A logical array of the idx
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function
% 2.0 - Added a poisson sampling function
% 3.0 - Added some input/output checking
% 4.0 - Added a way to ensure a minimum distance between points

    % Debug mode
    debug = 0;

    % Checking inputs
    if rate == 0
        rate = 1;
    end

    t = maxStartDistance:1:testLengthM;       % Generate a vector of meter points
    nPoiss = poissrnd(rate);                        % randomly picks the number using a poisson

    % checks to ensure at least one stimulus is going to appear
    nPoiss(nPoiss<1) = 1;
    
    % initialise loop variables
    numPoints       = 0;
    count           = 0;
    maxIterations   = 1000*nPoiss;
    accepted        = nan(1, nPoiss);
    
    % Loop to pick points
    while numPoints < nPoiss && count < maxIterations
        
        % Get a random point
        idx =  randperm(numel(t), 1);
        if debug; disp(["Picked: " num2str(idx)]); end
        if numPoints == 0
            numPoints = numPoints + 1;
            accepted(numPoints) = idx;
            continue;
        end
        
        % Find Distance
        distance = accepted - idx;
        
        % Accept point if the distance is far enough
        
        if abs(distance(1:numPoints)) >= closestDist
            numPoints = numPoints + 1;
            accepted(numPoints) = idx;
            if debug; disp("Point Accepted"); end
        else
            if debug; disp("Point Rejected"); end
        end
        
        % Iterate loop
        count = count + 1;
    end
    
    accepted = sort(accepted);                       	% Sorts points from lowest to highest
    logical(accepted) = true;                           % Returns a logical array of idicies
    
    if debug; figure; plot(logical); end

end