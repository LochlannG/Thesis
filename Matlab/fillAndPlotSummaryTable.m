function summary = fillAndPlotSummaryTable(carTable, bikeTable, filenames, frameRate)
    % First by subject
    % Second by total
    summary = struct();
    
    % Stack both tables
    new_filenames = ["total", erase(filenames, ".mat")];
    for i = 1:length(new_filenames)
        overallTable.(new_filenames(i)) = [bikeTable.(new_filenames(i)); carTable.(new_filenames(i))];
    end
    
    % Overall mean reaction time
    summary.mean = mean(overallTable.("total").("Frame Pressed"), 'omitnan')*(1/frameRate);
    categories = {'Overall', 'Overtaking Cyclist', 'Slowing Down Cyclist', 'Overtaking Car', 'Slowing Down Car'};
    for i = 1:length(new_filenames)-1
        % Column indexes are gonna be:
        % Overall               -> 1
        % Cyclist/Overtaking    -> 2
        % Cyclist/Slowing Down  -> 3
        % Car/Overtaking        -> 4
        % Car/Slowing Down      -> 5
        
    
        % Takes out the current subjects table
        current_Conc_Table  = overallTable.(new_filenames(i+1));
        current_Bike_Table  = bikeTable.(new_filenames(i+1));
        current_Cars_Table  = carTable.(new_filenames(i+1));
    
        % Button press extraction
        overtake = 3; slowdown = 2;
    
        overtake_Conc_Table = current_Conc_Table(current_Conc_Table.("Button Pressed") == overtake, :);
        overtake_Bike_Table = current_Bike_Table(current_Bike_Table.("Button Pressed") == overtake, :);
        overtake_Cars_Table = current_Cars_Table(current_Cars_Table.("Button Pressed") == overtake, :);
    
        slowdown_Conc_Table = current_Conc_Table(current_Conc_Table.("Button Pressed") == slowdown, :);
        slowdown_Bike_Table = current_Bike_Table(current_Bike_Table.("Button Pressed") == slowdown, :);
        slowdown_Cars_Table = current_Cars_Table(current_Cars_Table.("Button Pressed") == slowdown, :);
    
        %%%%%%%%%
        % Overall Mean Response Time
        summary.arr(i, 1) = mean(current_Conc_Table.("Frame Pressed"), "omitnan")*(1/frameRate);
        summary.std(i, 1) = std(current_Conc_Table.("Frame Pressed"), "omitnan")*(1/frameRate);
        summary.cnt(i, 1) = nnz(~isnan(current_Conc_Table.("Frame Pressed")));
    
        %%%%%%%%%
        % Cyclist
        summary.cnt(i, 2) = nnz(~isnan(overtake_Bike_Table.("Frame Pressed")));
        summary.cnt(i, 3) = nnz(~isnan(slowdown_Bike_Table.("Frame Pressed")));
    
        summary.arr(i, 2) = mean(overtake_Bike_Table.("Frame Pressed"), "omitnan")*(1/frameRate); % Overtaking
        summary.arr(i, 3) = mean(slowdown_Bike_Table.("Frame Pressed"), "omitnan")*(1/frameRate); % Slowing Down
    
        summary.std(i, 2) = std(overtake_Bike_Table.("Frame Pressed"), "omitnan")*(1/frameRate); % Overtaking
        summary.std(i, 3) = std(slowdown_Bike_Table.("Frame Pressed"), "omitnan")*(1/frameRate); % Slowing Down
        
        %%%%%%%%%
        % Cars
        summary.cnt(i, 4) = nnz(~isnan(overtake_Cars_Table.("Frame Pressed")));
        summary.cnt(i, 5) = nnz(~isnan(slowdown_Cars_Table.("Frame Pressed")));
    
        summary.arr(i, 4) = mean(overtake_Cars_Table.("Frame Pressed"), "omitnan")*(1/frameRate); % Overtaking
        summary.arr(i, 5) = mean(slowdown_Cars_Table.("Frame Pressed"), "omitnan")*(1/frameRate); % Slowing Down
    
        summary.std(i, 4) = std(overtake_Cars_Table.("Frame Pressed"), "omitnan")*(1/frameRate); % Overtaking
        summary.std(i, 5) = std(slowdown_Cars_Table.("Frame Pressed"), "omitnan")*(1/frameRate); % Slowing Down
    
    end
    
    % This will plot the values categorically :)
    meanValues = mean(summary.arr(:, 2:end), 1);
    figure
    hold on
    plot(summary.arr(:, 2:end)', 'o', 'MarkerEdgeColor', '#0072BD', 'MarkerFaceColor', '#0072BD')
    plot(meanValues, 'o', 'MarkerFaceColor', '#A2142F', 'MarkerEdgeColor', '#A2142F')
    for i = 1:4
        text(i+0.1, meanValues(i), num2str(round(meanValues(i), 2)+"s"))
    end
    xlim([0, 5])
    ylim([0, 6])
    xticks(1:4)
    xticklabels(categories(2:end))
    title("Response Time By Stimulus & Decision Made")
    ylabel("Time (s)")

end