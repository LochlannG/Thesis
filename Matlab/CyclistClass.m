classdef CyclistClass
    properties

        % Position and speed values
        x
        y
        speed

        % OpenGL Values
        vertexCoords
        vertexColors
        elementArray


    end
    properties (Constant)
        % bike dimensions
        % https://www.nationaltransport.ie/wp-content/uploads/2023/08/Cycle-Design-Manual_Sept.-2023_High-Res.pdf
        xScale      = 0.65;                                             % What to scale the cube by in the x direction (both sides)
        yScale      = 1.8;                                              % What to scale the cube by in the y direction (both sides)
        zScale      = mean([0.8, 2.2]);                                 % What to scale the cube by in the x direction (both sides)
        rgb         = [0.46, 0.96, 0.26];                               % Colour of the cube
        curbDist    = 0.5;                                              % Distance 'cyclist' will be drawn from the curb
        maxSpeed    = 30;
    end
    methods
        function cyclist = CyclistClass(road)
            % Creating x position of 'cyclists', this is static for simplicity
            cyclist.x = cyclist.curbDist-road.laneWidth;                % X position of 'cyclist' relative to the axis system

        end

        function cyclist = getVertexes(cyclist)

            scal = [cyclist.xScale, cyclist.yScale, cyclist.zScale];
            cyclist = getShapeVertexes(cyclist, scal(1), scal(2), scal(3), cyclist.rgb, "Cube");
            
        end

        function cyclist = setPosition(cyclist, givenY)
            cyclist.y = givenY;
        end

        function cyclist = setSpeed(cyclist, givenSpeed)
            if givenSpeed <= cyclist.maxSpeed
                cyclist.speed = givenSpeed;
            else
                disp("Max Speed Exceeded")
                cyclist.speed = cyclist.maxSpeed;
            end
            
        end

        function cyclist = updateCyclistPos(cyclist, scrn)
            cyclist.y = cyclist.y + cyclist.speed/scrn.frameRate;
        end
        
    end
end