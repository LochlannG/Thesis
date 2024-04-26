% results stuff
clc; close all
figure
t = tiledlayout(ceil(results.nTrials/3), 3);

results.givenFrameRT = 60;

overtakeLasts = results.givenFrameRT*3; % length of an overtake, ignore all extra presses before that

if length(results.buttonsPressed{2}) > length(results.time{2})
    % Need to truncate them
    lengths = zeros(1, results.nTrials);

    buttons{1} = results.buttonsPressed{1};
    lengths(1) = length(buttons{1});
    for i = 2:results.nTrials
        lengths(i) = length(results.buttonsPressed{i});
        buttons{i} = results.buttonsPressed{i}(:, lengths(i-1):lengths(i));
    end
else
   buttons = results.buttonsPressed; 
end

for i = 1:results.nTrials
    
    overtakePressed = buttons{i}(6, :);
    [overtakePressed2, ~] = envelope(overtakePressed, overtakeLasts);
    
    
    % Calculations
    frameVector     = 1:length(results.time{i});
    
    bike = results.bikeY{i};
    car  = results.withCarY{i};
    view = results.cameraView{i};
    
    % Under the assumption that the bike vector will always be the same
    % length I only need this
    lengthDiff = length(view) - length(bike);
    
    
    if lengthDiff == 1
        % view is smaller
        disp("view shorter")
        view = view(:, 1:end-1);
        frameVectorShort = frameVector(1:end-1);
    elseif lengthDiff == -1
        % bike is smaller
        disp("bike shorter")
        bike = bike(:, 1:end-1);
        car  = car(:, 1:end - 1);
        frameVectorShort = frameVector(1:end-1);
    elseif lengthDiff == 0
       % No difference between vector lengths
       % do nothing
       disp("they be the same length")
       frameVectorShort = frameVector;
    else
        disp('Something has gone very wrong, vector lengths are different')
        frameVectorShort = frameVector;
    end
    
    seenCar{i}          = and(car <= view, car >= 0);
    anyCar{i}           = any(seenCar{i});
    carStartFrames{i}   = diff(anyCar{i}) > 0;
    carEndFrames{i}     = diff(anyCar{i}) < 0;
    
    seenBike{i}         = and(bike <= view, bike >= 0);
    anyBike{i}          = any(seenBike{i});
    bikeStartFrames{i}  = diff(anyBike{i}) > 0;
    bikeEndFrames{i}    = diff(anyBike{i}) < 0;
    
    % Counting the view distances when the bikes are visible
    

    % Plotting
    nexttile
    hold on
    plot(frameVector, results.bikeY{i}', 'color', 'g')
    plot(frameVector, results.withCarY{i}', 'color', 'b')
    plot(frameVector(1:end-1), results.cameraView{i}(frameVector(1:end-1)), '--', 'color', '#808080');
    plot(frameVectorShort, seenBike{i}-1, 'g', 'linewidth', 3)
    plot(frameVectorShort, seenCar{i}-1, 'b', 'linewidth', 3)
    xlim([0 length(frameVector)])
    ylim([0, round(max(max(results.cameraView{i}(frameVector(1:end-1)))))])
    title(['Trial # ', num2str(i)])
    hold off
end


title(t, "Position Summary")
xlabel(t, "Frame")
ylabel(t, "Distance (m)")
%%
% Reaction time plotting
figure
clc
% close all
clear indexesVisible
indexesRecorded = [];

for i = 1:results.nTrials
    currentBikes = seenBike{i};
    nBikes(i) = height(currentBikes);
    
    % Loop through all the bikes in the trial
    for j = 1:nBikes(i)
        
        % Find when the objects are visible
        try
            indexesVisible(2) = find(currentBikes(j, :), 1, 'first');
            indexesVisible(3) = find(currentBikes(j, :), 1, 'last');
        catch
            disp(["Trial # " num2str(i) " Stimulus # " num2str(j) " empty"])
            indexesVisible(2:3) = nan(1, 2);
        end
        
        indexesVisible(1) = i;
        
        % Append to variables
        indexesRecorded = [indexesRecorded; indexesVisible];
        
    end
    
end

% partialViewDist = []
% for i = 1:length(indexesRecorded)
%    currentTrial = indexesRecorded(i, 1);
%    startIndex = indexesRecorded(i, 2);
%    endIndex = indexesRecorded(i, 3);
%    
%    if isnan(startIndex)
%        % Do nothing
%    else
%        partialViewDist = [partialViewDist; unique(results.cameraView{currentTrial}(startIndex:endIndex))];
%    end
% end

%%

% Bike on/off
figure;
hold on
plot(diff(anyBike{i}), 'r')
plot(anyBike{i}, 'g')
plot(diff(anyCar{i}), 'r')
plot(anyCar{i}, 'b')

% Overtake presses & Speed
figure;
hold on
plot(overtakePressed)
plot(results.cameraV{i})

% View Distances
countViewDistances(results)

function countViewDistances(results)
    figure
    t = tiledlayout(ceil(results.nTrials/3), 3);
    title(t, "Position Summary")
    xlabel(t, "Frame")

    for i = 1:results.nTrials
        nexttile
        view = results.cameraView{i};
        plot(diff(view))
        title(['Trial # ', num2str(i)])
        
    end

end
