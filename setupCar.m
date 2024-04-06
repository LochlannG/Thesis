function car = setupCar(road)
    car = struct();
    car.startSpeed = 0;
    car.maxSpeed = 100/3.6;
    car.continuousAcceleration = ((100/3.6)/9);                                                       % We are assuming this car is a 2015 Golf which does 0-100 in 9 secs https://www.guideautoweb.com/en/articles/27805/volkswagen-golf-tdi-versus-golf-tsi-2015-two-tests-over-4-000-km/
    car.discreteAcceleration = (5/3.6);
    car.width = 1.8;
    car.lanePosRatio = 0.5;
    car.driverPosRatio = 0.5;
    car.overtakeWidth = 1;
    car.oncomingSpeed = car.maxSpeed;
    car.start = 100;
    car.x = 0.5*road.laneWidth;
    car = getCubeVertexes(car, 1, 1.5, 1, [1, 0, 0]);
end