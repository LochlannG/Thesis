classdef TrialClass
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        roadLength
        currentBlock
        nBlocks
        currentTrial
        nTrials
        subjectCode
        recordEMG
    end

    methods
        function trial = TrialClass()
            % TrialClass Construct an instance of this class
            % Prompts the users to gain the details of this. There are some
            % default values included.

            % Prompt the user
            prompt              = {'Enter subject code:', 'nBlocks', 'nTrials:', 'Trials Distance (m):','EMG:'};
            dlgtitle            = 'Details of Trials Input';
            fieldsize           = [1 45; 1 45; 1 45; 1 45; 1 45];
            definput            = {'test', '2', '2', '200', '0'};
            answer              = inputdlg(prompt, dlgtitle, fieldsize, definput);
            
            % Variables to get about the subject & the test
            trial.subjectCode   = answer{1};
            trial.nBlocks       = str2double(answer{2});
            trial.nTrials       = str2double(answer{3});
            trial.roadLength    = str2double(answer{4});  
            trial.recordEMG     = logical(str2double(answer{5}));

            trial.currentBlock = 1;
            trial.currentTrial = 1;
        end

        function trial = iterateBlock(trial)
            % ITERATEBLOCK Function handling when a block changes
            % Add one to the current block counter

            trial.currentBlock = trial.currentBlock + 1;
            trial.currentTrial = 1;

        end

        function trial = iterateTrial(trial)
            % ITERATETRIAL Function handling when a trial ends
            % Add one to the current trial counter

            trial.currentTrial = trial.currentTrial + 1;

        end

        function [trial, camera] = resetTrial(trial, camera)
            % RESETTRIAL Reset trial variables
            % At the top of a trial, reset the values which are
            % dependent on a single trial.

            camera = camera.resetStartPosition;
            camera = camera.setSpeed(200/3.6);

        end

        function printBlock(trial, scrn, keys)
            % PRINTBLOCK Print out current block number to screen
            % Takes in some variables about the current status of this
            % trial. Prints out the current block to the screen. Waits for
            % the user to click enter before continuing.

            textString = ['Current Block: ' num2str(trial.currentBlock) '\nPress Enter to Continue'];
            DrawFormattedText(scrn.win, textString, 'center', 'center', scrn.whit);
            Screen('Flip', scrn.win);
            
            while true
                [~, ~, keys.code, ~] = KbCheck;
                if keys.code(keys.enter) == 1
                    break;
                end
            end
        end

        function printTrial(trial, scrn, nSecs)
            % PRINTTRIAL Print out current trial number to screen
            % Takes in some variables about the current status of this
            % trial. Prints out the current block to the screen. Waits for
            % the user to click enter before continuing.

            textString = ['Current Trial: ' num2str(trial.currentTrial)];
            DrawFormattedText(scrn.win, textString, 'center', 'center', scrn.whit);
            Screen('Flip', scrn.win);
            WaitSecs(nSecs);

        end

    end
end