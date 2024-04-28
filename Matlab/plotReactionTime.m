function plotReactionTime(bikeTable, bikeOrCar)
    
    if bikeOrCar == 1
        type = "Cyclist";
    elseif bikeOrCar == 2
        type = "Car";
    end

    % Overall Reaction Times - Doesn't matter if they overtook
    figure
    bikeReactionTimes = (bikeTable.("Frame Pressed"))*1/60;
    histogram(bikeReactionTimes, 'BinWidth', 0.2)
    title("Overall Response Times to " + type + " Stimuli")
    xlabel("Time (s)")
    ylabel("Frequency")
    xlim([0 max(bikeReactionTimes)])
    
    % Reaction Times Based on which decision they made
    slowDownLog = bikeTable.("Button Pressed") == 2;
    overTakeLog = bikeTable.("Button Pressed") == 3;

    figure
    hold on
    t = tiledlayout(2,1, "TileSpacing", "none");
    nexttile
    histogram(bikeReactionTimes(slowDownLog), 'BinWidth', 0.2, "FaceColor", "#0072BD")
    axisHandle = gca;
    maximum = max(axisHandle.Children.Values);
    xlim([0 max(bikeReactionTimes)])
    ylim([0 maximum])
    set(gca,'XTick',[]);
    legend("Slow Down Decision", 'Location', 'southeast')

    nexttile
    histogram(bikeReactionTimes(overTakeLog), 'BinWidth', 0.2, "FaceColor", "#D95319")
    set(gca, 'YDir','reverse')
    xlim([0 max(bikeReactionTimes)])
    ylim([0 maximum])
    legend("Over Take Decision", 'Location', 'northeast')

    title(t, "Reponse Times by Response Type to " + type + " Stimuli")
    xlabel(t, "Time (s)")
    ylabel(t, "Frequency")
end