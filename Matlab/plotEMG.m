clc; clear; close all

% convert to mat
path = "C:/Users/lochl/Documents/Local Working Directories/Thesis Working Directory/EMG Data/all/";
files = ["206", "208", "210", "213", "214", "215", "216" "217", "218", "219"]+".csv";
for i = 1:length(files)
    convertToMat(path, files(i));
end

%%
[EMGdata, len, sampFreq] = oldLoadEMG("C:/Users/lochl/Documents/Local Working Directories/Thesis Working Directory/EMG Data/proofOfPrinciple/", "Run_number_204_Signal_Preview_Rep_1.8.mat");
oldplotEMG(EMGdata, sampFreq, len);
proofOfPrinciple(EMGdata, sampFreq);
%%
close all
path1 =  "C:/Users/lochl/Documents/Local Working Directories/Thesis Working Directory/EMG Data/matFiles/";
filenames1 = ["208", "213", "215", "217", "219"]+".mat";
subjnames = ["b", "c", "d", "e", "f"];

for i = 1:length(filenames1)
    EMGdata = newLoadEmg(path1, filenames1(i));
    time = EMGdata(:, 1);
    
    clc;
    figure;
    t = tiledlayout(3, 1);
    nexttile(t)
    plot(time', EMGdata(:, 2)')
    title("Left Hand EMG")
    xlabel("Time (s)")
    ylabel("Amplitude (mV)")
    ylim([-4 4])
    xlim([0 2500])
    
    nexttile(t)
    plot(time', EMGdata(:, 3)')
    title("Right Hand EMG")
    xlabel("Time (s)")
    ylabel("Amplitude (mV)")
    ylim([-4 4])
    xlim([0 2500])
    
    nexttile(t)
    plot(time', EMGdata(:, 4)')
    title("Binary Output to Port 4FF8")
    xlabel("Time (s)")
    ylabel("Amplitude (mV)")
    ylim([-4 1])
    xlim([0 2500])

    title(t, "Subject: "+subjnames(i))
end
%%
close all; clc
path1 =  "C:/Users/lochl/Documents/Local Working Directories/Thesis Working Directory/EMG Data/matFiles/";
filenames1 = ["208", "213", "215", "217", "219"]+".mat";
subjnames = ["b", "c", "d", "e", "f"];
path2 = "C:/Users/lochl/Documents/Local Working Directories/Thesis Working Directory/Matlab/results/";
filenames2 = ["b_2.mat", "c_1.mat", "d_1.mat", "e_1.mat", "f_1.mat"];

% for subjectI = 1:length(filenames1)
% 
%     pullOut{subjectI} = getBlips(EMGdata, behaviouralData);
% 
% end


filenames3 = ["206", "208", "210", "213", "214", "215", "216", "217", "218", "219"]+".mat";

for fileI = 1:length(filenames3)

    EMGdata = load(path1+filenames3(fileI));
    EMGdata = EMGdata.matrixImport;
    pullOut{fileI} = getBlips(EMGdata);
    

    figure
    t = tiledlayout(6, 1);
    title(t, ["Data Taken From: "+filenames3(fileI), "Compared to the Behaviour Data From All Trials"])
    nexttile(t)
    hold on
    position = pullOut{fileI}(:, 3);
    type = pullOut{fileI}(:, 6);
    xline(position(type==1), 'Color', "#77AC30")
    xline(position(type==2), 'Color', "#A2142F")
    xlim([0, 2500])
    
    for subjectI = 1:length(filenames2)

        behaviouralData = load(path2+filenames2(subjectI));
        behaviouralData = behaviouralData.results;

        % Pull all the buttons out
        behaviourButtons = [];
        behaviourTime = [];
        for j = 1:behaviouralData.nTrials
            behaviourTime = [behaviourTime, behaviouralData.time{j}];
            behaviourButtons = [behaviourButtons, behaviouralData.buttonsPressed{j}([4, 6], :)];
        end

        finalTime = pullOut{subjectI}(end, 3);
        cumulativeTime = cumsum(behaviourTime(1:end-1));
        lengthofBehaviourTrials(subjectI) = cumulativeTime(end);
