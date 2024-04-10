function test = setupTest()

    test = struct();
    test.trials = 2;
    test.recordEEG = false;

    % This determines the length of the trail and the amount of various stimuli you
    % 'expect' to see come up
    test.lengthM = 2000;                                                                    % Similar to a small journey to a shop
    test.context = 'urban';
    test = setupContext(test);
    test.debug = 0;
    test.discreteSpeed = true;

end