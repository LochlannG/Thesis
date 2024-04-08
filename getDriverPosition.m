function xyz = getDriverPosition(camera, car, road)

    % x position is determined by a load of ratios.
    xyz(1) = (-1) * (road.laneWidth - road.laneWidth*car.lanePosRatio + car.width*0.5*car.driverPosRatio);

    % y position is just whatever I set it to be, likely -1
    xyz(2) = 0;

    % z position will be the height of the driver
    xyz(3) = camera.driverZ;

end