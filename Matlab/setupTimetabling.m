clc; clear; close all

% Creating storage structures
withCar     = struct();
towardsCar  = struct();
bike        = struct();
driver      = struct();

% Driver structure
driver.speed = 50/3.6;
driver.roadLength = 5000;
driver.timeVector = 1:1:driver.roadLength/driver.speed;

% bike values
bike.pos    = [200, 600, 1400, 2000];
bike.speed  = [14, 20, 14, 12]/3.6;
bike.type   = 1;
bike.relS   = bike.speed - driver.speed;

% withCar values
withCar.pos    = [150, 820];
withCar.speed  = [30, 30]/3.6;
withCar.type   = 2;
withCar.relS   = withCar.speed - driver.speed;

% Towards Car values
towardsCar.pos    = [500, 4700];
towardsCar.speed  = [-50, -40]/3.6;
towardsCar.type   = 3;
towardsCar.relS   = towardsCar.speed - driver.speed;

% Calling plotting function
figure;
% tiledlayout(2, 1)
nexttile
hold on
plotTimetable(bike, driver);
plotTimetable(withCar, driver);
% title("Left Lane")
% nexttile
% hold on
plotTimetable(towardsCar, driver);
% title("Right Lane")

function plotTimetable(struct, driver)
    
    switch struct.type
        case 1
            colour = 'g';
        case 2
            colour = 'r';
        case 3
            colour = 'b';
    end
    

    struct.runningPos = struct.pos;
    
    for i = driver.timeVector
        struct.runningPos(i+1, :) = struct.runningPos(i, :) + struct.relS;
    end
    
    plot(struct.runningPos, 'color', colour)
    ylim([0, 200])
    xlim([0, 200])
    yline(100, '--')
    yline(0)
    ylabel("Starting Position (m)")
    xlabel("Time (s)")
end