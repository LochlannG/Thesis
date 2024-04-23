classdef ResultsClass
    % ResultsClass Class containing the various properties and functions used to handle the results storage and plotting
    
    properties
        % Identifying the subject & test type
        subjectCode
        nTrials
        recordEEG
        recordEMG
        lengthM
        givenFrameRT
        
        % Individual Trial Variables
        time
        road
        
        % X positions of objects
        bikeX
        towardsCarX
        withCarX
        
        % Y positions of objects
        bikeY
        towardsCarY
        withCarY
        
        % Bike Start Levels
        bikeStartLevels
        
        % Binary user choice recordings
        buttonsPressed
        
        % Camera Variables
        cameraX
        cameraV
        cameraView
        
        % Distances between camera and objects/Available Gap
        whatFirst
        whichFirst
        gap
        
        % Gravity Scores
        bikeDist
        carDist
        car2Dist
        
        % Calculated Values
        averageFrameRate
        saved
    end
    
    properties (Constant)
        collisionThresholds           = [0.15, 0.7, 0.8];           % order of R, G, B -> towardsCar, Cyclist, withCar
    end
    
    methods
        function results = ResultsClass(test, scrn)
            %ResultsClass Construct an instance of this class
            results.subjectCode     = test.subjectCode;
            results.nTrials         = test.trials;
            results.recordEEG       = test.recordEEG;
            results.recordEMG       = test.recordEMG;
            results.lengthM         = test.lengthM;
            results.givenFrameRT    = scrn.frameRate;
            results.saved           = false;
            
        end
        
        function results = recordXPositions(results, withCar, towardsCar, cyclist)
            % Records x positions of objects at the top of a script
            
            % X positions of objects
            results.bikeX       = cyclist.x;
            results.towardsCarX = towardsCar.x;
            results.withCarX    = withCar.x;

            
        end
        
        function results = recordBikeStarts(results, loop, cyclist)
           
            results.bikeStartLevels{loop.currentTrial}  = cyclist.start;
            
        end

        function results = updateResults(results, loop)
        % Current

            % Some of the task variables in the current loop
            results.time{loop.currentTrial}             = loop.timeStore;           % Records the frame times
            results.road{loop.currentTrial}             = loop.roadStore;           % Records the road left at each frame
            
            % Y positions
            results.bikeY{loop.currentTrial}            = loop.bikeYStore;          % Records the y position of the bikes
            results.towardsCarY{loop.currentTrial}      = loop.towardsCarYStore;    % Records the y position of the oncoming cars
            results.withCarY{loop.currentTrial}         = loop.withCarYStore;       % Records the y position of the cars in the lane

            % Camera Variables
            results.cameraX{loop.currentTrial}          = loop.cameraXStore;        % Records the x position of the camera
            results.cameraV{loop.currentTrial}          = loop.cameraVStore;        % Records the speed of the camera
            results.cameraView{loop.currentTrial}       = loop.yNoiseStore;         % Records how far the camera can see

            % Distances between Camera/Available gap
            results.whatFirst{loop.currentTrial}        = loop.whichTypeStore;      % Records what type of object is first in your lane
            results.whichFirst{loop.currentTrial}       = loop.whichInstanceStore;  % Records which instance of that object is first in your lane
            results.gap{loop.currentTrial}              = loop.gapStore;            % Records the gaps in the right lane
            
            % User choice recording
            results.buttonsPressed{loop.currentTrial}   = loop.keysStore;
        end
        
        function [bikeDist, towardsCarDist, withCarDist] = plotGravityScoring(results)
            % Plots the 'gravity' scores

            for i = 1:length(results.bikeY)

                % Call things related to the figures
                figure;
                hold on
                title('Gravity Model of Distances to Objects')
                xlabel('Frames')
                ylabel('$\frac{1}{distance^{2}}$','Interpreter','latex', 'fontsize', 16)

                % Distances to oncoming cars
                for j = 1:height(results.towardsCarY{i})
                    towardsCarDist{i}(j, :) = sqrt((results.towardsCarY{i}(j, :) - 0).^2 + (results.towardsCarX - results.cameraX{i}).^2);
                    towardsCarGrav{i}(j, :) = 1./towardsCarDist{i}(j, :).^2;
                    plot(towardsCarGrav{i}, 'color', 'r');
                end

                % Distances to bikes
                for j = 1:height(results.bikeY{i})
                    bikeDist{i}(j, :) = sqrt((results.bikeY{i}(j, :) - 0).^2 + (results.bikeX - results.cameraX{i}).^2);
                    bikeGrav{i}(j, :) = 1./bikeDist{i}(j, :).^2;
                    plot(bikeGrav{i}, 'color', 'g')
                end

                % Distances to in flow cars
                for j = 1:height(results.withCarY{i})
                    withCarDist{i}(j, :) = sqrt((results.withCarY{i}(j, :) - 0).^2 + (results.withCarX - results.cameraX{i}).^2);
                    withCarGrav{i}(j, :) = 1./withCarDist{i}(j, :).^2;
                    plot(withCarGrav{i}(j, :), 'color', 'b')
                end

                %%%%%%%%%%%%%%%%%%%%
                % Collision Handling

                % Plots collision thresholds
                yline(results.collisionThresholds(1), 'r')     % Boundary for collision with cyclist, 'r')    % Boundary for collision with oncoming car
                yline(results.collisionThresholds(2), 'g')     % Boundary for collision with cyclist
                yline(results.collisionThresholds(3), 'b')     % Boundary for collision with in flow car

            end 

        end
        
        function results = plotTrialSummary(results, frameRTplot)
            
            for i = 1:results.nTrials

                figure;
                tiledlayout(3, 1)
                frameVector = 1:length(results.time{i});

                % Bike Position / View Distance Plot
                nexttile
                hold on
                plot(frameVector, results.bikeY{i}', 'color', 'g')
                plot(frameVector, results.withCarY{i}', 'color', 'b')
                plot(frameVector(1:end-1), results.cameraView{i}(frameVector(1:end-1)), '--');
                xlim([0 length(frameVector)])
                ylim([0, round(max(max(results.cameraView{i}(frameVector(1:end-1)))))])
                title("Bike Distance Remaining")
                ylabel("Distance (m)")
                hold off

                % Speed Plot
                nexttile
                hold on
                plot(frameVector, results.cameraV{i})
                title("Speeds")
                xlim([0 length(frameVector)])
                ylabel("Speed (m/s)")
                hold off

                % Button Presses
                nexttile
                buttons = results.buttonsPressed{i};
                for j = 1:height(buttons)
                   buttons(j, :) = buttons(j, :) + j; 
                end
                plot(frameVector(1:end-1), buttons')
                set(gca,'YTick',[])
                ylim([0 7])
                
                % Frame Timing Plots
                if frameRTplot
                    figure;
                    frameTimesMS = results.time{i}*1000;
                    hold on
                    plot(frameVector, frameTimesMS)
                    yline(mean(frameTimesMS))
                    xlim([0 length(frameVector)])
                    text(max(frameVector), mean(frameTimesMS), " Mean = "+mean(frameTimesMS)+"ms")
                    title("Frame time")
                    hold off
                    xlabel("Frame")
                end

                results.averageFrameRate{i} = 1/mean(frameTimesMS);
            
            end

        end
        
        function results = saveResults(results)
            % Save results
            
            filename = string(['results/', results.subjectCode, '.mat']);
            save(filename, 'results');
            results.saved = true;
        end

    end
end

