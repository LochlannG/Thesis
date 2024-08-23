classdef CarClass
    properties
        % Variables
        x       % What x position is the car in? (Distance from centreline)
        y       % What y position is the car in? (Position along road)
        speed   % What speed is the car going?
        which   % Which lane is the car in

        % OpenGL values, don't worry about it
        vertexCoords
        vertexColors
        elementArray

    end
    properties (Constant)
        maxSpeed        = 50/3.6;
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
            if car.which == "right"
                car.x       = 0.5*road.laneWidth;
                car.speed   = -car.maxSpeed;
            elseif car.which == "left"
                car.x       = -0.5*road.laneWidth;
                car.speed   = car.maxSpeed;
            end
        end

        function car = getVertexes(car)
            % Gets vertexes of the 'car'
            car = getShapeVertexes(car, car.width, car.len, car.height, [1, 0, 0], "Cube");
        end

        function car = setPosition(car, startY)
            car.y = startY;
        end

        function car = setSpeed(car, givenSpeed)
            if givenSpeed <= car.maxSpeed
                car.speed = givenSpeed;
            else
                disp("Max Speed Exceeded")
                car.speed = car.maxSpeed;
            end
            
        end

        function car = updateCarPos(car, scrn)
            car.y = car.y + car.speed/scrn.frameRate;
        end
        
    end
end