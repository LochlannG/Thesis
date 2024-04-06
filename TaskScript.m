% Task Code for the collection of data regarding driver-cyclist interaction
% Written by Lochlann Gallagher

clc; clear; close all;

AssertOpenGL;

%% %%%%%%%%%%%%%%%%%%%%
%%% Pyschtoolbox setup
PsychDefaultSetup(2);
InitializeMatlabOpenGL(0, 0, 0, 0);                                                     % Initialise this with all zeros to improve performance
scrn = setupPsychTLBX();

% Defining parameters governing the length of the test
test = setupTest();

% Setup road & centreline
[road, centreline] = setupRoad();

% Defining parameters specificly to do with the cyclist
cyclist = setupCyclist(road);

% Defining parameters - towardsCar
towardsCar = setupCar(road);

% towardsCar 2 - inflow traffic
withCar = towardsCar;
withCar.x = -0.5*road.laneWidth;
withCar.potentialEnd = 10;
withCar.chanceOfEnding = 0.001;   % *100 for the chance of ending per frame

% Defining parameters - Camera
camera = setupCamera(towardsCar, road);

% Defining parameters - Noise
noise = setupNoise();

%% %%%%%%%%%%%%%%%%%%%
%%% Setting up variables for use in the loop

% loop structure to hold data about the main loop
loop = setupLoop();

% Get key names
keys = setupKeys();

%% %%%%%%%%%%%%%%%%%%%
%%% Handling pinging the EMG software
% emg = EMGtriggers;

