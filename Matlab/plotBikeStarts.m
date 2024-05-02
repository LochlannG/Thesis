function plotBikeStarts(table)
    levels = [20; 40; 60];

    t = tiledlayout(1, 1);
    nexttile(t);
    title(t, "Response Time by Cyclist Start Distance from Camera")
    xlabel(t, "Response Time (s)")
    ylabel(t, "Frequency")

    hold on
    for i = 1:length(levels)
        subTable = table(table.("Bike Start Y") == levels(i), :);
        for j = 1:height(subTable)
            if subTable.("Bike Start Y")(j) > subTable.("View Distance")(j)
                subTable(j, "Bike Start Y") = subTable(j, "View Distance");
            end
        end
        
        data2 = subTable.("Frame Pressed")*1/60;


        % Plot all
        data3 = data2(and(data2>0.2, data2<15));
        n = numel(data3);                                                   % Get the number of elements of data
    
        % Fit Distribution & pull out some details
        pd = fitdist(data3, "kernel");                                      % Fit kernel function
        q = icdf(pd,[0.0013499 0.99865]);                                   % Three-sigma range for normal distribution
        x = linspace(q(1), q(2));                                           % Create vector between that range
    
        % Handle histogram detailing
        [bincounts, binedges] = histcounts(data3, 'BinWidth', 0.5);                      % Create the histogram edges
        bincenters = binedges(1:end-1) + diff(binedges)/2;                  % Find the centres of the bins
%         hh = bar(bincenters, bincounts, 1);                                 % Plot the histogram with no gap between bars.
        
        % Normalize the density to match the total area of the histogram
        binwidth = binedges(2)-binedges(1);                                 % Finds the width of each bin
        area = n * binwidth;
        y = area * pdf(pd, x);                                              % Multiply the pdf by the area of the bars
        hh1 = plot(x, y,'LineWidth',2);                                % Plot the kernel function
    end

    xlim([0, 15])
    legend(num2str(levels)+"m")


    %%%%%%%%%%%%%%%%%%%%%%%
    % Plot both
    figure
    t = tiledlayout(2, 1, 'TileSpacing', 'none');
    
    title(t, "Response Time by Cyclist Start Distance from Camera By Decision")
    xlabel(t, "Response Time (s)")
    ylabel(t, "Frequency")

    nexttile(t);
    hold on
    for i = 1:length(levels)
        subTable = table(table.("Bike Start Y") == levels(i), :);
        for j = 1:height(subTable)
            if subTable.("Bike Start Y")(j) > subTable.("View Distance")(j)
                subTable(j, "Bike Start Y") = subTable(j, "View Distance");
            end
        end

        subTable = subTable(subTable.("Button Pressed")==2, :);
        
        data2 = subTable.("Frame Pressed")*1/60;


        % Plot all
        data3 = data2(and(data2>0.2, data2<15));
        n = numel(data3);                                                   % Get the number of elements of data
    
        % Fit Distribution & pull out some details
        pd = fitdist(data3, "kernel");                                      % Fit kernel function
        q = icdf(pd,[0.0013499 0.99865]);                                   % Three-sigma range for normal distribution
        x = linspace(q(1), q(2));                                           % Create vector between that range
    
        % Handle histogram detailing
        [bincounts, binedges] = histcounts(data3, 'BinWidth', 0.5);                      % Create the histogram edges
        bincenters = binedges(1:end-1) + diff(binedges)/2;                  % Find the centres of the bins
%         hh = bar(bincenters, bincounts, 1);                                 % Plot the histogram with no gap between bars.
        
        % Normalize the density to match the total area of the histogram
        binwidth = binedges(2)-binedges(1);                                 % Finds the width of each bin
        area = n * binwidth;
        y = area * pdf(pd, x);                                              % Multiply the pdf by the area of the bars
        hh1 = plot(x, y,'LineWidth',2);                                % Plot the kernel function
    end

    set(gca, 'XTick', [])
    ylim([0 10])
    xlim([0, 15])
    legend(num2str(levels)+"m")
    ylabel("Slow Down Decision")

    nexttile(t);
    ylabel("Overtake Decision")
    hold on
    for i = 1:length(levels)
        subTable = table(table.("Bike Start Y") == levels(i), :);
        for j = 1:height(subTable)
            if subTable.("Bike Start Y")(j) > subTable.("View Distance")(j)
                subTable(j, "Bike Start Y") = subTable(j, "View Distance");
            end
        end

        subTable = subTable(subTable.("Button Pressed")==3, :);
        data2 = subTable.("Frame Pressed")*1/60;


        % Plot all
        data3 = data2(and(data2>0.2, data2<15));
        n = numel(data3);                                                   % Get the number of elements of data
    
        % Fit Distribution & pull out some details
        pd = fitdist(data3, "kernel");                                      % Fit kernel function
        q = icdf(pd,[0.0013499 0.99865]);                                   % Three-sigma range for normal distribution
        x = linspace(q(1), q(2));                                           % Create vector between that range
    
        % Handle histogram detailing
        [bincounts, binedges] = histcounts(data3, 'BinWidth', 0.5);                      % Create the histogram edges
        bincenters = binedges(1:end-1) + diff(binedges)/2;                  % Find the centres of the bins
%         hh = bar(bincenters, bincounts, 1);                                 % Plot the histogram with no gap between bars.
        
        % Normalize the density to match the total area of the histogram
        binwidth = binedges(2)-binedges(1);                                 % Finds the width of each bin
        area = n * binwidth;
        y = area * pdf(pd, x);                                              % Multiply the pdf by the area of the bars
        hh1 = plot(x, y,'LineWidth',2);                                % Plot the kernel function
    end
    ylim([0 10])
    xlim([0, 15])
    set(gca, 'YDir', 'reverse')
end