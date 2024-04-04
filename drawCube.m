function drawCube(position, structure)

    global GL

    % Draw Cube
    glPushMatrix;
    glTranslatef(position(1), position(2), position(3))
    
    glVertexPointer(3, GL.FLOAT, 0, structure.vertexCoords);
    glColorPointer(3, GL.FLOAT, 0, structure.vertexColors);
    
    glEnableClientState(GL.VERTEX_ARRAY);
    glEnableClientState(GL.COLOR_ARRAY);
    
    glDrawElements(GL.QUADS, 24, GL.UNSIGNED_INT, structure.elementArray);

    glDisableClientState(GL.VERTEX_ARRAY);
    glDisableClientState(GL.COLOR_ARRAY);

    glPopMatrix;

end