function [totalCollisions] = countCollisions(folder, filenames, plt)
    
    totalCollisions = [];
    for subjectI = 1:length(filenames)
        
        load(folder+"/"+filenames(subjectI));
            
        for trialI = 1:results.nTrials

                clear bikeDist bikeGrav withCarDist withCarGrav towardsCarDist towardsCarGrav
                
                % Distances to oncoming cars
                for objectI = 1:height(results.towardsCarY{trialI})
                    towardsCarDist{trialI}(objectI, :) = sqrt((results.towardsCarY{trialI}(objectI, :) - 0).^2 + (results.towardsCarX - results.cameraX{trialI}).^2);
                    towardsCarGrav{trialI}(objectI, :) = 1./towardsCarDist{trialI}(objectI, :).^2;
                    
                    towardsCarCollisions{subjectI, trialI}(objectI) = sum(towardsCarGrav{trialI}(objectI, :)>results.collisionThresholds(1));

                end

                % Distances to bikes
                for objectI = 1:height(results.bikeY{trialI})
                    bikeDist{trialI}(objectI, :) = sqrt((results.bikeY{trialI}(objectI, :) - 0).^2 + (results.bikeX - results.cameraX{trialI}).^2);
                    bikeGrav{trialI}(objectI, :) = 1./bikeDist{trialI}(objectI, :).^2;

                    bikeCollisions{subjectI, trialI}(objectI) = sum(bikeGrav{trialI}(objectI, :)>results.collisionThresholds(2));

                end

                % Distances to in flow cars
                for objectI = 1:height(results.withCarY{trialI})
                    withCarDist{trialI}(objectI, :) = sqrt((results.withCarY{trialI}(objectI, :) - 0).^2 + (results.withCarX - results.cameraX{trialI}).^2);
                    withCarGrav{trialI}(objectI, :) = 1./withCarDist{trialI}(objectI, :).^2;
                    
                    withCarCollisions{subjectI, trialI}(objectI) = sum(withCarGrav{trialI}(objectI, :)>results.collisionThresholds(3));

                end


        end 

        for trialI = 1:results.nTrials
            totalCollisions = [totalCollisions; any(towardsCarCollisions{subjectI, trialI}), any(bikeCollisions{subjectI, trialI}), any(withCarCollisions{subjectI, trialI})]; 
                
        end
        

    end

    figure
    plot(totalCollisions)
end