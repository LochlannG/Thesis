function [vector, newPos] = handleSpeedoVectors(camera, speedo)

    % 
    % figure
    % [a, newPos] = handleSpeedoVectors(camera, distance);
    % 
    % quiver3(camera.xyz(1), camera.xyz(2), camera.xyz(3), a(1, 1), a(1, 2), a(1, 3), 0)
    % hold on
    % axis equal
    % plot3(camera.xyz(1), camera.xyz(2), camera.xyz(3), 'ro')
    % plot3(camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), 'bo')
    % plot3(newPos(1), newPos(2), newPos(3), 'go')

    vector = camera.fixPoint - camera.xyz;
    vector = (vector/norm(vector));
    
    newPos = vector*speedo.distance + camera.xyz;
    
end

