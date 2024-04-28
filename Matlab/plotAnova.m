function statResults = plotAnova(bikeTable)
    reducedTable = bikeTable.total(:, [1, 7, 9, 11]);
    reducedTable(reducedTable.("Button Pressed")==1, :) = [];
    reducedTable(isnan(reducedTable.("Button Pressed")), :) = [];

    buttons = reducedTable.("Button Pressed");
    subject = reducedTable.("Subject");
    viewDis = reducedTable.("View Distance");
    pGap    = reducedTable.("Percieved Gap");

    statTable = table(subject, viewDis, pGap, buttons)
    statResults = anova(statTable, "buttons");
end