function [object, loop, test, objectY] = drawAndMoveObject(object, loop, test, type)
% [object, loop, test, objectYStore] = drawAndMoveObject(object, loop, test, type)
% Does what it says on the tin: Handles the drawing and moving of the instances of a given OpenGL object.
% An object can have a number of instances but the only thing that changes between them is their current position
%
% Inputs:
% object            -   Structure holding details of the object to be drawn and moved
% loop              -   Structure holding details of the current trial loop
% test              -   Structure containing details of how the test is setup
% type              -   What is the object can take value [1, 2, 3]
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

    % This loop handles the logic turning a 'object' stimulus on when it
    % reaches the correct frame.
    if object.n > 0
        if object.stimStartM(object.stimCurrent) >= loop.roadLeft
            object.stimOn(object.stimCurrent) = true;
            if test.debug == 1
                disp("Oncoming car begun at frame = " + loop.currentFrame);
            end
            if object.stimCurrent < length(object.stimStartM)
                object.stimCurrent = object.stimCurrent + 1; 
            end
        end
    end

    % This loop handles the movement of the 'object'
    objectY = nan(object.n, 1);
    for stimInt = find(object.stimOn, 1, "first"):find(object.stimOn, 1, "last")
        
            if type == 1
                step = loop.bikeStep(stimInt);
            elseif type == 2
                step = loop.inFlowCarStep;
            elseif type == 3
                step = loop.oncomingCarStep;
            end

        % Draw the cyclist to the screen using the drawCyclist function
        drawOpenGLObject([object.x, object.y(stimInt), 1], object, "Cube");

        % update position based on relative speed and frame rate
        object.y(stimInt) = object.y(stimInt) - step;

        % If the y position of the 'cyclist' is less than 0 then it must
        % have reached the end of the track
        if object.y(stimInt) < 0
            object.stimOn(stimInt) = false;                        % Turn the stimulus off
            if type == 1 || type == 2
                loop.eventOverFlag = true;
            end
            if test.debug == 1
                disp(num2str(stimInt) + " finished track")          % Print message
            end
        end
        
        if type == 1 || type == 2
            if object.y(stimInt) < object.potentialEnd
                if rand()*100 < object.chanceOfEnding
                    object.stimOn(stimInt) = false;
                    loop.eventOverFlag = true;
                    if test.debug == 1
                        disp("In-flow Car #" + num2str(stimInt) + " turned off the track")
                    end
                end
            end
        end
        

        objectY(stimInt) = object.y(stimInt);
    end

%     % Append position to the object store
%     objectY = [objectY, objectY];

end