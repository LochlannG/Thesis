function drawOpenGLObject(position, rotVect, rotAngl, object, whatShape)
% drawOpenGLObject(position, object, whatShape)
% Does what it says on the tin: Draws an openGL object at a given position
%
% Inputs:
% position          -   Position (x, y, z) of the object's centre (determined by vertexCoords)
% rotVect           -   Vector to rotate the object around
% rotAngl           -   Angle to rotate the object through
% object            -   The object to draw, contains vertexCoords; vertexColors; elementArray values
% whatShape         -   Which shape are you drawing, takes values ["Square", "Cube]
%
% Outputs:
% Visually draws the given object at the position given
%
% Author - Lochlann Gallagher
% Changelog (I'm not very good at maintaining this):
% 1.0 - Created function
% 2.0 - Amalgamated Cube & Square drawing into the one function for clarity
% and ease of use

    global GL

    % Draw road
    glPushMatrix;
    glTranslatef(position(1), position(2), position(3))

    if ~isempty(rotAngl) == 1
        glRotatef(rotAngl, rotVect(1), rotVect(2), rotVect(3))
    end
    
    glVertexPointer(3, GL.FLOAT, 0, object.vertexCoords);
    glColorPointer(3, GL.FLOAT, 0, object.vertexColors);
    
    glEnableClientState(GL.VERTEX_ARRAY);
    glEnableClientState(GL.COLOR_ARRAY);
    
    if whatShape == "Square"
        glDrawElements(GL.QUADS, 4, GL.UNSIGNED_INT, object.elementArray);
    elseif whatShape == "Cube"
        glDrawElements(GL.QUADS, 24, GL.UNSIGNED_INT, object.elementArray);
    end

    glDisableClientState(GL.VERTEX_ARRAY);
    glDisableClientState(GL.COLOR_ARRAY);

    glPopMatrix;
end