%         differenceTime = finalTime - cumulativeTime(end);
        nexttile(t)
        plot(cumulativeTime, behaviourButtons','Color', "#D95319")
        xlim([0, 2500])
        title(subjnames(subjectI))
%         plot(cumulativeTime+differenceTime, behaviourButtons','Color', "#77AC30")

        

    end


end

disp("Behaviour Trial Lengths in Seconds:")
disp(lengthofBehaviourTrials)

function returnArray = getBlips(EMGdata)

    % This section needs to pull & concat the button presses
%     behaviourButtons = [];
%     behaviourTime = [];
%     for i = 1:behaviouralData.nTrials
%         behaviourTime = [behaviourTime, behaviouralData.time{i}];
%         behaviourButtons = [behaviourButtons, behaviouralData.buttonsPressed{i}([4, 6], :)];
%     end

    % This section handles pulling the blips from the 
    sampleVector = 1:length(EMGdata(:, 1));
    samplerate = 1/mean(diff(EMGdata(sampleVector, 1)), 1, 'omitnan'); % hz
    logical = (EMGdata(sampleVector, 4) < -0.2);
    differential = diff(logical);
    startIndexes = differential>0;
    endIndexes = differential<0;
    strt = find(startIndexes);
    fin  = find(endIndexes);
    indexes = []; position = []; distance = []; type = [];
    for i = 1:length(strt)
        % This assumes a start index always before an end index
        indexes = [indexes; strt(i), fin(i)];
        position = [position; EMGdata(strt(i), 1), EMGdata(fin(i), 1)];
        distance(i) = sampleVector(fin(i))- sampleVector(strt(i));
        if and(distance(i) >= 100, distance(i) <= 250)
            type(i) = 2;
        elseif and(distance(i) >= 26,  distance(i) <= 29)
            type(i) = 1;
        else
            type(i) = nan(1, 1);
        end
    end
    
    
    
    % Start Index, Finish Index, Start Sample, Finish Sample, Distance
    % Between Start/Finish Sample, Type of Blip (1 = Regular Decision, 2 =
    % Trial Start)
    returnArray = [];
    returnArray = [indexes, position, distance', type'];
    
%     figure
%     tiledlayout(3, 1)
%     nexttile
%     hold on
%     plot(EMGdata(sampleVector, 1), EMGdata(sampleVector, 2))
%     plot(EMGdata(sampleVector, 1), EMGdata(sampleVector, 3)+2)
% 
%     nexttile
%     hold on
%     xline(position(type==1), 'Color', "#77AC30")
%     xline(position(type==2), 'Color', "#A2142F")
%     hold off
    
    % Plot the button presses too
%     nexttile
%     hold on
%     finalTime = returnArray(end, 3);
%     cumulativeTime = cumsum(behaviourTime(1:end-1));
%     differenceTime = finalTime - cumulativeTime(end);

%     plot(cumulativeTime+differenceTime, behaviourButtons','Color', "#77AC30")

    % Reports the length of the vectors
    disp("Length of Vector in Seconds: "+num2str(EMGdata(end, 1))+" in Samples: "+num2str(sampleVector(end)))


end


function data = newLoadEmg(path, file)
    fullName = path+file;
    data = load(fullName);
    data = data.matrixImport;
end

function matrixImport = convertToMat(path, file)

    
    matrixImport = readmatrix(path+file);
    if size(matrixImport, 2)  > 18
        fields = [1, 2, 16, 30];
    elseif size(matrixImport, 2) > 6 && size(matrixImport, 2) <= 18
        fields = [1, 2, 16, 18];
    elseif size(matrixImport, 2) <= 6
        fields = [1, 2, 4, 6];
    end
    matrixImport = matrixImport(:, fields);
    matrixImport(:, 2:3) = matrixImport(:, 2:3)*1000;

    matrixImport = matrixImport(~isnan(matrixImport(:, 1)), :);
    newPath = "C:/Users/lochl/Documents/Local Working Directories/Thesis Working Directory/EMG Data/matFiles/";
    newName = erase(file, '.csv');
    save(newPath+newName+".mat", "matrixImport", '-mat')
end

function [data, len, sampFreq] = oldLoadEMG(path, file)
    fullName = path+file;
    data = load(fullName);
    
    sampFreq = data.Fs(1);
    display("Average Sampling Frequency: " + num2str(sampFreq))
    len = length(data.Data);
end

function oldplotEMG(data, sampFreq, len)
    figure
    tiledlayout(2, 1)
    nexttile
    plot(data.Time', data.Data');
    title("EMG plot")
    xlabel("Time (secs)")
    ylabel("Amplitude (mV)")
    
    nexttile
    fEMG = fft(data.Data(1, :), len);
    F1 = sampFreq*((0:len-1)/len);
    plot(F1, abs(fEMG));
    title("Frequency Spectrum of EMG")
    xlabel("Frequency (Hz)");
    ylabel("Amplitude")
    xlim([0, max(F1)/2])

end

function proofOfPrinciple(data, sampFreq)

    figure
    t = tiledlayout(2, 2);
    title(t, "Proof of Principle Plots - EMG Integration Method")
    nexttile(t, [1, 2])
    snipIdx1 = find(data.Time(1, :)>12, 1, 'first'):find(data.Time(1, :)>15, 1, 'first');
    snipIdx2 = find(data.Time(1, :)>8, 1, 'first'):find(data.Time(1, :)>10, 1, 'first');
    
    snippedTime1 = data.Time(1, snipIdx1);
    snippedData1 = data.Data(1, snipIdx1)*1000;
    len1 = length(snippedData1);
    
    snippedTime2 = data.Time(1, snipIdx2);
    snippedData2 = data.Data(1, snipIdx2)*1000;
    len2 = length(snippedData2);
    
    time1 = (0:1:length(snippedTime1)-1)*1/sampFreq;
    time2 = (0:1:length(snippedTime2)-1)*1/sampFreq;
    
    hold on
    plot(time1, snippedData1 + 2)
    plot(time2, snippedData2 + 1)
    legend("Contraction", "No Contraction")
    title("EMG plot")
    xlabel("Time (secs)")
    ylabel("Amplitude (mV)")
    
    nexttile(t)
    hold on
    fEMG1 = fft(snippedData1, len1);
    fEMG2 = fft(snippedData2, len2);
    
    F1 = sampFreq*((0:len1-1)/len1);
    F2 = sampFreq*((0:len2-1)/len2);
    plot(F1, abs(fEMG1));
    plot(F2, abs(fEMG2));
    
    xArrowPos = 10; yArrowPos = 35;
    xline(xArrowPos, 'Color', "#EDB120", 'LineWidth', 2)
    anArrow = annotation('arrow', 'Color', "#EDB120", 'LineWidth', 2) ;
    anArrow.Parent = gca;
    anArrow.Position = [xArrowPos, yArrowPos, 120, 0] ;
    
    title("Frequency Spectrum of EMG")
    legend("Contraction", "No Contraction")
    xlabel("Frequency (Hz)");
    ylabel("Amplitude (mV)")
    xlim([0, max(F1)/2])
    
    % Integral [just going to do a cube]
    % Everything past 10hz
    nexttile(t)
    hold on
    F1AboveThres = F1(find(F1>10, 1, "first"):end);
    area1 = (F1AboveThres(end)-F1AboveThres(1))*mean(abs(fEMG1(find(F1>10, 1, "first"):end)));
    
    F2AboveThres = F2(find(F2>10, 1, "first"):end);
    area2 = (F2AboveThres(end)-F2AboveThres(1))*mean(abs(fEMG2(find(F2>10, 1, "first"):end)));
    
    barNames = categorical(["Contraction", "No Contraction"]);
    b = bar([area1, area2]);
    b.FaceColor = 'flat';
    b.CData(2, :) = [0.8500 0.3250 0.0980];
    set(gca, 'XTick', [1, 2])
    set(gca, 'XTickLabel', barNames)
    xtickangle(gca, 45)
    ylabel("Integrated Area (mV/s)")
end