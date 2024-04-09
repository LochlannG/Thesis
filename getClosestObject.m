function [whichType, whichInstance] = getClosestObject(cyclist, withCar)
    
    typeOptions             = [0, 1, 2, 3];        % equal, cyclist, withCar, neither

    closestCyclist          = min(cyclist.y(cyclist.stimOn));
    closestCar              = min(withCar.y(withCar.stimOn));

    % Get some logical information as it can get lost in the if statements
    emptyCyclist            = isempty(closestCyclist);
    emptyCar                = isempty(closestCar);
    
    cyclistCloser           = lt(closestCyclist, closestCar);
    carCloser               = gt(closestCyclist, closestCar);
    
    % Catch weird edge cases
    if and(~emptyCyclist, emptyCar)  % if the cyclist is on the screen but the car isn't then the cyclist must be closer
        carCloser           = false;
        cyclistCloser       = true;
    elseif and(emptyCyclist, ~emptyCar) % if the cyclist isn't on the screen but the car is then the car must be closer
        carCloser           = true;
        cyclistCloser       = false;
    end
    
    if closestCyclist == closestCar
        % Where they are equally far from the camera

        whichType           = typeOptions(1);
        whichInstance(1)    = cyclist.y(cyclist.y==closestCyclist);
        whichInstance(2)    = withCar.y(withCar.y==closestCar);

    elseif cyclistCloser
        % Where the cyclist is closer to the camera

        whichType           = typeOptions(2);
        whichInstance(1)    = find(cyclist.stimOn, 1);
        whichInstance(2)    = 0;

    elseif carCloser
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