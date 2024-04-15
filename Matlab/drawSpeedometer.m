function drawSpeedometer(loop, speedo, needle, camera)

    % Define local variables
%     speedRatio = loop.cameraVCurrent/camera.maxSpeed;

%     needlePos = speedo.xyz;
%     needlePos(2) = (speedo.xyz(1) + speedo.vertexCoords(1)) + speedo.xyz(1)*speedRatio;
    [camera.vector, speedo.xyz] = handleSpeedoVectors(camera, speedo);

    % Calculate angles to rotate around
    rotationAxis = cross(speedo.normal, camera.vector);
    rotationAngle = rad2deg(acos(dot(speedo.normal, camera.vector)));
    
    drawOpenGLObject(speedo.xyz, rotationAxis, rotationAngle, speedo, "Square")
%     drawOpenGLObject(needlePos, needle, "Square")
    
end