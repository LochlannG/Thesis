% Task Code for the collection of data regarding driver-cyclist interaction
% Written by Lochlann Gallagher

clc; clear; close all;

%% %%%%%%%%%%%%%%%%%%%%
%%% Pyschtoolbox setup
AssertOpenGL;
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
withCar.potentialEnd        = 20;                       % The distance from the camera where the object can disappear
withCar.chanceOfEnding      = 0.01;                    	% Chance of ending per frame
withCar.spacing             = 50;                       % Minimum Distance between objects

% Calling remaining setup function
camera                      = setupCamera(towardsCar, road);                % Defining parameters - Camera
noise                       = setupNoise(scrn);                             % Defining parameters - Noise
loop                        = setupLoop(scrn);                              % Defining parameters - Loop
keys                        = setupKeys();                                  % Defining parameters - Loop
[speedo, needle, marker]    = setupSpeedometer();

%% %%%%%%%%%%%%%%%%%%%
%%% Handling pinging the EMG software
% emg = EMGtriggers(hex2dec('4FF8'));
emg = 0;

%% %%%%%%%%%%%%%%%%%%%
%%% Main trial loop

while test.trials > 0
    
    %%%%%%%%%%%%%%%%%%%%%
    % Ping the software to say the trial has begun
%     emg.bigTaskMarker();

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
    
    % Variables that need to be reset for each new trial
    loop.currentFrame       = 1;
    loop.roadLeft           = test.lengthM;
    loop.setOvertake        = false;
    loop.skipPlot           = false;
    loop.cameraVCurrent     = camera.startSpeed;
    loop.cameraStartX       = camera.xyz(1);
    loop.eventOverTimer     = -1;
    loop.firstDisplay       = 1;
    loop.stopResponse       = true;
    loop.speedUpMaxFrames   = round(scrn.frameRate*2, 0);     % You're allowed speed up for 2 seconds following a stimulus
    loop.speedUpLeft        = loop.speedUpMaxFrames;
    loop.nFramShown         = 0;
    loop.whichTypeStore     = []; loop.whichType = 0;
    loop.whichInstanceStore = []; loop.whichInstance = 0;
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
    cyclist.stimStartM      = test.lengthM - getStimStarts(test.lengthM, 100, cyclist.spacing, test.rateCyclist, []);
    cyclist.n               = length(cyclist.stimStartM);
    test.nCyclists          = cyclist.n;
    cyclist.speed           = getCyclistSpeed(14/3.6, 3/3.6, 2, test.nCyclists);
    cyclist.start           = getCyclistStartPos(test.nCyclists);
    cyclist.y               = ones(test.nCyclists, 1)*100;%.*cyclist.start';
    cyclist.stimOn          = false(test.nCyclists, 1);
    cyclist.stimApp         = false(test.nCyclists, 1);
    cyclist.stimCurrent     = 1;

    % Sets up the oncoming traffic variables for the trial loop
    towardsCar.stimStartM   = test.lengthM - getStimStarts(test.lengthM, towardsCar.start, towardsCar.spacing, test.rateOncomingCar, test.lengthM-cyclist.stimStartM);
    towardsCar.n            = length(towardsCar.stimStartM);
    test.nOncomingCars      = towardsCar.n;
    towardsCar.stimCurrent  = 1;
    towardsCar.y            = ones(test.nOncomingCars, 1)*towardsCar.start;
    towardsCar.stimOn       = false(test.nOncomingCars, 1);
    towardsCar.stimApp      = false(test.nOncomingCars, 1);

    % Sets up the in flow traffic variables for the trial loop
    withCar.stimStartM      = test.lengthM - getStimStarts(test.lengthM, withCar.start, withCar.spacing, test.rateInFlowCar, []);
    withCar.n               = length(towardsCar.stimStartM);
    test.nInFlowCars        = withCar.n;
    withCar.speed           = min(cyclist.speed);
    withCar.stimCurrent     = 1;
    withCar.y               = ones(test.nInFlowCars, 1)*towardsCar.start;
    withCar.stimOn          = false(test.nInFlowCars, 1);
    withCar.stimApp         = withCar.stimOn();

    %%%%%%%%%%%%%%%%%%%%%
    %%% Letting the user set their speed at the start
