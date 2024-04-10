function xyz = getDriverPosition(camera, car, road)
% xyz = getDriverPosition(camera, car, road)
% Gives a (3 x 1) array of x, y, z position of where the camera should be
%
% Inputs:
% camera            -   Structure holding details of the camera object
% car               -   Structure holding details of the car object
% road              -   Structure holding details of the road object
% 
% Outputs:
% xyz               -   (3 x 1) array of x, y, z position
%
% Author - Lochlann Gallagher
% Changelog:
% 1.0 - Created function

    % x position is determined by a load of ratios.
    xyz(1) = (-1) * (road.laneWidth - road.laneWidth*camera.lanePosRatio + car.width*0.5*camera.driverPosRatio);

    % y position is just whatever I set it to be, likely -1
    xyz(2) = -1;

    % z position will be the height of the driver
    xyz(3) = camera.driverZ;

end