function [bikeTableOut, carTableOut] = binTrials(folder, filenames, plotOutputs)
    close all

    carTableOut = struct(); carTableOut.total = [];
    bikeTableOut = struct(); bikeTableOut.total = [];
    subjectNames = erase(filenames, ".mat");

    nSubjects = length(filenames);

    % Output status to user
    disp("nSubjects = " + num2str(nSubjects))
    disp("Loop beginning")


    %% This section loops through the results object and pulls out the relevent details
    if plotOutputs(1)
        t = tiledlayout(nSubjects, 10);
    end

    for subjectI = 1:nSubjects
        disp("Loading file " + filenames(subjectI))
        load(folder + "/" + filenames(subjectI));

        % Pulls out the button presses that got concatted incorrectly in
        % the first set of trials. If the number of samples is shorter than
        % the number of samples in the buttons vector then it snips it
        if length(results.buttonsPressed{2}) > length(results.time{2})
            % Need to truncate them
            lengths = zeros(1, results.nTrials);
            buttons{1} = results.buttonsPressed{1};
            lengths(1) = length(buttons{1});
            for trialI = 2:results.nTrials
                lengths(trialI) = length(results.buttonsPressed{trialI});
                buttons{trialI} = results.buttonsPressed{trialI}(:, lengths(trialI-1):lengths(trialI));
            end
        else
           buttons = results.buttonsPressed; 
        end

        % Run through all the trials and find the bikes and cars
        for trialI = 1:results.nTrials
    
            % Calculations
            frameVector     = 1:length(results.time{trialI});
            
            % Assign variables
            bike = results.bikeY{trialI};
            car  = results.withCarY{trialI};
            view = results.cameraView{trialI};
            
            % Under the assumption that the bike vector will always be the same
            % length I only need this
            lengthDiff = length(view) - length(bike);
            
            
            if lengthDiff == 1
                % view is smaller
                view = view(:, 1:end-1);
                frameVectorShort = frameVector(1:end-1);
            elseif lengthDiff == -1
                % bike is smaller
                bike = bike(:, 1:end-1);
                car  = car(:, 1:end - 1);
                frameVectorShort = frameVector(1:end-1);
            elseif lengthDiff == 0
               % No difference between vector lengths
               % do nothing
               frameVectorShort = frameVector;
            else
                disp('Something has gone very wrong, vector lengths are different')
                frameVectorShort = frameVector;
            end
            
            seenCar{trialI}          = and(car <= view, car >= 0);
            anyCar{trialI}           = any(seenCar{trialI});
            carStartFrames{trialI}   = diff(anyCar{trialI}) > 0;
            carEndFrames{trialI}     = diff(anyCar{trialI}) < 0;
            
            seenBike{trialI}         = and(bike <= view, bike >= 0);
            anyBike{trialI}          = any(seenBike{trialI});
            bikeStartFrames{trialI}  = diff(anyBike{trialI}) > 0;
            bikeEndFrames{trialI}    = diff(anyBike{trialI}) < 0;
            
            if plotOutputs(1)
                % Plotting
                nexttile
                hold on
                plot(frameVector, results.bikeY{trialI}', 'color', 'g')
                plot(frameVector, results.withCarY{trialI}', 'color', 'b')
                plot(frameVector(1:end-1), results.cameraView{trialI}(frameVector(1:end-1)), '--', 'color', '#808080');
                plot(frameVectorShort, seenBike{trialI}-1, 'g', 'linewidth', 3)
                plot(frameVectorShort, seenCar{trialI}-1, 'b', 'linewidth', 3)
                xlim([0 length(frameVector)])
                ylim([0, round(max(max(results.cameraView{trialI}(frameVector(1:end-1)))))])
                title(['Trial # ', num2str(trialI)])
                hold off
            end

        end

        if plotOutputs(1)
            title(t, "Position Summary")
            xlabel(t, "Frame")
            ylabel(t, "Distance (m)")
        end


        %% This Section records all the details specifically for cyclists
        indexesRecorded = [];
        for trialI = 1:results.nTrials
            currentBikes = seenBike{trialI};
            nBikes(trialI) = height(currentBikes);
            
            % Loop through all the bikes in the trial
            for objectI = 1:nBikes(trialI)
                
                % Find when the objects are visible
                try
                    indexesVisible(2) = find(currentBikes(objectI, :), 1, 'first');
                    indexesVisible(3) = find(currentBikes(objectI, :), 1, 'last');
                catch
                    disp("Trial # " + num2str(trialI) + " Stimulus # " + num2str(objectI) + " empty")
                    indexesVisible(2:3) = nan(1, 2);
                end
                
                indexesVisible(1) = trialI;
                
                % Append to variables
                indexesRecorded = [indexesRecorded; indexesVisible];
                
            end
            
        end
        
        partialViewDist = [];
        partialButtons  = [];
        partialGap      = [];
        for trialI = 1:length(indexesRecorded)
            currentTrial = indexesRecorded(trialI, 1);
            startIndex = indexesRecorded(trialI, 2);
            endIndex = indexesRecorded(trialI, 3);
            
            if isnan(startIndex)
               % Do nothing
               appendButton     = nan(1, 2);
               appendViewDist   = nan(1, 1);
            else
                cameraSnippet = results.cameraView{currentTrial}(startIndex:endIndex);
                appendViewDist = mode(cameraSnippet);
                gapSnippet = results.gap{currentTrial}(:, startIndex:endIndex);
                buttonSnippet = buttons{currentTrial}([3, 4, 6], startIndex:endIndex);
            
                firstBT = nan(3, 1);
                for objectI = 1:3
                    notFound = true;
                    buttonToAppend = find(buttonSnippet(objectI, :));
                    counter = 1;
                    while notFound
                        try
                            if buttonToAppend(counter) < 0.2*60
                                counter = counter+1;
                            else
                                buttonToAppend  = buttonToAppend(counter);
                                notFound        = false;
                            end
                        catch
                            % Just move on
                            buttonToAppend = nan(1, 1);
                            notFound = false;
                        end
                    end

                    % Catches errors
                    if isempty(buttonToAppend)
                        buttonToAppend = nan(1, 1);
                    end
                    firstBT(objectI)  = buttonToAppend;
                
                end
                
                % This finds out which one was first and pulls its frame and row
                % The buttons are 3 - up, 4 - down, 6 - right
                % This are converted into 1, 2, 3 in the same order
                [appendButton(1), appendButton(2)] = min(firstBT);
            
                % Catch errors
                if isnan(appendButton(1))
                    appendButton(2) = nan(1, 1);
                    appendGap = nan(1, 2);
                else
                    appendGap = gapSnippet(:, appendButton(1))';
                end
            
                
            end
    
            partialViewDist = [partialViewDist; appendViewDist];
            partialButtons  = [partialButtons;  appendButton];
            partialGap      = [partialGap;      appendGap];
            clear appendButton;
        end

        if plotOutputs(2)
            figure
            t = tiledlayout(2, 1);
            nexttile
            histogram(partialButtons(:, 1))
            nexttile
            title("Button Pressed")
            histogram(partialButtons(any(partialButtons(:, 2)==[2, 3], 2), 2))

            % Overall Decoration
            title(t, ("Subject" + num2str(subjectI)))
            
        end
        
        
        % I want to plot them relative to the speed plots to see why the buttons were used so often
        tableArray          = [indexesRecorded, indexesRecorded(:, 3)-indexesRecorded(:, 2), partialViewDist, partialButtons, partialGap];
        varNames            = {'Subject', 'Bike Or Car', 'Trial', 'Start Index', 'End Index', 'Index Length', 'View Distance', 'Frame Pressed', 'Button Pressed', 'Actual Gap', 'Percieved Gap'};
        subjectArray        = ones(length(indexesRecorded), 1)*subjectI;
        bikeOrCar           = ones(length(indexesRecorded), 1)*1;
        fullTable           = table(subjectArray, bikeOrCar, tableArray(:, 1),tableArray(:, 2),tableArray(:, 3),tableArray(:, 4),tableArray(:, 5),tableArray(:, 6),tableArray(:, 7),tableArray(:, 8),tableArray(:, 9), 'VariableNames', varNames);
        bikeTableOut.total   = [bikeTableOut.total; fullTable];
        bikeTableOut.(subjectNames(subjectI)) = fullTable;

        if plotOutputs(3)
            % This will plot each trial with the button presses as vertical lines
            colour = ['r', 'g', 'b']; % up, down, right
            for trialI = 1:results.nTrials
                figure
                hold on
                plot(results.cameraV{trialI})
                title(["Trial #: " + num2str(subjectI) + "." + num2str(trialI)])
            
                currentTrialTable = fullTable(fullTable.("Trial")==trialI, :);
                for objectI = 1:height(currentTrialTable)
                    disp("Plotting subject.trial.object: " + num2str(subjectI) + "." + num2str(trialI) + "." + num2str(objectI))
                    if and(~isnan(currentTrialTable.("Button Pressed")(objectI)), ~isempty(currentTrialTable.("Button Pressed")(objectI)))
                        xline(currentTrialTable.("Start Index")(objectI), 'color', colour(currentTrialTable.("Button Pressed")(objectI)))
                    else
                        disp("Caught the nan value at subject.trial.object: " + num2str(subjectI) + "." + num2str(trialI) + "." + num2str(objectI))
                    end
                end
            end
        end


        %% This Section records all the details specifically for cars
        indexesRecorded = [];
        for trialI = 1:results.nTrials
            currentCars = seenCar{trialI};
            nCars(trialI) = height(currentCars);
            
            % Loop through all the bikes in the trial
            for objectI = 1:nCars(trialI)
                
                % Find when the objects are visible
                try
                    indexesVisible(2) = find(currentCars(objectI, :), 1, 'first');
                    indexesVisible(3) = find(currentCars(objectI, :), 1, 'last');
                catch
                    disp("Trial # " + num2str(trialI) + " Stimulus # " + num2str(objectI) + " empty")
                    indexesVisible(2:3) = nan(1, 2);
                end
                
                indexesVisible(1) = trialI;
                
                % Append to variables
                indexesRecorded = [indexesRecorded; indexesVisible];
                
            end
            
        end
        
        partialViewDist = [];
        partialButtons  = [];
        partialGap      = [];
        for trialI = 1:length(indexesRecorded)
            currentTrial = indexesRecorded(trialI, 1);
            startIndex = indexesRecorded(trialI, 2);
            endIndex = indexesRecorded(trialI, 3);
            
            if isnan(startIndex)
               % Do nothing
               appendButton     = nan(1, 2);
               appendViewDist   = nan(1, 1);
            else


                cameraSnippet = results.cameraView{currentTrial}(startIndex:endIndex);
                appendViewDist = mode(cameraSnippet);
                gapSnippet = results.gap{currentTrial}(:, startIndex:endIndex);
                buttonSnippet = buttons{currentTrial}([3, 4, 6], startIndex:endIndex);
            

                firstBT = nan(3, 1);
                for objectI = 1:3
                    notFound = true;
                    buttonToAppend = find(buttonSnippet(objectI, :));
                    counter = 1;

                    while notFound
                        try
                            if buttonToAppend(counter) < 0.2*60
                                counter = counter+1;
                            else
                                buttonToAppend  = buttonToAppend(counter);
                                notFound        = false;
                            end
                        catch
                            % Just move on
                            buttonToAppend = nan(1, 1);
                            notFound = false;
                        end
                    end

                    % Catches errors
                    if isempty(buttonToAppend)
                        buttonToAppend = nan(1, 1);
                    end
                    firstBT(objectI)  = buttonToAppend;
                
                end
                
                % This finds out which one was first and pulls its frame and row
                % The buttons are 3 - up, 4 - down, 6 - right
                % This are converted into 1, 2, 3 in the same order
                [appendButton(1), appendButton(2)] = min(firstBT);
                
                % Catch errors
                if isnan(appendButton(1))
                    appendButton(2) = nan(1, 1);
                    appendGap = nan(1, 2);
                else
                    appendGap = gapSnippet(:, appendButton(1))';
                end
            
                
            end
    
            partialViewDist = [partialViewDist; appendViewDist];
            partialButtons  = [partialButtons;  appendButton];
            partialGap      = [partialGap;      appendGap];
            clear appendButton;
        end

        if plotOutputs(2)
            figure
            t = tiledlayout(2, 1);
            nexttile
            histogram(partialButtons(:, 1))
            nexttile
            title("Button Pressed")
            histogram(partialButtons(any(partialButtons(:, 2)==[2, 3], 2), 2))

            % Overall Decoration
            title(t, ("Subject" + num2str(subjectI)))
            
        end
        
        
        % I want to plot them relative to the speed plots to see why the buttons were used so often
        tableArray          = [indexesRecorded, indexesRecorded(:, 3)-indexesRecorded(:, 2), partialViewDist, partialButtons, partialGap];
        varNames            = {'Subject', 'Bike Or Car', 'Trial', 'Start Index', 'End Index', 'Index Length', 'View Distance', 'Frame Pressed', 'Button Pressed', 'Actual Gap', 'Percieved Gap'};
        subjectArray        = ones(length(indexesRecorded), 1)*subjectI;
        bikeOrCar           = ones(length(indexesRecorded), 1)*2;
        fullTable           = table(subjectArray, bikeOrCar, tableArray(:, 1),tableArray(:, 2),tableArray(:, 3),tableArray(:, 4),tableArray(:, 5),tableArray(:, 6),tableArray(:, 7),tableArray(:, 8),tableArray(:, 9), 'VariableNames', varNames);
        carTableOut.total   = [carTableOut.total; fullTable];
        carTableOut.(subjectNames(subjectI)) = fullTable;

        if plotOutputs(3)
            % This will plot each trial with the button presses as vertical lines
            colour = ['r', 'g', 'b']; % up, down, right
            for trialI = 1:results.nTrials
                figure
                hold on
                plot(results.cameraV{trialI})
                title(["Trial #: " + num2str(subjectI) + "." + num2str(trialI)])
            
                currentTrialTable = fullTable(fullTable.("Trial")==trialI, :);
                for objectI = 1:height(currentTrialTable)
                    disp("Plotting subject.trial.object: " + num2str(subjectI) + "." + num2str(trialI) + "." + num2str(objectI))
                    if and(~isnan(currentTrialTable.("Button Pressed")(objectI)), ~isempty(currentTrialTable.("Button Pressed")(objectI)))
                        xline(currentTrialTable.("Start Index")(objectI), 'color', colour(currentTrialTable.("Button Pressed")(objectI)))
                    else
                        disp("Caught the nan value at subject.trial.object: " + num2str(subjectI) + "." + num2str(trialI) + "." + num2str(objectI))
                    end
                end
            end
        end


    end

end