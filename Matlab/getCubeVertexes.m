function cube = getCubeVertexes(cube, xScale, yScale, zScale, rgb)
% cube = getCubeVertexes(cube, xScale, yScale, zScale, rgb)
% Creates the parameters of the given cube structure required to draw it in OpenGL
%
% Inputs:
% cube              -   Structure holding details of the object that is going to be drawn as a cube.
% xScale            -   What to scale the cube by in the x direction (both sides)
% yScale            -   What to scale the cube by in the y direction (both sides)
% zScale            -   What to scale the cube by in the z direction (both sides)
% rgb               -   Colour of the cube. RGB values in the range [0, 1]
%
% Outputs:
% cube              -   Updated structure holding details of the cube object with new values vertexCoords, vertexColors, elementArray
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function
% 2.0 - Changed the output types to be correct, openGL is very difficult
% about that kind of thing

    if isempty(cube)
        cube = struct();
    end

    % Coordinates of each vertex
    cube.vertexCoords = single([ 0.5,  0.5,  1;
                                 0.5,  0.5,  0;
                                 0.5, -0.5,  0;
                                 0.5, -0.5,  1;
                                -0.5,  0.5,  1;
                                -0.5,  0.5,  0;
                                -0.5, -0.5,  0;
                                -0.5, -0.5,  1]);

    % Figure for debugging
    % figure; scatter3(cube.vertexCoords(:, 1), cube.vertexCoords(:, 2), cube.vertexCoords(:, 3))

    % Scale the coordinates
    nVerticies = length(cube.vertexCoords);
    scalingArray = [ones(nVerticies, 1)*xScale, ones(nVerticies, 1)*yScale, ones(nVerticies, 1)*zScale];
    cube.vertexCoords = cube.vertexCoords.*scalingArray;
    
    % Colour at each vertex
    cube.vertexColors = single(ones(nVerticies, 3).*rgb); % colours at each vertex (must be single type numbers)
    
    % How the vertexes relate to each other (I wouldn't change this OpenGL is very particular about types/orders)
    cube.elementArray = int32( [0, 1, 2;
                                3, 0, 3;
                                7, 4, 0;
                                4, 5, 1;
                                6, 2, 1;
                                5, 6, 5;
                                4, 7, 6;
                                7, 3, 2]); % vertex numbers for the faces
    
    % Reshape the objects into single height arrays as OpenGL is very particular
    cube.vertexCoords = reshape(cube.vertexCoords', 1, length(cube.vertexCoords)*3);
    cube.vertexColors = reshape(cube.vertexColors', 1, length(cube.vertexColors)*3);
    cube.elementArray = reshape(cube.elementArray', 1, length(cube.elementArray)*3);
end