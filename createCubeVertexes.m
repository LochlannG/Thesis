function cube = createCubeVertexes(cube, xScale, yScale, zScale, rgb)

    

    % CoOrdinates of each vertex
    cube.vertexCoords = single( [1, 1, 1;
                                    1, 1, -1;
                                    1, -1, -1;
                                    1, -1, 1;
                                    -1, 1, 1;
                                    -1, 1, -1;
                                    -1, -1, -1;
                                    -1, -1, 1]);

    nVerticies = length(cube.vertexCoords);

    scalingArray = [ones(nVerticies, 1)*xScale, ones(nVerticies, 1)*yScale, ones(nVerticies, 1)*zScale];
    cube.vertexCoords = cube.vertexCoords.*scalingArray;
    
    % Colour at each vertex
    cube.vertexColors = single(ones(nVerticies, 3).*rgb); % colours at each vertex
    
    % How the vertexes relate to each other (I wouldn't change this)
    cube.elementArray = int32([0,1,2;
                                3,0,3;
                                7,4,0;
                                4,5,1;
                                6,2,1;
                                5,6,5;
                                4,7,6;
                                7,3,2]); % vertex numbers for the faces
    
    cube.vertexCoords = reshape(cube.vertexCoords', 1, length(cube.vertexCoords)*3);
    cube.vertexColors = reshape(cube.vertexColors', 1, length(cube.vertexColors)*3);
    cube.elementArray = reshape(cube.elementArray', 1, length(cube.elementArray)*3);
end