%% %%%%%%%%%%%%%%%%%%%
%%% Main trial loop
while test.trials > 0

    %%%%%%%%%%%%%%%%%%%%%
    %%% Displays a message to the user
    textString = ['Current Trial: ' num2str(loop.currentTrial) '\nContext: ' test.context '\nPress return to continue'];
    DrawFormattedText(scrn.win, textString, 'center', 'center', scrn.whit);
    Screen('Flip', scrn.win)
    
    while true
        [~, ~, keys.messageSkip, ~] = KbCheck;
        if keys.messageSkip(keys.enter) == 1
            break;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%
    %%% Sets/resets loop variables for the new trial
    if test.discreteSpeed
        noise.yNoise = getDiscreteViewDist(noise.levels);
    else
        noise.yNoise = viewDistance(scrn.frameRate, test.lengthM, "WN", noise) + noise.minViewDistance;
    end
    
    loop.currentFrame = 1;
    loop.roadLeft = test.lengthM;
    loop.setOvertake = false;
    loop.skipPlot = false;
    loop.carVCurrent = 30/3.6;
    loop.timeStore = []; loop.bikeYStore = []; loop.carVStore = []; loop.roadStore = []; loop.carYStore =[]; loop.car2YStore =[]; loop.subjectXStore = [];

    %%%%%%%%%%%%%%%%%%%%%
    %%% Sets up trial loop variables for objects drawn to the screen
    % Sets up the cyclist variables for the trial loop
    cyclist.stimStartM = generateStarts(test.lengthM, 100, test.rateCyclist*round(test.lengthM/1000));
    cyclist.stimStartM = test.lengthM - cyclist.stimStartM;
    cyclist.n = length(cyclist.stimStartM);
    test.nCyclists = cyclist.n;
    cyclist.speed = getCyclistSpeed(14/3.6, 3/3.6, 2, test.nCyclists);
    cyclist.start = getCyclistStart(test.nCyclists);
    cyclist.y = ones(test.nCyclists, 1).*cyclist.start';
    cyclist.stimOn = false(test.nCyclists, 1);
    cyclist.stimCurrent = 1;

    % Sets up the oncoming traffic variables for the trial loop
    towardsCar.stimStartM = test.lengthM - generateStarts(test.lengthM, towardsCar.start, test.rateOncomingCar*round(test.lengthM/1000));
    towardsCar.n = length(towardsCar.stimStartM);
    test.nOncomingCars = towardsCar.n;
    towardsCar.stimCurrent = 1;
    towardsCar.y = ones(test.nOncomingCars, 1)*towardsCar.start;
    towardsCar.stimOn = false(test.nOncomingCars, 1);

    % Sets up the in flow traffic variables for the trial loop
    withCar.stimStartM = test.lengthM - generateStarts(test.lengthM, withCar.start, test.rateInFlowCar*round(test.lengthM/1000));
    withCar.n = length(towardsCar.stimStartM);
    test.nInFlowCars = withCar.n;
    withCar.stimCurrent = 1;
    withCar.y = ones(test.nInFlowCars, 1)*towardsCar.start;
    withCar.stimOn = false(test.nInFlowCars, 1);

    %%%%%%%%%%%%%%%%%%%%%
    %%% OpenGL setup
    
    Screen('BeginOpenGL', scrn.win);
    glMatrixMode(GL.MODELVIEW);
    glLoadIdentity;
    glEnable(GL.DEPTH_TEST);            % this ensures closer objects are drawn on top
    glShadeModel(GL.SMOOTH);
    glClearColor(0.5,0.5,0.5,1);        % Sets the background colour
    
    while loop.roadLeft > 0
    
        % Timing
        tic
        
        % Flags for use during loop
        loop.eventOverFlag = false;
        
        %%%%%%%%%%%%%%%%%%%%%
        %%% Camera
    
        % Handles the setup of the perspective projection for the camera
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        if test.discreteSpeed
            gluPerspective(70 , 1/scrn.ar, 0.1, noise.yNoise);
        else
            gluPerspective(70 , 1/scrn.ar, 0.1, noise.yNoise(loop.currentFrame));
        end
    
        % Handles camera positioning & fixation
        if ~loop.setOvertake
            gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            loop.subjectXStore= [loop.subjectXStore, camera.xyz(1)];    % Stores the x position of the camera
        elseif loop.setOvertake
            gluLookAt(camera.xyz(1)+towardsCar.overtakeWidth, camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            loop.subjectXStore= [loop.subjectXStore, camera.xyz(1)+towardsCar.overtakeWidth];  % Stores the x position of the camera
        end
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing road
    
        % Clear out the backbuffer
        glClear();
    
        % Draw Road
        drawOpenGLObject([0, 0, 0], road, "Square")

        % Draw Centreline
        for i = 1:length(centreline.y)
            drawOpenGLObject([0, centreline.y(i), 0], centreline, "Square")
        end
        centreline.y = centreline.y - loop.carVCurrent/scrn.frameRate;
        if centreline.y(1) <= -3
            centreline.y(1) = [];
            centreline.y = [centreline.y centreline.y(end)+6];
        end
    
        % Handling Speed
        loop.roadLeft = loop.roadLeft - loop.carVCurrent*(1/scrn.frameRate);
        loop.bikeStep = (loop.carVCurrent - cyclist.speed)/scrn.frameRate;                                  % the distance a bike will go in a frame
        loop.oncomingCarStep = (towardsCar.oncomingSpeed + loop.carVCurrent)/scrn.frameRate;
        loop.inFlowCarStep = max(loop.bikeStep);
    
        loop.carVStore = [loop.carVStore, loop.carVCurrent];
        loop.roadStore = [loop.roadStore, loop.roadLeft];
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing cyclist
        [loop, cyclist, test, loop.bikeYStore] = drawAndMoveObject(cyclist, loop, test, 1);
        %%% Drawing other in flow cars
        [loop, withCar, test, loop.car2YStore] = drawAndMoveObject(withCar, loop, test, 2);
        %%% Drawing other oncoming cars
        [loop, towardsCar, test, loop.carYStore] = drawAndMoveObject(towardsCar, loop, test, 3);
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing to Screen
    
        % Flipping to the screen
        Screen('EndOpenGL', scrn.win);
        Screen('Flip', scrn.win);
        
        %%%%%%%%%%%%%%%%%%%%%
        %%% Handling Button Presses
        % Allows speeding up and slowing down in a discrete manner
        % following an event
        if test.discreteSpeed
            if loop.eventOverFlag
                % Handles when an event has just occured
                
                % Move them in from their overtak
                loop.setOvertake = false;
                
                % Change the distance that the camera can see
                noise.yNoise = getDiscreteViewDist(noise.levels);
                
                while true
                    % Displays a message to the user
                    textString = ['Event passed, use the up and down keys to set the new speed' '\nSpeed: ' num2str(loop.carVCurrent*3.6) '\nPress return to continue'];
                    DrawFormattedText(scrn.win, textString, 'center', 'center', scrn.whit);
                    Screen('Flip', scrn.win)
                    
                    % Handles Button Presses
                    loop = getKeyMakeChange(loop, keys, test, towardsCar, scrn, [0, 1, 1, 1, 0, 0]);
                    if loop.breakFlag == true
                        break;
                    end 
                end
            else
                % Handles when an event has not occured
                
                % Handles Button Presses
                loop = getKeyMakeChange(loop, keys, test, towardsCar, scrn, [1, 0, 0, 1, 1, 1]);
                if loop.breakFlag == true
                    break;
                end 
            end
        else
            % Handles Button Presses
            loop = getKeyMakeChange(loop, keys, test, towardsCar, scrn, [1, 1, 1, 1, 1, 1]);
            if loop.breakFlag == true
                break;
            end 
        end
        
        Screen('BeginOpenGL', scrn.win);
    
        % Inform the debug user
        if test.debug == 1
            disp("Current Frame     = " + loop.currentFrame)                                             % Useful for keeping track
        end    

        %%%%%%%%%%%%%%%%%%%%%
        %%% Handling Loop Processes
    
        % Update loop values
        loop.currentFrame = loop.currentFrame + 1;
    
        % Update the time tracking values
        loop.timeStore = [loop.timeStore toc];
    
    end

    % records the values stored into a cell structure
    loop.time{loop.currentTrial} = loop.timeStore;
    loop.bikeY{loop.currentTrial} = loop.bikeYStore;
    loop.carV{loop.currentTrial} = loop.carVStore;
    loop.road{loop.currentTrial} = loop.roadStore;
    loop.carY{loop.currentTrial} = loop.carYStore;
    loop.car2Y{loop.currentTrial} = loop.car2YStore;
    loop.subjectX{loop.currentTrial} = loop.subjectXStore;

    % updates the loop value
    if ~loop.escapeFlag
        Screen('EndOpenGL', scrn.win);
        test.trials = test.trials - 1;
        loop.currentTrial = loop.currentTrial + 1;
    else
        test.trials = 0;
    end
end

% Close open screen
Screen('CloseAll');
%%
%%%%%%%%%%%%%%%%%%%%%
%%% Plotting Summary Results
close all;
if ~loop.skipPlot
    averageFrameRate = plotTrialSummary(loop.time{1}, loop.bikeY{1}, loop.carV{1}, noise.yNoise);
end

results.gravityCollisions = [0.15, 0.7, 0.8];           % order of R, G, B -> towardsCar, Cyclist, withCar
[results.bikeDist, results.carDist, results.car2Dist] = plotGravityScoring(loop, towardsCar, cyclist, withCar, results.gravityCollisions);
