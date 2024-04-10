function [idx, logical] = getStarts(testLengthM, maxStartDistance, rate)
% [idx, logical] = getStarts(testLengthM, startDistance, rate)
% Randomly generate a number of points in the sample space of testLengthM
% determined by the rate parameter
%
% Inputs:
% testLengthM       -   Length of test in meters
% startDistance     -   Distance that an object start from
% rate              -   Expected number of objects
%
% Outputs:
% idx               -   A sorted list of n samples in space 0:testLengthM-startDistance
% logical           -   A logical array of the idx
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function
% 2.0 - Added a poisson sampling function
% 3.0 - Added some input/output checking

    % Checking inputs
    if rate == 0
        rate = 1;
    end

    t = 0:1:testLengthM-maxStartDistance;       % Generate a vector of meter points
    rt = poissrnd(rate);                        % randomly picks the number using a poisson

    % checks to ensure a stimulus is going to appear
    rt(rt<1) = 1;

    idx =  randperm(numel(t), rt);
    idx = sort(idx);                            % Sorts points from lowest to highest
    logical(idx) = true;    	                % Returns a logical array of idicies


end