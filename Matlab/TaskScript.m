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
results                     = struct();

% Setup Cyclist
cyclist                     = CyclistClass(road);
cyclist                     = cyclist.getVertexes();

% Setup Car objects
towardsCar  = CarClass(road, "other");
towardsCar  = towardsCar.setEndingVals(0, 0, 0);
towardsCar  = towardsCar.getVertexes();
withCar     = CarClass(road, "this");
withCar     = withCar.setEndingVals(20, 0.01, 60);
withCar     = withCar.getVertexes();

% Calling remaining setup functions
camera                      = setupCamera(towardsCar, road);                % Defining parameters - Camera
noise                       = setupNoise(scrn);                             % Defining parameters - Noise
keys                        = setupKeys();                                  % Defining parameters - Keys
loop                        = LoopClass(scrn);                              % Defining parameters - Loop

% Setup Speedometer
speedo = SpeedoClass(0.2, 1);
needle = SpeedoClass(0.02, 0.01);
marker = SpeedoClass(0.1, 0.01);
speedo = speedo.getVertexes([0, 0, 0]);
needle = needle.getVertexes([1, 0, 0]);
marker = marker.getVertexes([0.3, 0.3, 0.3]);


%% %%%%%%%%%%%%%%%%%%%
%%% Handling pinging the EMG software
% emg = EMGtriggers(hex2dec('4FF8'));
emg = 0;

%% %%%%%%%%%%%%%%%%%%%
%%% Main trial loop

while test.trials > 0
    
    
    %% %%%%%%%%%%%%%%%%%%%
    % Ping the software to say the trial has begun
    % emg.bigTaskMarker();

    
    %% %%%%%%%%%%%%%%%%%%%
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
    

    %% %%%%%%%%%%%%%%%%%%%
    %%% Sets/resets loop variables for the new trial
    % Variables that need to be reset for each new trial
    loop                    = loop.resetLoopVars(camera, test, scrn);

    
    %% %%%%%%%%%%%%%%%%%%%
    %%% Sets up trial loop variables for objects drawn to the screen
    % Sets up the cyclist variables for the trial loop
    cyclist                 = cyclist.resetLoop(test);
    test.nCyclists          = cyclist.n;

    % Sets up the oncoming traffic variables for the trial loop
    towardsCar              = towardsCar.resetLoop(test, cyclist, test.rateOncomingCar);
    test.nOncomingCars      = towardsCar.n;

    % Sets up the in flow traffic variables for the trial loop
    withCar                 = withCar.resetLoop(test, cyclist, test.rateInFlowCar);
    withCar                 = withCar.setSpeed(min(cyclist.speed));
    test.nInFlowCars        = withCar.n;

    
    %% %%%%%%%%%%%%%%%%%%%
    %%% Letting the user set their speed at the start
    noise.yNoise            = getDiscreteViewDist(noise.levels);
    cyclist                 = cyclist.setEndingVals(noise.yNoise);
    withCar                 = withCar.setEndingVals(noise.yNoise, 0, 100);
    loop.firstDisplay       = true;
    
    %% %%%%%%%%%%%%%%%%%%%
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
        
        %% %%%%%%%%%%%%%%%%%%%
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
        [loop, camera] = loop.overtakeHandling(camera);
        
        %% %%%%%%%%%%%%%%%%%%%
        %%% Drawing road and centrelines
        % Clear out the backbuffer
        glClear();
    
        % Draw Road, Verges
        drawOpenGLObject([0, 0, 0], [], [], road, "Square")         % Draw Road
        drawOpenGLObject([0, 0, -0.01], [], [], verge, "Square")    % Draw Verges

        % Draw Speedometer
        speedo.drawSpeedometer(loop, needle, marker, camera)

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
    
        % Update speed values & flags
        loop = loop.resetTopFrameFlags();
        loop = loop.updateSpeed(scrn, cyclist, towardsCar, withCar);
        
        
        %% %%%%%%%%%%%%%%%%%%%
        %%% Drawing objects
        % Drawing the various 'road users' to the screen        
        [cyclist, loop, test, loop.bikeYCurrent]            = drawAndMoveObject(cyclist, loop, test, 1, scrn);          % Drawing cyclist
        [withCar, loop, test, loop.withCarYCurrent]         = drawAndMoveObject(withCar, loop, test, 2, scrn);          % Drawing other in flow cars
        [towardsCar, loop, test, loop.towardsCarYCurrent]   = drawAndMoveObject(towardsCar, loop, test, 3, scrn);       % Drawing other oncoming cars

        
        %% %%%%%%%%%%%%%%%%%%%
        %%% Getting the 'Gap'
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
        [loop.gap(1, 1), loop.gap(2, 1)]        = getCurrentGap(towardsCar, noise);
        

        %% %%%%%%%%%%%%%%%%%%%
        %%% Wrap up at end of frame
        % Append to storage matricies for later plotting
        loop                                    = loop.updateStorage();

        % Flipping to the screen
        Screen('EndOpenGL', scrn.win);
        Screen('Flip', scrn.win);
        

        %% %%%%%%%%%%%%%%%%%%%
        %%% Handling Button Presses
        % Start counter to wait 0.5 secs after the event ends before fixing
        % & 2.0 seconds after the even for allowing speed
        if loop.eventOverFlag
            loop                                = loop.restartTimers(scrn, noise);
        end
        
        % Allows speeding up and slowing down in a discrete manner following an event
        [loop, noise, withCar, speedo, cyclist] = loop.getUserResponse(noise, withCar, speedo, cyclist, keys, camera, test, scrn, emg);
        if loop.breakFlag == true
            break;
        end
        
        
        %% %%%%%%%%%%%%%%%%%%%
        %%% Wrap up at end of frame (This must happen after user response
        % Inform the debug user
        if test.debug == 1
            disp("Current Frame     = " + loop.currentFrame)        % Useful for keeping track
        end    

        %% %%%%%%%%%%%%%%%%%%%
        %%% Handling Loop Processes
        loop = loop.endOfFrameWrapUp(toc);
        Screen('BeginOpenGL', scrn.win);
    
    end

    % records results of the current trial stored into a cell structure
    results = updateResults(results, loop);

    % updates the loop value
    if ~loop.escapeFlag
        Screen('EndOpenGL', scrn.win);
        test.trials                     = test.trials - 1;          % Reduces the number of trails remaining by 1
        loop.currentTrial               = loop.currentTrial + 1;    % Updates which trial we are on
    else
        test.trials = 0;
    end
end

% Close open screen at end of trial
Screen('CloseAll');


%% %%%%%%%%%%%%%%%%%%%
%%% Plotting Summary Results
close all;
if ~loop.skipPlot
    averageFrameRate = plotTrialSummary(loop.time{1}, loop.bikeY{1}, loop.cameraV{1}, noise.yNoise);
end

results.gravityCollisions                               = [0.15, 0.7, 0.8];           % order of R, G, B -> towardsCar, Cyclist, withCar
[results.bikeDist, results.carDist, results.car2Dist]   = plotGravityScoring(results, towardsCar, cyclist, withCar, results.gravityCollisions);