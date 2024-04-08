function camera = setupCamera(car, road)


    camera                          = struct();                             % Creates a new structure

    % Camera positioning
    camera.lanePosRatio             = 0.5;                                  % Ratio of where the car is position within a lane
    camera.driverPosRatio           = 0.25;                                 % Ratio of where a driver is positioned within a car
    camera.overtakeWidth            = 1;                                    % How much the camera moves out when 'overtaking'
    camera.driverZ                  = 1.05;                                 % between [1.05, 2] https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6480464/
    camera.xyz                      = getDriverPosition(camera, car, road); % gets the camera position by estimating a car's place
    camera.fixPoint                 = [0, 100, 0];                          % Position the camera looks at (fixation point)
    camera.upVec                    = [0, 0, 1];                            % What direction is up at that fixation point

    % Camera perspective setup
    camera.FOVY                     = 70;                                   % Field of view in the y direction

    % Controlling the speed and acceleration of the camera's frame
    camera.continuousAcceleration   = ((100/3.6)/9);                        % We are assuming this car is a 2015 Golf which does 0-100 in 9 secs https://www.guideautoweb.com/en/articles/27805/volkswagen-golf-tdi-versus-golf-tsi-2015-two-tests-over-4-000-km/
    camera.discreteAcceleration     = (5/3.6);                              % Discrete acceleration doesn't worry about timing so it goes up in steps of km/h
    camera.maxSpeed                 = car.maxSpeed;                         % Just copies the max speed from the car structure
end