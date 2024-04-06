function cyclist = setupCyclist(road)

    cyclist = struct();
    cyclist.curbDist = 0.5;
    cyclist.potentialEnd = 10;
    cyclist.chanceOfEnding = 0.001;
    
    % Generate sample stamps that mark when the 'cyclists' will appear
    cyclist.x = cyclist.curbDist-road.laneWidth;

    xScale = 0.25;
    yScale = 1.5;
    zScale = 1;
    rgb = [0.46, 0.96, 0.26];

    cyclist = getCubeVertexes(cyclist, xScale, yScale, zScale, rgb);
end