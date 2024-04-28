function plotSubjectSpecificChoice(bikeTable, slowdown, overtake, subjectNames)
    
    subjectNames = categorical(subjectNames);
    totalTable = bikeTable.("total");
    totalSlow = []; totalOver = [];
    for i = 1:length(unique(totalTable.Subject))

        currentSubLog = totalTable.Subject == i;
        currentSubBut = totalTable.("Button Pressed")(currentSubLog);

        countSlow = nnz(currentSubBut(currentSubBut==slowdown));
        countOver = nnz(currentSubBut(currentSubBut==overtake));
        
        totalSlow = [totalSlow; countSlow];
        totalOver = [totalOver; countOver];
    end

    totalCon = [totalSlow, totalOver];
    proportions = 100*totalCon./sum(totalCon, 2);
    figure
    bar(proportions, 'stacked')
    title("Proporition of Choice Made by Subject")
    set(gca, 'XTickLabel', subjectNames)
    xlabel("Subject"); ylabel("Proportion of Decision")
    legend("Slow Down", "Overtake")
end