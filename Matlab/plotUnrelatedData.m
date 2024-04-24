close all; clc; clear

dublin = [0.16	0.31	0.16	0.19	0.11	0.03	0.04];
nationally = [0.09	0.26	0.14	0.19	0.15	0.06	0.09];
Y = [dublin; nationally]*100;
X = categorical({'<1km', '1-3km', '3-5km', '5-10km', '10-20km', '20-30km', '30km+'});
X = reordercats(X,{'<1km', '1-3km', '3-5km', '5-10km', '10-20km', '20-30km', '30km+'});

figure
hold on
bar(X, Y')
title("Trip Distance in Ireland 2022")
legend("Dublin", "Nationally")
ylabel("Percentage of Trips")