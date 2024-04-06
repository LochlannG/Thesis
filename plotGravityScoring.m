function [bikeDist, carDist, car2Dist] = gravityScoring(loop, car, cyclist, car2, collisionThresholds)

    
    for i = 1:length(loop.bikeY)
        
        % Call things related to the figures
        figure;
        hold on
%         fontsize(gcf, 16)
        title('Gravity Model of Distances to Objects')
        xlabel('Frames')
        ylabel('$\frac{1}{distance^{2}}$','Interpreter','latex', 'fontsize', 16)

        % Distances to oncoming cars
        for j = 1:height(loop.carY{i})
            carDist{j} = sqrt((loop.carY{i}(j, :) - 0).^2 + (car.x - loop.subjectX{i}).^2);
            carGrav{j} = 1./carDist{j}.^2;
            plot(carGrav{j}, 'color', 'r');
        end
        
        % Distances to bikes
        for j = 1:height(loop.bikeY{i})
            bikeDist{j} = sqrt((loop.bikeY{i}(j, :) - 0).^2 + (cyclist.x - loop.subjectX{i}).^2);
            bikeGrav{j} = 1./bikeDist{j}.^2;
            plot(bikeGrav{j}, 'color', 'g')
        end

        % Distances to in flow cars
        for j = 1:height(loop.car2Y{i})
            car2Dist{j} = sqrt((loop.car2Y{i}(j, :) - 0).^2 + (car2.x - loop.subjectX{i}).^2);
            car2Grav{j} = 1./car2Dist{j}.^2;
            plot(car2Grav{j}, 'color', 'b')
        end
        
        %%%%%%%%%%%%%%%%%%%%
        % Collision Handling
        
        % Plots collision thresholds
        yline(collisionThresholds(1), 'r')     % Boundary for collision with cyclist, 'r')    % Boundary for collision with oncoming car
        yline(collisionThresholds(2), 'g')     % Boundary for collision with cyclist
        yline(collisionThresholds(3), 'b')     % Boundary for collision with in flow car
        
    end 

end