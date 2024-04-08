function cyclist = setupCyclist(road)
% cyclist = setupCyclist(road)
% Creates the 'cyclist' structure, used to change details of who that
% object is placed and rendered
%
% Inputs:
% road              -   Structure holding details of the 'road' object
%
% Outputs:
% cyclist           -   Structure holding details of the 'cyclist' object
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function

    cyclist = struct();                                                 % Create Structure
    
    % Handling when the cyclist can 'disappear' from the screen
    cyclist.potentialEnd = 5;                                           % Distance from the camera when it can 'disappear'
    cyclist.chanceOfEnding = 1;                                         % Percentage chance of ending per frame when within that distance
    
    % Creating x position of 'cyclists', this is static for simplicity
    cyclist.curbDist = 0.5;                                             % Distance 'cyclist' will be drawn from the curb
    cyclist.x = cyclist.curbDist-road.laneWidth;                        % X position of 'cyclist' relative to the axis system

    % Creating the openGL values
    xScale = 0.25;                                                      % What to scale the cube by in the x direction (both sides)
    yScale = 1.5;                                                       % What to scale the cube by in the y direction (both sides)
    zScale = 1;                                                         % What to scale the cube by in the x direction (both sides)
    rgb = [0.46, 0.96, 0.26];                                           % Colour of the cube
    cyclist = getCubeVertexes(cyclist, xScale, yScale, zScale, rgb);    % Create the object
    
end