%     [loop, noise] = getPostEventResponse(loop, noise, scrn, cyclist, road, verge, centreline, keys, test, camera, "first", emg);
    noise.yNoise = getDiscreteViewDist(noise.levels);
    cyclist.potentialEnd = noise.yNoise;
    withCar.potentialEnd = noise.yNoise;
    loop.firstDisplay = true;
    
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
            if loop.firstDisplay
                gluPerspective(70 , 1/scrn.ar, 0.1,  noise.yNoise);
            else
                gluPerspective(70 , 1/scrn.ar, 0.1, noise.vector(noise.iteration));
                noise.iteration = noise.iteration + 1;
                if noise.iteration >= noise.maxIter
                    noise.iteration = noise.maxIter;
                    loop.stopResponse = true;
                end
            end
        else
            gluPerspective(70 , 1/scrn.ar, 0.1, noise.yNoise(loop.currentFrame));
        end
    
        % Handles camera positioning & fixation
        % gluLookAt() is the function responsible for camera positioning in OpenGL
        if ~loop.setOvertake
            % If not overtaking
            camera.xyz(1) = loop.cameraStartX;
            gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            loop.cameraXStore = [loop.cameraXStore, camera.xyz(1)];    % Stores the x position of the camera
        elseif loop.setOvertake
            % If overtaking
            camera.xyz(1) = loop.cameraStartX + camera.overtakeWidth;
            gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            loop.cameraXStore = [loop.cameraXStore, camera.xyz(1)+camera.overtakeWidth];  % Stores the x position of the camera
        end
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing road and centrelines
    
        % Clear out the backbuffer
        glClear();
    
        % Draw Road, Verges
        drawOpenGLObject([0, 0, 0], [], [], road, "Square")         % Draw Road
        drawOpenGLObject([0, 0, -0.01], [], [], verge, "Square")    % Draw Verges

        % Draw Speedometer
        drawSpeedometer(loop, speedo, needle, marker, camera)

        % Draw Centreline
        for i = 1:length(centreline.y)                      
            drawOpenGLObject([0, centreline.y(i), 0], [], [], centreline, "Square")
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
        loop.inFlowCarStep      = (loop.cameraVCurrent - withCar.speed)/scrn.frameRate;                            % The distance a car in the camera lane will move in a frame

        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawingiong objects
        % Drawing the various 'road users' to the screen        
        [cyclist, loop, test, loop.bikeYCurrent]            = drawAndMoveObject(cyclist, loop, test, 1);                % Drawing cyclist
        [withCar, loop, test, loop.withCarYCurrent]         = drawAndMoveObject(withCar, loop, test, 2);                % Drawing other in flow cars
        [towardsCar, loop, test, loop.towardsCarYCurrent]   = drawAndMoveObject(towardsCar, loop, test, 3);             % Drawing other oncoming cars

        % Getting which object is first & the actual/percieved 'gap'
        [loop.whichType, loop.whichInstance, loop.oneVis]   = getClosestObject(cyclist, withCar);
        
        % If the object in front has changed since the last time
        try
            if or(loop.whichType ~= loop.whichTypeStore(end-1), loop.whichInstance ~= loop.whichInstanceStore(end-1))
                loop.nFramShown = 0;
            end
        catch
            % do nothing
        end
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

            if loop.eventOverTimer == 0 % Handles when an event has occured
                [loop, noise, speedo] = getPostEventResponse(loop, noise, speedo);
                cyclist.potentialEnd = noise.yNoise;                % Update Cyclist potential end zone
                withCar.potentialEnd = noise.yNoise;                % Update the same for cars in your lane
            elseif ~loop.stopResponse % Are they allowed speed up?

                loop = getKeyMakeChange(loop, cyclist, keys, test, camera, scrn, [1, 0, 1, 1, 0, 1], emg);

            else % Handles when an event has not occured
                rgb = [1, 1, 1];
                speedo.vertexColors = reshape(single(ones(4, 3).*rgb)', 1, length(single(ones(4, 3).*rgb))*3);
                % They are only allowed 
                loop = getKeyMakeChange(loop, cyclist, keys, test, camera, scrn, [1, 0, 0, 1, 0, 1], emg);
                
            end

            if loop.breakFlag == true
                    break;
            end


        else
            % This handles trials where the subject is in continuous control of their speed

            % Handles Button Presses
            loop = getKeyMakeChange(loop, cyclist, keys, test, camera, scrn, [1, 1, 1, 1, 0, 1], emg);
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
[results.bikeDist, results.carDist, results.car2Dist]   = plotGravityScoring(results, towardsCar, cyclist, withCar, results.gravityCollisions);