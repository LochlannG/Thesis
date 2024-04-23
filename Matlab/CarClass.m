classdef CarClass
    properties
        % Variables
        x
        y
        n
        speed
        stimStartM
        stimCurrent
        stimOn
        stimGone                    % The stimulus has disappeared
        which

        % OpenGL values
        vertexCoords
        vertexColors
        elementArray

        % Specific to the car in 'this' lane I should use a child class but cannot be bothered
        potentialEnd                % The distance from the camera where the object can disappear

    end
    properties (Constant)
        maxSpeed        = 80/3.6;
        start           = 80;

        chanceOfEnding  = 0.01           % Chance of ending per frame
        spacing         = 60             % Minimum Distance between objects

        % Dimensions
        % https://www.nimblefins.co.uk/cheap-car-insurance/average-car-dimensions
        % used the 'hatchback' values
        width       = 1.78;                              
        height      = 1.455;
        len         = 4.27;
    end
    methods
        function car = CarClass(road, whichLane)
            car.which = whichLane;
            if car.which == "other"
                car.x       = 0.5*road.laneWidth;
                car.speed   = car.maxSpeed;
            elseif car.which == "this"
                car.x       = -0.5*road.laneWidth;
            end
        end

        function car = getVertexes(car)
            % Gets vertexes of the 'car'
            car = getShapeVertexes(car, car.width, car.len, car.height, [1, 0, 0], "Cube");
        end

        function car = setEndingVals(car, givenEnd)
            car.potentialEnd    = givenEnd;
        end

        function car = resetLoop(car, test, cyclist, rate)
            if car.which == "other"
                car.stimStartM   = test.lengthM - getStimStarts(test.lengthM, car.start, car.spacing, rate, []);
            elseif car.which == "this"
                car.stimStartM   = test.lengthM - getStimStarts(test.lengthM, car.start, car.spacing, rate, test.lengthM-cyclist.stimStartM);
            end
            car.n            = length(car.stimStartM);
            car.stimCurrent  = 1;
            car.y            = ones(car.n, 1)*car.start;
            car.stimOn       = false(car.n, 1);
            car.stimGone     = false(car.n, 1);

        end

        function car = setSpeed(car, givenSpeed)
            car.speed = givenSpeed;
        end
        
        function car = handleMessup(car)
            messups = and(car.stimOn, car.stimGone);
            car.stimOn(messups) = false;
        end
    end
end