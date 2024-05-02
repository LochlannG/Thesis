function plotReactionTimeBySpeed(bikeTable, bikeOrCar)
    
    %% Input handling
    if bikeOrCar == 1
        type = "Cyclist";
    elseif bikeOrCar == 2
        type = "Car";
    end

    %% Specific to the speed plotting function
    data    = (bikeTable.("Speed")*3.6);
    maxX    = 80;  maxY = 35;
    
    %% Based on what decision they made
    % This handles plotting all the trials together regardless of subject
    % Overall Speed Distribution - Doesn't matter what decision they made

    % Call a figure and seperate out the speed data
    figure; %hold on;
    t0 = tiledlayout(1, 1);
    nexttile(t0)
    data    = (bikeTable.("Speed")*3.6);                                % Take out the speed and convert it to kmph
    n       = numel(data);                                              % Get the number of elements of data

    % Fit Distribution & pull out some details
    pd      = fitdist(data, "kernel");                                  % Fit kernel function
    q       = icdf(pd,[0.0013499 0.99865]);                             % Three-sigma range for normal distribution
    x       = linspace(q(1), q(2));                                     % Create vector between that range

    % Handle histogram detailing
    [bincounts, binedges]   = histcounts(data, 15);                     % Create the histogram edges
    bincenters              = binedges(1:end-1) + diff(binedges)/2;     % Find the centres of the bins
    hh                      = bar(bincenters, bincounts, 1);            % Plot the histogram with no gap between bars.
    
    % Normalize the density to match the total area of the histogram
    binwidth    = binedges(2)-binedges(1);                              % Finds the width of each bin
    area        = n * binwidth;
    y           = area * pdf(pd, x);                                    % Multiply the pdf by the area of the bars
    hh1         = plot(x, y,'Color', "#0072BD",'LineWidth',2);          % Plot the kernel function

    % Aesthetic
    title(t0, "Driver Speed at Decision Time")
    xlabel(t0, "Speed (km/h)")
    ylabel(t0, "Frequency")
    xlim([0 max(data)])
    

    %% Based on what decision they made
    % This handles plotting all the trials together regardless of subject
    % Speed Distributions Segregated by decision made

    %%%%%%%%%%%%%%
    % Setup the plotting environment

    % Pull out the decisions
    slowDownLog = bikeTable.("Button Pressed") == 2;
    overTakeLog = bikeTable.("Button Pressed") == 3;

    % Set up the tiledlayout
    figure
    hold on
    t = tiledlayout(2, 1, "TileSpacing", "none");

    %%%%%%%%%%%%%%
    % Histogram 
    nexttile; %hold on;
    data2 = data(slowDownLog);                                          % Take out the speed and convert it to kmph
    n = numel(data2);                                                   % Get the number of elements of data

    % Fit Distribution & pull out some details
    pd = fitdist(data2, "kernel");                                      % Fit kernel function
    q = icdf(pd,[0.0013499 0.99865]);                                   % Three-sigma range for normal distribution
    x = linspace(q(1), q(2));                                           % Create vector between that range

    % Handle histogram detailing
    [bincounts, binedges] = histcounts(data2, 15);                      % Create the histogram edges
    bincenters = binedges(1:end-1) + diff(binedges)/2;                  % Find the centres of the bins
    hh = bar(bincenters, bincounts, 1);                                 % Plot the histogram with no gap between bars.
    
    % Normalize the density to match the total area of the histogram
    binwidth = binedges(2)-binedges(1);                                 % Finds the width of each bin
    area = n * binwidth;
    y = area * pdf(pd, x);                                              % Multiply the pdf by the area of the bars
    hh1 = plot(x, y,'Color', "#0072BD",'LineWidth',2);                                % Plot the kernel function

    % Aesthetic
    xlim([0 maxX])
    ylim([0 maxY])
    set(gca,'XTick',[]);
    legend("Slow Down Decision", 'Location', 'southeast')

    %%%%%%%%%%%%%%
    % Overtake box
    nexttile; %hold on;
    data3 = data(overTakeLog);                                          % Take out the speed and convert it to kmph
    n = numel(data3);                                                   % Get the number of elements of data

    % Fit Distribution & pull out some details
    pd = fitdist(data3, "kernel");                                      % Fit kernel function
    q = icdf(pd,[0.0013499 0.99865]);                                   % Three-sigma range for normal distribution
    x = linspace(q(1), q(2));                                           % Create vector between that range

    % Handle histogram detailing
    [bincounts, binedges] = histcounts(data3, 15);                      % Create the histogram edges
    bincenters = binedges(1:end-1) + diff(binedges)/2;                  % Find the centres of the bins
    hh = bar(bincenters, bincounts, 1);                                 % Plot the histogram with no gap between bars.
    
    % Normalize the density to match the total area of the histogram
    binwidth = binedges(2)-binedges(1);                                 % Finds the width of each bin
    area = n * binwidth;
    y = area * pdf(pd, x);                                              % Multiply the pdf by the area of the bars
    hh1 = plot(x, y,'Color', "#D95319",'LineWidth',2);                                % Plot the kernel function
    set(gca, 'YDir','reverse')

    % Aesthetic
    title(t, "Driver Speed at Decision Time")
    xlabel(t, "Speed (km/h)")
    ylabel(t, "Frequency")
    xlim([0 maxX])
    ylim([0 maxY])
    legend("Overtake Decision", 'Location', 'southeast')

    %% Based on their view distance
    % This handles plotting all the trials together regardless of subject
    % Speed Distributions Segregated by decision made & by viewing distance

    %%%%%%%%%%%%%%
    % Setup the plotting environment
    maxX = 80; maxY = 15;

    % Pull out the decisions
    slowDownLog = bikeTable.("Button Pressed") == 2;
    overTakeLog = bikeTable.("Button Pressed") == 3;
    viewLevels = [20, 40, 80];
    data = bikeTable;

    % Set up the tiledlayout
    figure
    hold on
    t = tiledlayout(2, 1, "TileSpacing", "none");

    %%%%%%%%%%%%%%
    % Histogram - Slow Down
    nexttile; hold on;
    
    for i = 1:length(viewLevels)
        data2 = data.("Speed")(and(data.("View Distance")==viewLevels(i), slowDownLog), :)*3.6;
        n = numel(data2);                                                   % Get the number of elements of data
    
        % Fit Distribution & pull out some details
        pd = fitdist(data2, "kernel");                                      % Fit kernel function
        q = icdf(pd,[0.0013499 0.99865]);                                   % Three-sigma range for normal distribution
        x = linspace(q(1), q(2));                                           % Create vector between that range
    
        % Handle histogram detailing
        [bincounts, binedges] = histcounts(data2, 15);                      % Create the histogram edges
        bincenters = binedges(1:end-1) + diff(binedges)/2;                  % Find the centres of the bins
    %     hh = bar(bincenters, bincounts, 1);                                 % Plot the histogram with no gap between bars.
        
        % Normalize the density to match the total area of the histogram
        binwidth = binedges(2)-binedges(1);                                 % Finds the width of each bin
        area = n * binwidth;
        y = area * pdf(pd, x);                                              % Multiply the pdf by the area of the bars
        hh1 = plot(x, y,'LineWidth',2);                                % Plot the kernel function
    end
    % Aesthetic
    xlim([0 maxX])
    ylim([0 maxY])
    set(gca,'XTick',[]);
    ylabel("Slow Down Decision")
    
    legend("20m", "40m", "80m", 'Location', 'northeast')

    %%%%%%%%%%%%%%
    % Histogram - Slow Down
    nexttile; hold on;
    ylabel("Overtake Decisions")
    
    for i = 1:length(viewLevels)
        data2 = data.("Speed")(and(data.("View Distance")==viewLevels(i), overTakeLog), :)*3.6;
        n = numel(data2);                                                   % Get the number of elements of data
    
        % Fit Distribution & pull out some details
        pd = fitdist(data2, "kernel");                                      % Fit kernel function
        q = icdf(pd,[0.0013499 0.99865]);                                   % Three-sigma range for normal distribution
        x = linspace(q(1), q(2));                                           % Create vector between that range
    
        % Handle histogram detailing
        [bincounts, binedges] = histcounts(data2, 15);                      % Create the histogram edges
        bincenters = binedges(1:end-1) + diff(binedges)/2;                  % Find the centres of the bins
    %     hh = bar(bincenters, bincounts, 1);                                 % Plot the histogram with no gap between bars.
        
        % Normalize the density to match the total area of the histogram
        binwidth = binedges(2)-binedges(1);                                 % Finds the width of each bin
        area = n * binwidth;
        y = area * pdf(pd, x);                                              % Multiply the pdf by the area of the bars
        hh1 = plot(x, y,'LineWidth',2);                                % Plot the kernel function
    end
    
    set(gca, 'YDir','reverse')
    

    % Aesthetic
    title(t, "Driver Speed at Decision Time")
    xlabel(t, "Speed (km/h)")
    ylabel(t, "Frequency")
    xlim([0 maxX])
    ylim([0 maxY])

    %% Setting Speed Based on their view distance
    % This handles plotting all the trials together regardless of subject
    % Speed Distributions Segregated by decision made & by viewing distance

    %%%%%%%%%%%%%%
    % Setup the plotting environment
    maxX = 80; maxY = 30;

    % Pull out the decisions
    slowDownLog = bikeTable.("Button Pressed") == 2;
    overTakeLog = bikeTable.("Button Pressed") == 3;
    viewLevels = [20, 40, 80];
    data = bikeTable;

    % Set up the tiledlayout
    figure
    hold on
    t = tiledlayout(1, 1, "TileSpacing", "none");

    %%%%%%%%%%%%%%
    % Histogram - Slow Down
    nexttile; hold on;

    for i = 1:length(viewLevels)
        lens(i) = length(data.("Speed")(data.("View Distance")==viewLevels(i), :)*3.6);
    end
    
    data2 = nan(max(lens(i)), length(viewLevels));

    for i = 1:length(viewLevels)
        data2(1:lens(i), i) = data.("Speed")(data.("View Distance")==viewLevels(i), :)*3.6;
        n = numel(data2(:, i));                                                   % Get the number of elements of data
    
        % Fit Distribution & pull out some details
        pd = fitdist(data2(:, i), "kernel");                                      % Fit kernel function
        q = icdf(pd,[0.0013499 0.99865]);                                   % Three-sigma range for normal distribution
        x = linspace(q(1), q(2));                                           % Create vector between that range
    
        % Handle histogram detailing
        [bincounts, binedges] = histcounts(data2(:, i), 15);                      % Create the histogram edges
        bincenters = binedges(1:end-1) + diff(binedges)/2;                  % Find the centres of the bins
    %     hh = bar(bincenters, bincounts, 1);                                 % Plot the histogram with no gap between bars.
        
        % Normalize the density to match the total area of the histogram
        binwidth = binedges(2)-binedges(1);                                 % Finds the width of each bin
        area = n * binwidth;
        y = area * pdf(pd, x);                                              % Multiply the pdf by the area of the bars
        hh1 = plot(x, y,'LineWidth',2);                                % Plot the kernel function
    end
    % Aesthetic
    xlim([0 maxX])
    ylim([0 maxY])
    legend("20m", "40m", "80m", 'Location', 'northeast')
    

    % Aesthetic
    title(t, "Driver Speed By View Distance")
    xlabel(t, "Speed (km/h)")
    ylabel(t, "Frequency")
    xlim([0 maxX])
    ylim([0 maxY])

    %% Do an ANOVA
    [p, t, stats] = anova1(data2, ["20m", "40m", "80m"]);
    disp(p)
    [c1,m,h,gnames] = multcompare(stats);
    tbl1 = array2table(c1,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
    disp(tbl1)
end