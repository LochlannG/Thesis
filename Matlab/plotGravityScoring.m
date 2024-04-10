function [bikeDist, towardsCarDist, withCarDist] = gravityScoring(loop, towardsCar, cyclist, withCar, collisionThresholds)

    
    for i = 1:length(loop.bikeY)
        
        % Call things related to the figures
        figure;
        hold on
        title('Gravity Model of Distances to Objects')
        xlabel('Frames')
        ylabel('$\frac{1}{distance^{2}}$','Interpreter','latex', 'fontsize', 16)

        % Distances to oncoming cars
        for j = 1:height(loop.towardsCarY{i})
            towardsCarDist{j} = sqrt((loop.towardsCarY{i}(j, :) - 0).^2 + (towardsCar.x - loop.cameraX{i}).^2);
            towardsCarGrav{j} = 1./towardsCarDist{j}.^2;
            plot(towardsCarGrav{j}, 'color', 'r');
        end
        
        % Distances to bikes
        for j = 1:height(loop.bikeY{i})
            bikeDist{j} = sqrt((loop.bikeY{i}(j, :) - 0).^2 + (cyclist.x - loop.cameraX{i}).^2);
            bikeGrav{j} = 1./bikeDist{j}.^2;
            plot(bikeGrav{j}, 'color', 'g')
        end

        % Distances to in flow cars
        for j = 1:height(loop.withCarY{i})
            withCarDist{j} = sqrt((loop.withCarY{i}(j, :) - 0).^2 + (withCar.x - loop.cameraX{i}).^2);
            withCarGrav{j} = 1./withCarDist{j}.^2;
            plot(withCarGrav{j}, 'color', 'b')
        end
        
        %%%%%%%%%%%%%%%%%%%%
        % Collision Handling
        
        % Plots collision thresholds
        yline(collisionThresholds(1), 'r')     % Boundary for collision with cyclist, 'r')    % Boundary for collision with oncoming car
        yline(collisionThresholds(2), 'g')     % Boundary for collision with cyclist
        yline(collisionThresholds(3), 'b')     % Boundary for collision with in flow car
        
    end 

end