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
    cyclist.potentialEnd = 20;                                          % Distance from the camera when it can 'disappear'
    cyclist.chanceOfEnding = 0.01;                                      % Percentage chance of ending per frame when within that distance
    
    % Determines the minimum spacing of the 'cyclists'
    cyclist.spacing = 50;
    
    % Creating x position of 'cyclists', this is static for simplicity
    cyclist.curbDist = 0.5;                                             % Distance 'cyclist' will be drawn from the curb
    cyclist.x = cyclist.curbDist-road.laneWidth;                        % X position of 'cyclist' relative to the axis system

    % Creating the openGL values
    % bike dimensions
    % https://www.nationaltransport.ie/wp-content/uploads/2023/08/Cycle-Design-Manual_Sept.-2023_High-Res.pdf
    xScale = 0.65;                                                      % What to scale the cube by in the x direction (both sides)
    yScale = 1.8;                                                       % What to scale the cube by in the y direction (both sides)
    zScale = mean([0.8, 2.2]);                                                         % What to scale the cube by in the x direction (both sides)
    rgb = [0.46, 0.96, 0.26];                                           % Colour of the cube
    cyclist = getCubeVertexes(cyclist, xScale, yScale, zScale, rgb);    % Create the object
    
end