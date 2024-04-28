function plotGapAcceptance(bikeTable, slowdown, overtake)
    % It is probably going to be a binary regression of some form
    p_Gap = bikeTable.total.("Percieved Gap");
%     a_Gap = bikeTable.total.("Actual Gap");

    button = bikeTable.total.("Button Pressed");
    p_Gap_Over = p_Gap(button == overtake);
    p_Gap_Slow = p_Gap(button == slowdown);

    zerVect = zeros(length(p_Gap_Slow), 1);
    oneVect = ones(length(p_Gap_Over), 1);

    X = [p_Gap_Slow; p_Gap_Over];
    y = [zerVect; oneVect];

    % Logistic Regression thing
    figure
    hold on
    plot(p_Gap_Slow, 0, 'o', 'MarkerFaceColor', '#0072BD', 'MarkerEdgeColor', '#0072BD')
    plot(p_Gap_Over, 1, 'o', 'MarkerFaceColor', '#D95319', 'MarkerEdgeColor', '#D95319')
    title("Logistic Regression?")
    xlabel("Percieved Gap")
    set(gca,'yTick',[0, 1]);
    set(gca, 'YTickLabel', {'Slow Down', 'Overtake'})

    % Dot Plot
    figure
    hold on
    t = tiledlayout(2,1, "TileSpacing", "none");
    nexttile
    histogram(p_Gap_Slow, 'BinWidth', 1, "FaceColor", "#0072BD")
    maximum = 80;
    xlim([0 100])
    ylim([0 maximum])
    set(gca,'XTick',[]);
    legend("Slow Down Decision", 'Location', 'southeast')

    nexttile
    histogram(p_Gap_Over, 'BinWidth', 1, "FaceColor", "#D95319")
    set(gca, 'YDir','reverse')
    xlim([0 100])
    ylim([0 maximum])
    legend("Over Take Decision", 'Location', 'northeast')

    title(t, "Percieved Gap By Decision Made")
    xlabel(t, "Percieved Gap (m)")
    ylabel(t, "Frequency")
end