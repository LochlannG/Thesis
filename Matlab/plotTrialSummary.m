function averageFrameRate = plotTrialSummary(frameTimes, bikePosition, carSpeed, viewDist)

    figure;
    tiledlayout(3, 1)
    frameVector = 1:length(frameTimes);
    
    % Bike Position / View Distance Plot
    nexttile
    hold on
    plot(frameVector, bikePosition')
    plot(frameVector, viewDist(frameVector), '--');
    xlim([0 length(frameVector)])
    ylim([0, round(max(max(viewDist(frameVector))))])
    title("Bike Distance Remaining")
    ylabel("Distance (m)")
    hold off
    
    % Speed Plot
    nexttile
    hold on
    plot(frameVector, carSpeed)
%     plot(frameVector, carSpeed-params.bikeSpeed)
%     yline(params.bikeSpeed, 'g')
    title("Speeds")
    xlim([0 length(frameVector)])
    ylabel("Speed (m/s)")
    hold off
    
    % Frame Timing Plots
    nexttile
    frameTimesMS = frameTimes*1000;
    hold on
    plot(frameVector, frameTimesMS)
    yline(mean(frameTimesMS))
    xlim([0 length(frameVector)])
    text(max(frameVector), mean(frameTimesMS), " Mean = "+mean(frameTimesMS)+"ms")
    title("Frame time")
    hold off
    xlabel("Frame")

    averageFrameRate = 1/mean(frameTimes);

end