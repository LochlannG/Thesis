function test = setupContext(test)
% test = setupContext(test)
% Randomly generate a number of points in the sample space of testLengthM
% determined by the CyclistRate parameter
%
% Inputs:
% test              -   Structure containing 'context' field which determines the setting of the current trial
%
% Outputs:
% test              -   Updated test structure
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function
    
    if test.context == 'rural'
        test.rateCyclist = 2;
        test.rateOncomingCar = 25;
        test.rateInFlowCar = 5;
    elseif test.context == 'urban'
        test.rateCyclist = 5;
        test.rateOncomingCar = 35;
        test.rateInFlowCar = 10;
    else
        error('Unrecognised Context')
    end
end