function drawSpeedometer(loop, speedo, needle, camera)
    
    % Define local constants
    speedoPos = [0, 3, 1];

    % Define local variables
    speedRatio = loop.cameraVCurrent/camera.maxSpeed;

    needlePos = speedoPos;
    needlePos(2) = (speedoPos(1) + speedo.vertexCoords(1)) + speedoPos(1)*speedRatio;

    drawOpenGLObject(speedoPos, speedo, "Square")
    drawOpenGLObject(needlePos, needle, "Square")
    
end