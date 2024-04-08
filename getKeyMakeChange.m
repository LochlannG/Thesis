function loop = getKeyMakeChange(loop, keys, test, camera, scrn, whichKeys)
% loop = checkKey(loop, keys, whichKeys)
% Check keys and update values in the loop structure based on those inputs 
%
% Inputs:
% loop              -   loop structure from TaskScript.m file, contains details of current loop
% keys              -   keys structure from TaskScript.m file, contains values for the current keyboard
% test              -   test structure from TaskScript.m file, contains details for the current test
% camera            -   camera structure from TaskScript.m file, contains details for the camera object
% scrn              -   scrn structure from TaskScript.m file, contains details for the current screen object
% whichKeys         -   (1 x 6) vector containing which keys are to be considered in the order of esc, return, up, down, left, right
% 
% Outputs:
% loop            -   loop structure from TaskScript.m file, contains updated details of current loop
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
    
    % Escape Key
    if all(keys.Code(keys.escape)) && whichKeys(1) == 1
        % Handles the escape key
        loop.skipPlot = true;
        loop.escapeFlag = true;
        loop.breakFlag = true;
    end
    
    if all(keys.Code(keys.enter)) && whichKeys(2) == 1
        % handles enter button
        loop.breakFlag = true;
    end
    
    % Up arrow Key
    if all(keys.Code(keys.up)) && whichKeys(3) == 1
        % Handles speeding up
        if test.debug == 1
            disp("Speed Up")
        end
        
        if test.discreteSpeed
            loop.cameraVCurrent = loop.cameraVCurrent + camera.discreteAcceleration;
        else
            loop.cameraVCurrent = loop.cameraVCurrent + camera.continuousAcceleration*(1/scrn.frameRate);
        end
        
        if loop.cameraVCurrent >= camera.maxSpeed
            loop.cameraVCurrent = camera.maxSpeed;
        end

    end
    
    % Down arrow key
    if all(keys.Code(keys.dw)) && whichKeys(4) == 1
        % Handles slowing down
        if test.debug == 1
            disp("Slow Down")
        end
        
        if test.discreteSpeed
            loop.cameraVCurrent = loop.cameraVCurrent - camera.discreteAcceleration;
        else
            loop.cameraVCurrent = loop.cameraVCurrent - 5*camera.continuousAcceleration*(1/scrn.frameRate);
        end
        
        if loop.cameraVCurrent <= 0
            loop.cameraVCurrent = 0;
        end

    end
    
    % Left arrow key
    if all(keys.Code(keys.lt)) && whichKeys(5) == 1
        % Handles moving back into your lane
        if test.debug == 1
            disp("Back to lane")
        end
        loop.setOvertake = false;

    end
    
    % Right arrow key
    if all(keys.Code(keys.rt)) && whichKeys(6) == 1
        % Handles overtaking
        if test.debug == 1
            disp("Overtake")
        end
        loop.setOvertake = true;

    end
    
end