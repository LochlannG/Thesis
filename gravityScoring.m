function [bikeDist, carDist, car2Dist] = gravityScoring(loop, cyclist, car, car2)

    
    for i = 1:length(loop.bikeY)
        
        % Call things related to the figures
        figure;
        hold on
        title('Gravity Model of Distances to Objects')

        % Distances to bikes
        for j = 1:height(loop.bikeY{i})
            bikeDist{j} = sqrt((loop.bikeY{i}(j, :) - 0).^2 + (cyclist.x - loop.subjectX{i}).^2);
            plot(1./bikeDist{j}.^2, 'color', 'g')
        end

        % Distances to oncoming cars
        for j = 1:height(loop.carY{i})
            carDist{j} = sqrt((loop.carY{i}(j, :) - 0).^2 + (car.x - loop.subjectX{i}).^2);
            plot(1./carDist{j}.^2, 'color', 'r')
        end

        % Distances to in flow cars
        for j = 1:height(loop.car2Y{i})
            car2Dist{j} = sqrt((loop.car2Y{i}(j, :) - 0).^2 + (car2.x - loop.subjectX{i}).^2);
            plot(1./car2Dist{j}.^2, 'color', 'b')
        end
    end 

end