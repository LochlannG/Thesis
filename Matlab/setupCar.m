function car = setupCar(road)


    car = struct();                                         % Creates a new structure

    % Speed
    car.maxSpeed        = 100/3.6;                          % Maximum speed of the car
    car.oncomingSpeed   = car.maxSpeed;                     % Set the speed of an oncoming car to the max

    % Positioning                            
    car.start           = 100;                              % How far from the camera does the car start
    car.x               = 0.5*road.laneWidth;               % Assumes the car is driving down the middle of the lane
    car.spacing         = 10;                               % Minimum Distance between cars
    
    % Drawing
    % https://www.nimblefins.co.uk/cheap-car-insurance/average-car-dimensions
    % used the 'hatchback' values
    car.width           = 1.78;                              
    car.height          = 1.455;
    car.length          = 4.27;
    car                 = getCubeVertexes(car, car.width, car.length, car.height, [1, 0, 0]);

end