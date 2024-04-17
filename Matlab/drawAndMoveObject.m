function [object, loop, test, objectY] = drawAndMoveObject(object, loop, test, type, scrn)
% [object, loop, test, objectYStore] = drawAndMoveObject(object, loop, test, type, scrn)
% Does what it says on the tin: Handles the drawing and moving of the instances of a given OpenGL object.
% An object can have a number of instances but the only thing that changes between them is their current position
%
% Inputs:
% object            -   Structure holding details of the object to be drawn and moved
% loop              -   Structure holding details of the current trial loop
% test              -   Structure containing details of how the test is setup
% type              -   What is the object can take value [1, 2, 3] <-> [bike, withCar, towardsCar]
% scrn              -   Structure holding details of the current scrn loop
%
% Outputs:
% object            -   Updated tructure holding details of the object to be drawn and moved
% loop              -   Updated structure holding details of the current trial loop
% test              -   Updated structure containing details of how the test is setup
% objectYStore      -   Updated store of object's various instances Y positions
%
% Author - Lochlann Gallagher
% Changelog (I'm not very good at maintaining this):
% 1.0 - Created function
% 2.0 - Added functionality for objects to 'turn off the track'
% 2.1 - Commented and cleaned up

    % This loop handles the logic turning a 'object' on when the trial
    % reaches the correct frame.
    if object.n > 0                                                         % If there are any instances of this object
        if object.stimStartM(object.stimCurrent) >= loop.roadLeft           % If the camera is at/has passed the point where this object should begin
            
            % Switch the object on
            object.stimOn(object.stimCurrent) = true;                       

            % If there are more instances yet to draw -> iterate the
            % counter
            if object.stimCurrent < length(object.stimStartM)
                object.stimCurrent = object.stimCurrent + 1; 
            end

            % Print message if in debug mode
            if test.debug == 1
                disp("Oncoming car begun at frame = " + loop.currentFrame);
            end

        end
    end

    % This loop handles the movement of the 'object'
    objectY = nan(object.n, 1);
    for stimInt = find(object.stimOn, 1, "first"):find(object.stimOn, 1, "last")
        
        % Finds what type of object we are working on and takes out
        % the appropriate 'step' which is the distance travelled by
        % that object in a frame
        if type == 1        % bike
            step = loop.bikeStep(stimInt);
            start = object.start(stimInt);
        elseif type == 2    % with car
            step = loop.inFlowCarStep;
            start = object.start;
        elseif type == 3    % towards car
            step = loop.oncomingCarStep;
            start = object.start;
        end

        % Draw object and update position
        if object.y(stimInt) <= start
            drawOpenGLObject([object.x, object.y(stimInt), 0], [], [], object, "Cube"); % Draw the object to the screen using the drawOpenGLObject function
        end
        
        object.y(stimInt) = object.y(stimInt) - step;                       % Update position based on step

        % If the y position of the 'cyclist' is less than 0 then it must 
        % have reached the end of the track
        if object.y(stimInt) < 0

            % If it is one of the bike or car in lane then it finishing 
            % the track is an event that we need to flag 
            if or(type == 1, type == 2)
                loop.eventOverFlag = true;                                 
            end
        end
        
        if object.y(stimInt) < -2

            object.stimOn(stimInt) = false;                                 % Turn the object off
            if or(type == 1, type == 2)
                loop.eventOverFlag = true;
            end

            % Print message if in debug mode
            if test.debug == 1
                disp(num2str(stimInt) + " finished track")                  
            end
        end
        
        % This block handles if the object can 'disappear' (simulates
        % bikes/cars turning off the road after you slow down behind them)
        % This can only happen with objects tagged as type = [1, 2] as they
        % are the ones in the camera's lane
        if or(type == 1, type == 2)                                             % If one of the correct types
            if and(loop.whichType == type, loop.whichInstance(type) == stimInt) % If this instance of this object is in front
                if object.y(stimInt) < object.potentialEnd                      % If the current instance is close enough to 'disappear'
                    
                    if loop.hitMinSpeedFlag
                        loop.nFramShown = loop.nFramShown + 1;
                    end

                    % If the object has been in front for more than nFramesTurn figure
                    if and(loop.nFramShown>scrn.frameRate*2, loop.hitMinSpeedFlag)
                        loop.nFramShown = 0;
                        object.stimOn(stimInt) = false;                         % Turn the instance off
                        loop.eventOverFlag = true;                              % Flag the event as having ended

                        % Print message if in debug mode
                        if test.debug == 1
                            disp("Stimulus #" + num2str(stimInt) + " turned off the track")
                        end
                    end                    
                end
            end
        end
        
        % Store the object's position for output
        objectY(stimInt) = object.y(stimInt);

    end
end