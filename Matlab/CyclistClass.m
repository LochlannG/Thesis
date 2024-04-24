classdef CyclistClass
    properties
        potentialEnd
        chanceOfEnding
        spacing
        curbDist
        x
        y
        stimStartM
        n
        speed
        start
        stimOn
        stimGone
        stimCurrent

        % OpenGL Values
        vertexCoords
        vertexColors
        elementArray


    end
    properties (Constant)
        % bike dimensions
        % https://www.nationaltransport.ie/wp-content/uploads/2023/08/Cycle-Design-Manual_Sept.-2023_High-Res.pdf
        xScale = 0.65;                                                      % What to scale the cube by in the x direction (both sides)
        yScale = 1.8;                                                       % What to scale the cube by in the y direction (both sides)
        zScale = mean([0.8, 2.2]);                                                         % What to scale the cube by in the x direction (both sides)
        rgb = [0.46, 0.96, 0.26];                                           % Colour of the cube
    end
    methods
        function cyclist = CyclistClass(road)
    
            % Handling when the cyclist can 'disappear' from the screen
            cyclist.potentialEnd = 20;                                          % Distance from the camera when it can 'disappear'
            cyclist.chanceOfEnding = 0.01;                                      % Percentage chance of ending per frame when within that distance
            
            % Determines the minimum spacing of the 'cyclists'
            cyclist.spacing = 100;
            
            % Creating x position of 'cyclists', this is static for simplicity
            cyclist.curbDist = 0.5;                                             % Distance 'cyclist' will be drawn from the curb
            cyclist.x = cyclist.curbDist-road.laneWidth;                        % X position of 'cyclist' relative to the axis system

        end

        function cyclist = getVertexes(cyclist)

            scal = [cyclist.xScale, cyclist.yScale, cyclist.zScale];
            cyclist = getShapeVertexes(cyclist, scal(1), scal(2), scal(3), cyclist.rgb, "Cube");
            
        end

        function cyclist = resetLoop(cyclist, test)
            cyclist.stimStartM      = test.lengthM - getStimStarts(test.lengthM, 100, cyclist.spacing, test.rateCyclist, []);
            cyclist.n               = length(cyclist.stimStartM);
            cyclist.speed           = getCyclistSpeed(14/3.6, 3/3.6, 2, cyclist.n);
            cyclist.start           = getCyclistStartPos(cyclist.n);
            cyclist.y               = ones(cyclist.n, 1)*100;%.*cyclist.start';
            cyclist.stimOn          = false(cyclist.n, 1);
            cyclist.stimGone        = false(cyclist.n, 1);
            cyclist.stimCurrent     = 1;
        end

        function cyclist = setEndingVals(cyclist, givenEnd)
            cyclist.potentialEnd = givenEnd;
        end
        
        function cyclist = handleMessup(cyclist)
            messups = and(cyclist.stimOn, cyclist.stimGone);
            cyclist.stimOn(messups) = false;
        end
    end
end