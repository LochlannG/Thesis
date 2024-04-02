function cyclist = createCylistVertexes(cyclist, xScale, yScale, zScale, rgb)

    

    % CoOrdinates of each vertex
    cyclist.vertexCoords = single( [1, 1, 1;
                                    1, 1, -1;
                                    1, -1, -1;
                                    1, -1, 1;
                                    -1, 1, 1;
                                    -1, 1, -1;
                                    -1, -1, -1;
                                    -1, -1, 1]);

    nVerticies = length(cyclist.vertexCoords);

    scalingArray = [ones(nVerticies, 1)*xScale, ones(nVerticies, 1)*yScale, ones(nVerticies, 1)*zScale];
    cyclist.vertexCoords = cyclist.vertexCoords.*scalingArray;
    
    % Colour at each vertex
    cyclist.vertexColors = single(ones(nVerticies, 3).*rgb); % colours at each vertex
    
    % How the vertexes relate to each other (I wouldn't change this)
    cyclist.elementArray = int32([0,1,2;
                                3,0,3;
                                7,4,0;
                                4,5,1;
                                6,2,1;
                                5,6,5;
                                4,7,6;
                                7,3,2]); % vertex numbers for the faces
    
    cyclist.vertexCoords = reshape(cyclist.vertexCoords', 1, length(cyclist.vertexCoords)*3);
    cyclist.vertexColors = reshape(cyclist.vertexColors', 1, length(cyclist.vertexColors)*3);
    cyclist.elementArray = reshape(cyclist.elementArray', 1, length(cyclist.elementArray)*3);
end