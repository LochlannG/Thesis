function test = setupContext(test)
% test = setupContext(test)
% Setups up the rates of occurance for the various objects based on a 'context'
% The 'rates' are given in units of per thousand meters
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
    
    % Rural context
    if test.context == 'rural'
        test.rateCyclist        = 1  * round(test.lengthM/1000);
        test.rateOncomingCar    = 3 * round(test.lengthM/1000);
        test.rateInFlowCar      = 1  * round(test.lengthM/1000);

    % Urban context
    elseif test.context == 'urban'
        test.rateCyclist        = 3 * round(test.lengthM/1000);
        test.rateOncomingCar    = 5 * round(test.lengthM/1000);
        test.rateInFlowCar      = 3 * round(test.lengthM/1000);

    % The littliest bit of error checking
    else
        error('Unrecognised Context')
    end

end