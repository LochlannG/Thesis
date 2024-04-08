function [whichType, whichInstance] = getClosestObject(cyclist, withCar)
    
    typeOptions             = [0, 1, 2, 3];        % equal, cyclist, withCar, neither

    closestCyclist          = min(cyclist.y(cyclist.stimOn));
    closestCar              = min(withCar.y(withCar.stimOn));

    % Get some logical information as it can get lost in the if statements
    emptyCyclist            = isempty(closestCyclist);
    emptyCar                = isempty(closestCar);
    cyclistCloser           = lt(closestCyclist, closestCar);
    carCloser               = gt(closestCyclist, closestCar);

    if closestCyclist == closestCar
        % Where they are equally far from the camera

        whichType           = typeOptions(1);
        whichInstance(1)    = cyclist.y(cyclist.y==closestCyclist);
        whichInstance(2)    = withCar.y(withCar.y==closestCar);

    elseif or(~isempty(cyclistCloser), and(emptyCar, ~emptyCyclist))
        % Where the cyclist is closer to the camera

        whichType           = typeOptions(2);
        whichInstance(1)    = find(cyclist.stimOn, 1);
        whichInstance(2)    = 0;

    elseif or(~isempty(carCloser), and(~emptyCar, emptyCyclist))
        % Where the car is closer to the camera

        whichType           = typeOptions(3);
        whichInstance(1)    = 0;
        whichInstance(2)    = find(withCar.stimOn, 1);

    else

        whichType           = typeOptions(4);
        whichInstance       = [0, 0];

    end

    whichInstance           = whichInstance';
end