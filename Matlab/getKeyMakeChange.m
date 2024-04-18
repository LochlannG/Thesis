function [loop, keyBinary] = getKeyMakeChange(loop, speedo, cyclist, keys, test, camera, scrn, whichKeys, emg)
% [loop, keyBinary] = getKeyMakeChange(loop, speedo, cyclist, keys, test, camera, scrn, whichKeys, emg)
% Check keys and update values in the loop structure based on those inputs 
%
% Inputs:
% loop              -   loop structure from TaskScript.m file, contains details of current loop
% speedo            -   loop structure from TaskScript.m file, contains details of current speedometer
% cyclist           -   cyclist structure from TaskScript.m file, contains values for cyclist object
% keys              -   keys structure from TaskScript.m file, contains values for the current keyboard
% test              -   test structure from TaskScript.m file, contains details for the current test
% camera            -   camera structure from TaskScript.m file, contains details for the camera object
% scrn              -   scrn structure from TaskScript.m file, contains details for the current screen object
% whichKeys         -   (1 x 6) vector containing which keys are to be considered in the order of esc, return, up, down, left, right
% emg               -   emg Object created from EMGtriggers.m class 
%
% Outputs:
% loop              -   loop structure from TaskScript.m file, contains updated details of current loop
% keyBinary         -   records which of the keys were pressed in a given frame
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function
% 2.0 - Updated for the continuous vs discrete paradigms
% 3.0 - Renamed function for clarity in use case

    % Checks the keys that are down
    [~, ~, keys.Code] = KbCheck;
    
    % Will close the loop if returned true, defaults to false
    loop.breakFlag = false;
    loop.hitMinSpeedFlag = false;
    
    % Opens an all zero array to record which keys
    keyBinary = zeros(1, 6);
    
    % Escape Key
    if all(keys.Code(keys.escape)) && whichKeys(1) == 1
        % Handles the escape key
        loop.skipPlot = true;
        loop.escapeFlag = true;
        loop.breakFlag = true;
        keyBinary(1) = 1; 
    end
    
    if all(keys.Code(keys.enter)) && whichKeys(2) == 1
        % handles enter button
        loop.breakFlag = true;
        keyBinary(2) = 1; 
    end
    
    % Up arrow Key
    if all(keys.Code(keys.up)) && whichKeys(3) == 1
        % Handles speeding up
        
        keyBinary(3) = 1; 
        
        if test.debug == 1
            disp("Speed Up")
        end
        
        if speedo.unlocked
            loop.cameraVCurrent = loop.cameraVCurrent + camera.discreteAcceleration;
        end
        
        if loop.cameraVCurrent >= camera.maxSpeed
            loop.cameraVCurrent = camera.maxSpeed;
        end
    end
    
    % Down arrow key
    % If key enabled AND pressed
    if all(keys.Code(keys.dw)) && whichKeys(4) == 1
        % Handles slowing down
        
        keyBinary(4) = 1; 
        
        if test.debug == 1
            disp("Slow Down")
        end
        
        if loop.nFramesSlowing == 0
            loop.nFramesSlowing = 1;
            if emg ~= 0
                emg.onMarker();
            end
        end
        
        if test.discreteSpeed

            % Defining a minimum value for speed, I love getting a chance
            % to use switch - case statements they are very fancy
            if any(strcmp(fieldnames(loop), 'whichType'))
                switch loop.whichType
                    case 1
                         minSpeed = cyclist.speed(loop.whichInstance(1));
                    otherwise
                        minSpeed = min(cyclist.speed);
                end
            else
                minSpeed = min(cyclist.speed);
            end
            
%             disp(["Current Speed", num2str(loop.cameraVCurrent)])

            if speedo.unlocked % if an event has passed

                loop.cameraVCurrent = loop.cameraVCurrent - camera.discreteAcceleration;
                
            elseif loop.oneVis      % if something isn't visible you can't slow down

                % When the trial screen is in place
                loop.cameraVCurrent = loop.cameraVCurrent - (loop.nFramesSlowing)*camera.slopeOfAccFun*(1/scrn.frameRate);
                loop.nFramesSlowing = loop.nFramesSlowing + 1;


            end

            if loop.cameraVCurrent <= minSpeed
                loop.hitMinSpeedFlag = true;
                loop.cameraVCurrent = minSpeed;
            end
        else
            loop.cameraVCurrent = loop.cameraVCurrent - 5*camera.continuousAcceleration*(1/scrn.frameRate);
        end
        
        if loop.cameraVCurrent <= 0
            loop.cameraVCurrent = 0;
        end

    else
        
        % If the down button hasn't been pressed this frame
        loop.nFramesSlowing = 0;
        if emg ~= 0
            emg.offMarker();
        end
        
    end
    
    % Left arrow key
    if all(keys.Code(keys.lt)) && whichKeys(5) == 1
        % Handles moving back into your lane
        if test.debug == 1
            disp("Back to lane")
        end
        loop.setOvertake = false;
        keyBinary(5) = 1;

    end
    
    % Right arrow key
    if all(keys.Code(keys.rt)) && whichKeys(6) == 1
        % Handles overtaking
        if test.debug == 1
            disp("Overtake")
        end
        
        loop = loop.startOvertake(scrn);
        keyBinary(6) = 1; 
        
        % ping EMG
        if emg ~= 0
            emg.smlTaskMarker();
        end

    end
    
end