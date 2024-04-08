function loop = getKeyMakeChange(loop, cyclist, keys, test, camera, scrn, whichKeys)
% loop = checkKey(loop, keys, whichKeys)
% Check keys and update values in the loop structure based on those inputs 
%
% Inputs:
% loop              -   loop structure from TaskScript.m file, contains details of current loop
% cyclist           -   cyclist structure from TaskScript.m file, contains values for cyclist object
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

            % Defining a minimum value for speed, I love getting a chance
            % to use switch - case statements they are very fancy
            switch loop.whichType
                case 0 % equally far away (This one is pretty unlikely)
                    minSpeed = min(cyclist.speed);
                case 1 % cyclist first
                    minSpeed = cyclist.speed(loop.whichInstance(1));
                case 2 % withCar first
                    minSpeed = min(cyclist.speed);
                case 3 % neither first
                    % I'm not sure what to do with this case so I'll just set it to a minimum
                    minSpeed = camera.absoluteMinSpeed;
            end

            % This just helps round the numbers for display
            if ~loop.eventOverFlag
                if loop.cameraVCurrent <= minSpeed
                    loop.cameraVCurrent = minSpeed;
                end
            else
                if loop.cameraVCurrent <= 15/3.6
                    loop.cameraVCurrent = 15/3.6;
                end
            end
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