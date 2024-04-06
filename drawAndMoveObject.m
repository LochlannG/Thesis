function [loop, object, test, objectYStore] = drawAndMoveObject(object, loop, test, type)


    
    objectYStore = [];

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
    objectYToAppend = nan(object.n, 1);
    for stimInt = find(object.stimOn, 1, "first"):find(object.stimOn, 1, "last")
        
            if type == 1
                step = loop.bikeStep(stimInt);
            elseif type == 2
                step = loop.inFlowCarStep;
            elseif type == 3
                step = loop.oncomingCarStep;
            end

        % Draw the cyclist to the screen using the drawCyclist function
        drawCube([object.x, object.y(stimInt), 1], object);

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
                if rand() < object.chanceOfEnding
                    object.stimOn(stimInt) = false;
                    loop.eventOverFlag = true;
                    if test.debug == 1
                        disp("In-flow Car #" + num2str(stimInt) + " turned off the track")
                    end
                end
            end
        end
        

        objectYToAppend(stimInt) = object.y(stimInt);
    end

    objectYStore = [objectYStore, objectYToAppend];

end