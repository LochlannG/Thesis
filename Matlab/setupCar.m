function car = setupCar(road)


    car = struct();                                         % Creates a new structure

    % Speed
    car.maxSpeed        = 100/3.6;                          % Maximum speed of the car
    car.oncomingSpeed   = car.maxSpeed;                     % Set the speed of an oncoming car to the max

    % Positioning                            
    car.start           = 100;                              % How far from the camera does the car start
    car.x               = 0.5*road.laneWidth;               % Assumes the car is driving down the middle of the lane

    % Drawing
    car.width           = 1.8;                              % Width of average irish car https://www.thejournal.ie/car-width-parking-ireland-6284300-Jan2024/
    car                 = getCubeVertexes(car, 1, car.width, 1, [1, 0, 0]);

end