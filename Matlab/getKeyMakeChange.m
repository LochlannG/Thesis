function loop = getKeyMakeChange(loop, cyclist, keys, test, camera, scrn, whichKeys, emg)
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
% emg               -   emg Object created from EMGtriggers.m class 
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
    loop.hitMinSpeedFlag = true;
    
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
    % If key enabled AND pressed
    if all(keys.Code(keys.dw)) && whichKeys(4) == 1
        % Handles slowing down
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
            
            disp(["Current Speed", num2str(loop.cameraVCurrent)])
            
            % This just helps round the numbers for display
%             if loop.eventOverTimer == 0 || loop.firstDisplay == 1
%                 % When the event is over
%                 loop.cameraVCurrent = loop.cameraVCurrent - camera.discreteAcceleration;
%                 if loop.cameraVCurrent <= 15/3.6
%                     loop.cameraVCurrent = 15/3.6;
%                 end
%             else
            

            if ~loop.stopResponse % if an event has passed

                loop.cameraVCurrent = loop.cameraVCurrent - camera.discreteAcceleration;
                
            elseif loop.oneVis      % if something is visible you can't slow down

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

    end
    
    % Right arrow key
    if all(keys.Code(keys.rt)) && whichKeys(6) == 1
        % Handles overtaking
        if test.debug == 1
            disp("Overtake")
        end
        loop.setOvertake = true;
        
        % ping EMG
        if emg ~= 0
            emg.smlTaskMarker();
        end

    end
    
end