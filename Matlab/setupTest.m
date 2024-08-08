function test = setupTest()
% Prompts the user to get the setup of the test

    % Prompt the user
    prompt              = {'Enter subject code:', 'nTrials:', 'Trials Distance (m):','EMG:'};
    dlgtitle            = 'Input';
    fieldsize           = [1 45; 1 45; 1 45; 1 45];
    definput            = {'test','1', '2000', '0'};
    answer              = inputdlg(prompt, dlgtitle, fieldsize, definput);
    
    % Variables to get about the subject & the test
    test = struct();
    test.subjectCode    = answer{1};
    test.trials         = str2double(answer{2});
    test.lengthM        = str2double(answer{3});  
    test.recordEMG      = logical(str2double(answer{4}));

    % Variables that don't depend on the user
    test.recordEEG      = false;
    test.context        = 'urban';
    test.debug          = 0;
    test.discreteSpeed  = true;

    % Context
    if test.context == 'rural'
        test.rateCyclist        = 1  * round(test.lengthM/1000);
        test.rateOncomingCar    = 3 * round(test.lengthM/1000);
        test.rateInFlowCar      = 1  * round(test.lengthM/1000);

    elseif test.context == 'urban'
        test.rateCyclist        = 3 * round(test.lengthM/1000);
        test.rateOncomingCar    = 5 * round(test.lengthM/1000);
        test.rateInFlowCar      = 3 * round(test.lengthM/1000);

    end

end