%% Results Calling Script
close all; clc; clear
frameRate = 60;
folder = "results";
filenames = ["a_1.mat", "b_2.mat", "c_1.mat", "d_1.mat", "e_1.mat", "f_1.mat"];
subjectNames = ["a", "b", "c", "d", "e", "f"];
slowdown = 2; overtake = 3;

% Plots all the subject reaction times
[bikeTable, carTable] = binTrials(folder, filenames, [false, false, false]);

%% Plot reaction times
% Does all subjects together
plotReactionTime(bikeTable.total, 1, [true, false]);
plotReactionTime(carTable.total, 2, [true, false]);

%% Plot Individual Response times
plotReactionTime(bikeTable.total, 1, [false, true]);
plotReactionTime(carTable.total, 2, [false, true]);

%% Reaction Times by speed?
close all
plotReactionTimeBySpeed(bikeTable.total, 1)

%% Decision by Cyclist Appearance
figure
histogram(bikeTable.total.("Bike Start Y"))
plotBikeStarts(bikeTable.total)

%% Fill the summary table
% Does all subjects together
summary = fillAndPlotSummaryTable(carTable, bikeTable, filenames, frameRate);

%% View Distance and tendancy to Overtake
% considers all subjects together
viewDist = plotViewDistProportion(bikeTable, slowdown, overtake);

%% Gap Acceptance
plotGapAcceptance(bikeTable, slowdown, overtake)

%% Individual Differences?
% Just give proportions for overtaking & slowing down behind cyclists by
% subject?
plotSubjectSpecificChoice(bikeTable, slowdown, overtake, subjectNames)

%% Throw it all in an ANOVA
clc
p = plotAnova(bikeTable);

%% Collisions
countCollisions(folder, filenames, false)

%% Plot the effect of an overtake
load("results\d_1.mat")
close all
trial = 2;
index = 1000:2100;
time = (index-1000)*1/60;
figure
t = tiledlayout(2, 1, "TileSpacing", "none");
title(t, "Decision Effect on Camera Speed")
nexttile(t)
plot(time, results.cameraV{trial}(index)*3.6)
ylabel("Speed (km/h)")
set(gca, "XTick", [])
xlim([0, max(time)])
ylim([0 100])
nexttile(t)
hold on
plot(time, results.buttonsPressed{trial}(4, index), 'color', "#D95319")
plot(time, results.buttonsPressed{trial}(6, index), 'color', "#EDB120")
legend("Slow Down", "Overtake", 'Location','southeast')
% title("Button Presses")
set(gca, "YTick", [])
ylabel("Button Presses")
xlim([0, max(time)])
xlabel("Time (s)")
