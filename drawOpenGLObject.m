function drawOpenGLObject(position, object, whatShape)
% drawOpenGLObject(position, object, whatShape)
% Does what it says on the tin: Draws an openGL object at a given position
%
% Inputs:
% Position          -   Structure holding details of the object to be drawn and moved
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