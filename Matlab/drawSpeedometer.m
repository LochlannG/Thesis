function drawSpeedometer(loop, speedo, needle, marker, camera)

    % Define local variables
    upOffset = 1;
    speedRatio = loop.cameraVCurrent/camera.maxSpeed;

    % Get the vectors of the 
    [camera.vector, speedo.xyz, needle.xyz, marker.xyz] = handleSpeedoVectors(camera, speedo);

    camera.vector(2) = camera.vector(2) + upOffset;

    % Calculate angles to rotate around
    speedo.rotationAxis = cross(speedo.normal, camera.vector);
    speedo.rotationAngle = rad2deg(acos(dot(speedo.normal, camera.vector)));
    
    needle.rotationAxis = cross(needle.normal, camera.vector);
    needle.rotationAngle = rad2deg(acos(dot(needle.normal, camera.vector)));

    marker.rotationAxis = cross(marker.normal, camera.vector);
    marker.rotationAngle = rad2deg(acos(dot(marker.normal, camera.vector)));

    % Offset them up
    speedo.xyz(3) = speedo.xyz(3) + upOffset + speedo.height;
    needle.xyz(3) = needle.xyz(3) + upOffset + speedo.height/2;
    marker.xyz(3) = marker.xyz(3) + upOffset + speedo.height/2 + marker.height/2;

    workingWidth = speedo.width*0.75;
    needle.xyz(1) = (speedo.xyz(1) - workingWidth*0.5) + workingWidth*speedRatio;

    % Draw the objects
    drawOpenGLObject(speedo.xyz, speedo.rotationAxis, speedo.rotationAngle, speedo, "Square")
    drawOpenGLObject(needle.xyz, needle.rotationAxis, needle.rotationAngle, needle, "Square")

    % Draw the markers
    drawOpenGLObject([marker.xyz(1) - workingWidth/2, marker.xyz(2), marker.xyz(3)], marker.rotationAxis, marker.rotationAngle, marker, "Square")
    drawOpenGLObject([marker.xyz(1)                 , marker.xyz(2), marker.xyz(3)], marker.rotationAxis, marker.rotationAngle, marker, "Square")
    drawOpenGLObject([marker.xyz(1) + workingWidth/2, marker.xyz(2), marker.xyz(3)], marker.rotationAxis, marker.rotationAngle, marker, "Square")
    
end