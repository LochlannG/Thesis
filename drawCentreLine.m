function drawCentreLine()

    % Draw Static Centrelines
    % Generate the coordinates of the four spots.
    centreLineHeight = 0.01; % This is defined to make sure the lines show up
    lineCorners = [-params.centreLineWidth, 0, centreLineHeight;
                   +params.centreLineWidth, 0, centreLineHeight;
                   +params.centreLineWidth, params.roadDist, centreLineHeight;
                   -params.centreLineWidth, params.roadDist, centreLineHeight];

    glBegin(GL.QUADS);
    glColor3ub(255, 255, 255)
    glVertex3f(lineCorners(1, 1), lineCorners(1, 2), lineCorners(1, 3))
    glVertex3f(lineCorners(2, 1), lineCorners(2, 2), lineCorners(2, 3))
    glVertex3f(lineCorners(3, 1), lineCorners(3, 2), lineCorners(3, 3))
    glVertex3f(lineCorners(4, 1), lineCorners(4, 2), lineCorners(4, 3))
    glEnd;
    
end