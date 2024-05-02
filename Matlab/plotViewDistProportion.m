function viewDist = plotViewDistProportion(bikeTable, slowdown, overtake)
    % This only considers bikes as we aren't really interested in decisions
    % to overtake a car.


    viewDist                = struct();
    viewDist.levels         = [20, 40, 80];
    viewDist.categories    = categorical({'20', '40', '80'});
    
    viewDist.slow.raw       = bikeTable.total.("View Distance")(bikeTable.total.("Button Pressed")==slowdown, :);
    viewDist.over.raw       = bikeTable.total.("View Distance")(bikeTable.total.("Button Pressed")==overtake, :);
    
    viewDist.slow.level1    = sum(viewDist.slow.raw == viewDist.levels(1));
    viewDist.slow.level2    = sum(viewDist.slow.raw == viewDist.levels(2));
    viewDist.slow.level3    = sum(viewDist.slow.raw == viewDist.levels(3));
    viewDist.slow.all       = [viewDist.slow.level1, viewDist.slow.level2, viewDist.slow.level3];
    
    viewDist.over.level1    = sum(viewDist.over.raw == viewDist.levels(1));
    viewDist.over.level2    = sum(viewDist.over.raw == viewDist.levels(2));
    viewDist.over.level3    = sum(viewDist.over.raw == viewDist.levels(3));
    viewDist.over.all       = [viewDist.over.level1, viewDist.over.level2, viewDist.over.level3];
    
    viewDist.all = 100*[viewDist.slow.all; viewDist.over.all]./(sum([viewDist.slow.all; viewDist.over.all]));
    
    % Plotting
    figure
    t = tiledlayout(2, 1);
    
    % Raw numbers plot
    nexttile
    bar(viewDist.categories, [viewDist.slow.all; viewDist.over.all]')
    title("Number of Overtake & Slow Down Decisions by View Distance")
    ylabel("Number of Decisions")
    xlabel("View Distance Levels (m)")
    
    % Proportion Plot
    nexttile
    bar(viewDist.categories, viewDist.all, 'stacked')
    legend("Slow Down", "Overtake")
    title("Proportion of Overtake & Slow Down Decisions by View Distance")
    ylabel("Decision Proportion (%)")
    xlabel(t, "View Distance Levels (m)")

end