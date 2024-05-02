function plotReactionTime(bikeTable, bikeOrCar, binOrIn)
    
    if bikeOrCar == 1
        type = "Cyclist";
    elseif bikeOrCar == 2
        type = "Car";
    end
    
    if binOrIn(1)
        % This handles plotting all the trials together regardless of
        % subject

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

    elseif binOrIn(2)
        maxX = 15; maxY = 20;


        figure;
        t1 = tiledlayout(3, 2);
        title(t1, "Overall Response Times to " + type + " Stimuli")
        xlabel(t1, "Time (s)")
        ylabel(t1, "Frequency")
        % This handles plotting all the subjects response times
        for i = 1:length(unique(bikeTable.Subject))
            
            bikeTableCropped = bikeTable(bikeTable.Subject==i, :);

            % Overall Reaction Times - Doesn't matter if they overtook
            nexttile(t1)
            bikeReactionTimes = (bikeTableCropped.("Frame Pressed"))*1/60;
            histogram(bikeReactionTimes, 'BinWidth', 0.2)
            title("Subject # " + num2str(i))
            xlim([0 maxX])
            ylim([0 maxY])
        end

        figure;
        t2 = tiledlayout(3, 2);
        title(t2, "Reponse Times by Response Type to " + type + " Stimuli")
        xlabel(t2, "Time (s)")
        ylabel(t2, "Frequency")
        for i = 1:length(unique(bikeTable.Subject))
            
            bikeTableCropped = bikeTable(bikeTable.Subject==i, :);
            bikeReactionTimes = (bikeTableCropped.("Frame Pressed"))*1/60;

            % Reaction Times Based on which decision they made
            slowDownLog = bikeTableCropped.("Button Pressed") == 2;
            overTakeLog = bikeTableCropped.("Button Pressed") == 3;

            nexttile(t2)
            title("Subject # " + num2str(i))
            set(gca, 'XTick', [])
            set(gca, 'YTick', [])
            hold on
            t_inner = tiledlayout(t2, 2,1, "TileSpacing", "none");
            t_inner.Layout.Tile = i;
            t_inner.Layout.TileSpan = [1 1];
            nexttile(t_inner)
            histogram(bikeReactionTimes(slowDownLog), 'BinWidth', 0.2, "FaceColor", "#0072BD")
            
            xlim([0 maxX])
            ylim([0 maxY])
            set(gca,'XTick',[]);
            if i == 1
                legend("Slow Down Decision", 'Location', 'southeast')
            end
        
            nexttile(t_inner)
            histogram(bikeReactionTimes(overTakeLog), 'BinWidth', 0.2, "FaceColor", "#D95319")
            set(gca, 'YDir','reverse')
            xlim([0 maxX])
            ylim([0 maxY])
            if i == 1
                legend("Over Take Decision", 'Location', 'northeast')
            end
            
        end

    end
end