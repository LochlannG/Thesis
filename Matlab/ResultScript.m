%% Results Calling Script
frameRate = 60;
folder = "results";
filenames = ["a_1.mat", "b_2.mat", "c_1.mat", "d_1.mat", "e_1.mat", "f_1.mat"];
subjectNames = ["a", "b", "c", "d", "e", "f"];
slowdown = 2; overtake = 3;

% Plots all the subject reaction times
[bikeTable, carTable] = binTrials(folder, filenames, [false, true, false]);

%% Plot reaction times
% Does all subjects together
plotReactionTime(bikeTable.total, 1);
plotReactionTime(carTable.total, 2)

%% Fill the summary table
% Does all subjects together
summary = fillAndPlotSummaryTable(carTable, bikeTable, filenames, frameRate);

%% View Distance and tendancy to Overtake
% considers all subjects together
viewDist = plotViewDistProportion(bikeTable, slowdown, overtake);

%% View Distance and Speed Setting


%% Gap Acceptance
plotGapAcceptance(bikeTable, slowdown, overtake)

%% Individual Differences?
% Just give proportions for overtaking & slowing down behind cyclists by
% subject?
clc; close all
plotSubjectSpecificChoice(bikeTable, slowdown, overtake, subjectNames)

%% Throw it all in an ANOVA
clc
plotAnova(bikeTable)