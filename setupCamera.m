function camera = setupCamera(car, road)
    camera = struct();
    camera.FOVY = 70;
    camera.driverZ = 1.5;                                                             % between [1.05, 2]
    camera.xyz = driverPosition(camera, car, road);
    camera.fixPoint = [0, 100, 0];
    camera.upVec = [0, 0, 1];
end