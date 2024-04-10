% Task Code for the collection of data regarding driver-cyclist interaction
% Written by Lochlann Gallagher

clc; clear; close all;

AssertOpenGL;

%% %%%%%%%%%%%%%%%%%%%%
%%% Pyschtoolbox setup
PsychDefaultSetup(2);
InitializeMatlabOpenGL(0, 0, 0, 0);                 % Initialise this with all zeros to improve performance
scrn = setupPsychTLBX();                            % Call psychtoolbox setup function

%% %%%%%%%%%%%%%%%%%%%%
%%% Defining Parameters

% Call setup functions
test                        = setupTest();              % Defining parameters governing the length of the test
[road, verge, centreline]   = setupRoad();              % Setup road & centreline
cyclist                     = setupCyclist(road);       % Defining parameters specificly to do with the cyclist

% The car objects are clones of each other with slightly different variables
towardsCar = setupCar(road);
withCar                     = towardsCar;               % Clone setupCar object
withCar.x                   = -0.5*road.laneWidth;      % Move it middle of the to the other lane
withCar.potentialEnd        = 10;                       % The distance from the camera where the object can disappear
withCar.chanceOfEnding      = 1;                    	% Chance of ending per frame

% Calling remaining setup function
camera  = setupCamera(towardsCar, road);                % Defining parameters - Camera
noise   = setupNoise();                                 % Defining parameters - Noise
loop    = setupLoop();                                  % Defining parameters - Loop
keys    = setupKeys();                                  % Defining parameters - Loop

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
    
    % Variables that need to be reset for each new trial
    loop.currentFrame       = 1;
    loop.roadLeft           = test.lengthM;
    loop.setOvertake        = false;
    loop.skipPlot           = false;
    loop.cameraVCurrent     = camera.startSpeed;
    loop.eventOverTimer     = -1;
    loop.whichTypeStore     = [];
    loop.whichInstanceStore = [];
    loop.gapStore           = [];
    loop.timeStore          = [];
    loop.bikeYStore         = [];
    loop.cameraVStore       = [];
    loop.roadStore          = [];
    loop.towardsCarYStore   = [];
    loop.withCarYStore      = [];
    loop.cameraXStore       = [];

    %%%%%%%%%%%%%%%%%%%%%
    %%% Sets up trial loop variables for objects drawn to the screen
    % Sets up the cyclist variables for the trial loop
    cyclist.stimStartM      = test.lengthM - getStarts(test.lengthM, 100, test.rateCyclist);
    cyclist.n               = length(cyclist.stimStartM);
    test.nCyclists          = cyclist.n;
    cyclist.speed           = getCyclistSpeed(14/3.6, 3/3.6, 2, test.nCyclists);
    cyclist.start           = getCyclistStart(test.nCyclists);
    cyclist.y               = ones(test.nCyclists, 1).*cyclist.start';
    cyclist.stimOn          = false(test.nCyclists, 1);
    cyclist.stimCurrent     = 1;

    % Sets up the oncoming traffic variables for the trial loop
    towardsCar.stimStartM   = test.lengthM - getStarts(test.lengthM, towardsCar.start, test.rateOncomingCar);
    towardsCar.n            = length(towardsCar.stimStartM);
    test.nOncomingCars      = towardsCar.n;
    towardsCar.stimCurrent  = 1;
    towardsCar.y            = ones(test.nOncomingCars, 1)*towardsCar.start;
    towardsCar.stimOn       = false(test.nOncomingCars, 1);

    % Sets up the in flow traffic variables for the trial loop
    withCar.stimStartM      = test.lengthM - getStarts(test.lengthM, withCar.start, test.rateInFlowCar);
    withCar.n               = length(towardsCar.stimStartM);
    test.nInFlowCars        = withCar.n;
    withCar.stimCurrent     = 1;
    withCar.y               = ones(test.nInFlowCars, 1)*towardsCar.start;
    withCar.stimOn          = false(test.nInFlowCars, 1);

    %%%%%%%%%%%%%%%%%%%%%
    %%% Letting the user set their speed at the start
    [loop, noise] = getPostEventResponse(loop, noise, scrn, cyclist, road, verge, centreline, keys, test, camera, "first");

    %%%%%%%%%%%%%%%%%%%%%
    %%% OpenGL setup
    
    Screen('BeginOpenGL', scrn.win);        % This is required at the start of every OpenGL frame
    glMatrixMode(GL.MODELVIEW);             % Setup up which mode OpenGL will draw within
    glLoadIdentity;
    glEnable(GL.DEPTH_TEST);                % This ensures closer objects are drawn on top
    glShadeModel(GL.SMOOTH);
    glClearColor(0.5,0.5,0.5,1);            % Sets the background colour
    
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
        % gluLookAt() is the function responsible for camera positioning in OpenGL
        if ~loop.setOvertake
            % If not overtaking
            gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            loop.cameraXStore = [loop.cameraXStore, camera.xyz(1)];    % Stores the x position of the camera
        elseif loop.setOvertake
            % If overtaking
            gluLookAt(camera.xyz(1)+camera.overtakeWidth, camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            loop.cameraXStore = [loop.cameraXStore, camera.xyz(1)+camera.overtakeWidth];  % Stores the x position of the camera
        end
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing road and centrelines
    
        % Clear out the backbuffer
        glClear();
    
        % Draw Road, Verges
        drawOpenGLObject([0, 0, 0], road, "Square")         % Draw Road
        drawOpenGLObject([0, 0, -0.01], verge, "Square")    % Draw Verges

        % Draw Centreline
        for i = 1:length(centreline.y)                      
            drawOpenGLObject([0, centreline.y(i), 0], centreline, "Square")
        end
        % Move Centrelines
        centreline.y = centreline.y - loop.cameraVCurrent/scrn.frameRate;
        if centreline.y(1) <= -3                            % Remove them if they are far enough away
            centreline.y(1) = [];
            centreline.y    = [centreline.y centreline.y(end)+6];
        end
    
        % Update speed values
        loop.roadLeft           = loop.roadLeft - loop.cameraVCurrent*(1/scrn.frameRate);                               % Update the amount of "road" left with the camera's "relative" speed (it's a static image)
        loop.bikeStep           = (loop.cameraVCurrent - cyclist.speed)/scrn.frameRate;                                 % The distance a bike will move in a frame
        loop.oncomingCarStep    = (towardsCar.oncomingSpeed + loop.cameraVCurrent)/scrn.frameRate;                      % The distance a car in the other lane will move in a frame
        loop.inFlowCarStep      = (loop.cameraVCurrent - min(cyclist.speed))/scrn.frameRate;                            % The distance a car in the camera lane will move in a frame

        % Drawing the various 'road users' to the screen
        [cyclist, loop, test, loop.bikeYCurrent]            = drawAndMoveObject(cyclist, loop, test, 1);                % Drawing cyclist
        [withCar, loop, test, loop.withCarYCurrent]         = drawAndMoveObject(withCar, loop, test, 2);                % Drawing other in flow cars
        [towardsCar, loop, test, loop.towardsCarYCurrent]   = drawAndMoveObject(towardsCar, loop, test, 3);             % Drawing other oncoming cars

        % Getting which object is first & the actual/percieved 'gap'
        [loop.whichType, loop.whichInstance]                = getClosestObject(cyclist, withCar);
        [loop.gap(1, 1), loop.gap(2, 1)]                    = getCurrentGap(towardsCar, noise);

        % Append to storage matricies for later plotting
        loop.whichTypeStore     = [loop.whichTypeStore, loop.whichType];
        loop.whichInstanceStore = [loop.whichInstanceStore, loop.whichInstance];
        loop.gapStore           = [loop.gapStore, loop.gap];
        loop.cameraVStore       = [loop.cameraVStore, loop.cameraVCurrent];
        loop.bikeYStore         = [loop.bikeYStore, loop.bikeYCurrent];
        loop.withCarYStore      = [loop.withCarYStore, loop.withCarYCurrent];
        loop.towardsCarYStore   = [loop.towardsCarYStore, loop.towardsCarYCurrent];
        loop.roadStore          = [loop.roadStore, loop.roadLeft];

        % Flipping to the screen
        Screen('EndOpenGL', scrn.win);
        Screen('Flip', scrn.win);

        % Start counter to wait 0.5 secs after the event ends before fixing
        if loop.eventOverFlag
            loop.eventOverTimer = 0.5*scrn.frameRate;
        end
        
        %%%%%%%%%%%%%%%%%%%%%
        %%% Handling Button Presses
        % Allows speeding up and slowing down in a discrete manner following an event
        if test.discreteSpeed
            if loop.eventOverTimer == 0
                % Handles when an event has occured

                [loop, noise] = getPostEventResponse(loop, noise, scrn, cyclist, road, verge, centreline, keys, test, camera, "ongoing");

            else
                % Handles when an event has not occured
                
                % Handles Button Presses
                loop = getKeyMakeChange(loop, cyclist, keys, test, camera, scrn, [1, 0, 0, 1, 1, 1]);
                if loop.breakFlag == true
                    break;
                end 
            end

        else
            % This handles trials where the subject is in continuous control of their speed

            % Handles Button Presses
            loop = getKeyMakeChange(loop, cyclist, keys, test, camera, scrn, [1, 1, 1, 1, 1, 1]);
            if loop.breakFlag == true
                break;
            end

        end
        
        Screen('BeginOpenGL', scrn.win);
    
        % Inform the debug user
        if test.debug == 1
            disp("Current Frame     = " + loop.currentFrame)        % Useful for keeping track
        end    

        %%%%%%%%%%%%%%%%%%%%%
        %%% Handling Loop Processes
        loop.eventOverTimer = loop.eventOverTimer - 1;
        loop.currentFrame = loop.currentFrame + 1;                  % Update loop values
        loop.timeStore = [loop.timeStore toc];                      % Update the time tracking values
    
    end

    % records results of the current trial stored into a cell structure
    results.time{loop.currentTrial}             = loop.timeStore;           % Records the frame times
    results.road{loop.currentTrial}             = loop.roadStore;           % Records the road left at each frame
    results.bikeY{loop.currentTrial}            = loop.bikeYStore;          % Records the y position of the bikes
    results.towardsCarY{loop.currentTrial}      = loop.towardsCarYStore;    % Records the y position of the oncoming cars
    results.withCarY{loop.currentTrial}         = loop.withCarYStore;       % Records the y position of the cars in the lane
    results.cameraX{loop.currentTrial}          = loop.cameraXStore;        % Records the x position of the camera
    results.cameraV{loop.currentTrial}          = loop.cameraVStore;        % Records the speed of the camera
    results.whatFirst{loop.currentTrial}        = loop.whichTypeStore;      % Records what type of object is first in your lane
    results.whchFirst{loop.currentTrial}        = loop.whichInstanceStore;  % Records which instance of that object is first in your lane
    results.gap{loop.currentTrial}              = loop.gapStore;            % Records the gaps in the right lane

    % updates the loop value
    if ~loop.escapeFlag
        Screen('EndOpenGL', scrn.win);
        test.trials                     = test.trials - 1;          % Reduces the number of trails remaining by 1
        loop.currentTrial               = loop.currentTrial + 1;    % Updates which trial we are on
    else
        test.trials = 0;
    end
end

% Close open screen
Screen('CloseAll');

%% %%%%%%%%%%%%%%%%%%%
%%% Plotting Summary Results
close all;
if ~loop.skipPlot
    averageFrameRate = plotTrialSummary(loop.time{1}, loop.bikeY{1}, loop.cameraV{1}, noise.yNoise);
end

results.gravityCollisions                               = [0.15, 0.7, 0.8];           % order of R, G, B -> towardsCar, Cyclist, withCar
[results.bikeDist, results.carDist, results.car2Dist]   = plotGravityScoring(loop, towardsCar, cyclist, withCar, results.gravityCollisions);