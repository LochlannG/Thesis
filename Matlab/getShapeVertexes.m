function obj = getShapeVertexes(obj, xScale, yScale, zScale, rgb, shape)
% obj = getShapeVertexes(obj, xScale, yScale, zScale, rgb, shape)
% Creates the parameters of the given shape structure required to draw it in OpenGL
%
% Inputs:
% obj              -   Structure holding details of the object that is going to be drawn as a cube.
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
% 3.0 - Changed function so that it can be used for squares as well as
% cubes

    if isempty(obj)
        obj = struct();
    end

    if shape == "Cube"
        % Coordinates of each vertex
        obj.vertexCoords = single([ 0.5,  0.5,  1;
                                     0.5,  0.5,  0;
                                     0.5, -0.5,  0;
                                     0.5, -0.5,  1;
                                    -0.5,  0.5,  1;
                                    -0.5,  0.5,  0;
                                    -0.5, -0.5,  0;
                                    -0.5, -0.5,  1]);
    
        % Figure for debugging
        % figure; scatter3(cube.vertexCoords(:, 1), cube.vertexCoords(:, 2), cube.vertexCoords(:, 3))
            
        % How the vertexes relate to each other (I wouldn't change this OpenGL is very particular about types/orders)
        obj.elementArray = int32( [0, 1, 2;
                                    3, 0, 3;
                                    7, 4, 0;
                                    4, 5, 1;
                                    6, 2, 1;
                                    5, 6, 5;
                                    4, 7, 6;
                                    7, 3, 2]); % vertex numbers for the faces

        obj.elementArray = reshape(obj.elementArray', 1, length(obj.elementArray)*3);
    
    elseif shape == "Square"

        obj.vertexCoords = single([-0.5, 0, 0;
                                    0.5, 0, 0;
                                    0.5, 1, 0;
                                   -0.5, 1, 0]);                                             % colours at each vertex
    
        obj.elementArray = int32([0, 1, 2, 3]);     
    end

    % Scale the coordinates
    nVerticies = length(obj.vertexCoords);
    scalingArray = [ones(nVerticies, 1)*xScale, ones(nVerticies, 1)*yScale, ones(nVerticies, 1)*zScale];
    obj.vertexCoords = obj.vertexCoords.*scalingArray;
    
    % Colour at each vertex
    obj.vertexColors = single(ones(nVerticies, 3).*rgb); % colours at each vertex (must be single type numbers)

    % Reshape the objects into single height arrays as OpenGL is very particular
    obj.vertexCoords = reshape(obj.vertexCoords', 1, length(obj.vertexCoords)*3);
    obj.vertexColors = reshape(obj.vertexColors', 1, length(obj.vertexColors)*3);
    
end