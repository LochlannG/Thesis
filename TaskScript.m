% Task Code for the collection of data regarding driver-cyclist interaction
% Written by Lochlann Gallagher
% 0.1 - 18/02/2024 - Trying to work out the structure of OpenGL's
% implementation in pyschtoolbo
% x. Created the psychtoolbox structure and
% drew in the axes. Created the 'road' object
% 0.2 - 20/02/2024 - Added the cyclist back in
% 0.3 - 21/02/2024 - Got the cyclist moving
% 0.4 - 22/02/2024 - Created the noisey road stuff
% 0.5 - 25/02/2024 - Allowed the car to accelarate + Gave the subject an
% option to slow down
% 0.6 - 11/03/2024 - Removed the uniform acceleration + Added support for
% arrow keys to facilitate user controlled acceleration + Removed Support
% for button presses
% 0.7 - 11/03/2024 - Added other cars
% 0.8 - 02/04/2024 - Added Git integration for better version control

clc; clear; close all;

AssertOpenGL;

%%%%%%%%%%%%%%%%%%%%%
%%% Pyschtoolbox setup

PsychDefaultSetup(2);
InitializeMatlabOpenGL(0, 0, 0, 0);                                                     % Initialise this with all zeros to improve performance

% Pulling important details from Screen() object
scrn = struct();
scrn.id = max(Screen('Screens'));
scrn.gray = GrayIndex(scrn.id);
scrn.whit = WhiteIndex(scrn.id);
scrn.imagingConfig = PsychImaging('PrepareConfiguration');
[scrn.win , scrn.winRect] = PsychImaging('OpenWindow', scrn.id, scrn.gray);
scrn.frameRate = Screen('FrameRate', scrn.id);                                          % Get frame rate of screen
[scrn.Xpixels, scrn.Ypixels] = Screen('WindowSize', scrn.win);                          % Get x & y distances on the screen
[scrn.xCenter, scrn.yCenter] = RectCenter(scrn.winRect);
Screen('TextFont', scrn.win, 'Ariel');
Screen('TextSize', scrn.win, 50);

% Work arounds to convert Pyschtoolbox measurements -> OpenGL
scrn.ar = RectHeight(scrn.winRect) / RectWidth(scrn.winRect);                           % Aspect ratio of screen
glViewport(0, 0, RectWidth(scrn.winRect), RectHeight(scrn.winRect));                    % Gives the shape of the screen to OpenGL

% Defining parameters governing the length of the test
test = struct();
test.trials = 2;
test.recordEEG = false;

% This determines the length of the trail and the amount of various stimuli you
% 'expect' to see come up
test.lengthM = 200;                                                                    % Similar to a small journey to a shop
test.context = 'urban';
test = setContext(test);

% Defining parameters - Road
road = struct();
road.centreLineWidth = 0.05;
road.drawDist = 80;
road.laneWidth = 2.5;
road.totalWidth = road.laneWidth*2;                                                     % RSA local road standard
road.vertexCoords = single([-road.laneWidth, 0, 0, ...
                            road.laneWidth, 0, 0, ...
                            road.laneWidth, road.drawDist, 0, ...
                            -road.laneWidth, road.drawDist, 0]);                        % coOrds for each vertex
road.vertexColors = single([0.29, 0.29,	0.31, ...
                            0.29, 0.29,	0.31, ...
                            0.29, 0.29,	0.31, ...
                            0.29, 0.29,	0.31]);                                                    % colours at each vertex
road.elementArray = int32([0, 1, 2, 3]);                                                % vertex numbers for the faces

% Defining parameters specificly to do with the cyclist
cyclist = struct();
cyclist.speed = 14/3.6;
cyclist.start = 100; 
cyclist.curbDist = 0.5;
cyclist.potentialEnd = 30;
cyclist.chanceOfEnding = 0.15;
cyclist = createCylistVertexes(cyclist, 0.25, 1.5, 1, [0.46, 0.96, 0.26]);

% Defining parameters - Car
car = struct();
car.startSpeed = 0;
car.maxSpeed = 100/3.6;
car.acceleration = ((100/3.6)/9);                                                       % We are assuming this car is a 2015 Golf which does 0-100 in 9 secs https://www.guideautoweb.com/en/articles/27805/volkswagen-golf-tdi-versus-golf-tsi-2015-two-tests-over-4-000-km/
car.width = 1.8;
car.potentialEnd = 5;
car.lanePosRatio = 0.5;
car.driverPosRatio = 0.5;
car.overtakeWidth = 1;
car.oncomingSpeed = car.maxSpeed;
car.start = 100;
car.x = 0.5*road.laneWidth;
car = createCylistVertexes(car, 1, 1.5, 1, [1, 0, 0]);

% Car 2 - inflow traffic
car2 = car;
car2.x = -0.5*road.laneWidth;
car2.chanceOfEnding = 0.15;

% Centreline
centreline = struct();
centreline.width = 0.15;
centreline.length = 3;
centreline.vertexCoords = single([-centreline.width/2, 0, 0.1, ...
                            centreline.width/2, 0, 0.1, ...
                            centreline.width/2, centreline.length, 0.1, ...
                            -centreline.width/2, centreline.length, 0.1]);                        % coOrds for each vertex
centreline.vertexColors = single([1,  1,  1, ...
                            1,  1,	1, ...
                            1,  1,	1, ...
                            1,  1,	1]);                                                    % colours at each vertex
centreline.elementArray = int32([0, 1, 2, 3]);                                                % vertex numbers for the faces

% Defining parameters - Camera
camera = struct();
camera.FOVY = 70;
camera.driverZ = 1.5;                                                             % between [1.05, 2]
camera.xyz = driverPosition(camera, car, road);
camera.fixPoint = [0, 100, 0];
camera.upVec = [0, 0, 1];

% Defining parameters - Noise
noise.limits = [0, 50];                                      % range limits for the generation of noise (caution: don't use negative values)
noise.nWaves = 5;
noise.noiseAmp = 20;
noise.avK = 200;
noise.maxSinF = 0.5;
noise.minViewDistance = 10;

% Defining parameters - EEG
EEGparams.CORRECT     = 1;
EEGparams.INCORRECT   = 2;
EEGparams.TOOEARLY    = 3;
EEGparams.TOOLATE     = 4;
EEGparams.RELEASED    = 5;
EEGparams.CD_BUTTONS = [12 13]; % Left and right mouse buttons

%%%%%%%%%%%%%%%%%%%%%
%%% Setting up variables for use in the loop
% Generate sample stamps that mark when the 'cyclists' will appear
cyclist.x = cyclist.curbDist-road.laneWidth;


% loop structure to hold data about the main loop
loop = struct();
loop.escapeFlag = false;
loop.time = {}; loop.bikeY = {}; loop.carV ={}; loop.road = {}; loop.carY ={}; loop.car2Y = {}; loop.subjectX = {};
loop.currentTrial = 1;

% Get key names
keys = struct();
keys.escape = KbName('ESCAPE');
keys.enter  = KbName('return');
keys.lt = KbName('LeftArrow');
keys.rt = KbName('RightArrow');
keys.dw = KbName('DownArrow');
keys.up = KbName('UpArrow');

%%%%%%%%%%%%%%%%%%%%%
%%% Handling pinging the EMG software
% emg = EMGtriggers;

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
    %%% Sets/resets loop variables for the current trial
    noise.yNoise = viewDistance(scrn.frameRate, test.lengthM, "WN", noise) + noise.minViewDistance;
    loop.currentFrame = 1;
    loop.roadLeft = test.lengthM;
    loop.setOvertake = false;
    loop.skipPlot = false;
    loop.carVCurrent = 40/3.6;
    loop.timeStore = []; loop.bikeYStore = []; loop.carVStore = []; loop.roadStore = []; loop.carYStore =[]; loop.car2YStore =[]; loop.subjectXStore = [];

    %%%%%%%%%%%%%%%%%%%%%
    %%% Sets up trial loop variables for objects drawn to the screen
    % Sets up the cyclist variables for the trial loop
    cyclist.stimStartM = generateStarts(test.lengthM, cyclist.start, test.rateCyclist*round(test.lengthM/1000));
    cyclist.stimStartM = test.lengthM - cyclist.stimStartM;
    test.nCyclists = length(cyclist.stimStartM);
    cyclist.stimEndM = rand(test.nCyclists, 1)*cyclist.potentialEnd;
    cyclist.y = ones(test.nCyclists, 1)*cyclist.start;
    cyclist.stimOn = false(test.nCyclists, 1);
    cyclist.stimCurrent = 1;

    % Sets up the oncoming traffic variables for the trial loop
    car.stimStartM = test.lengthM - generateStarts(test.lengthM, car.start, test.rateOncomingCar*round(test.lengthM/1000));
    test.nOncomingCars = length(car.stimStartM);
    car.stimCurrent = 1;
    car.y = ones(test.nOncomingCars, 1)*car.start;
    car.stimOn = false(test.nOncomingCars, 1);

    % Sets up the in flow traffic variables for the trial loop
    car2.stimStartM = test.lengthM - generateStarts(test.lengthM, car2.start, test.rateInFlowCar*round(test.lengthM/1000));
    test.nInFlowCars = length(car2.stimStartM);
    car2.stimCurrent = 1;
    car2.stimEndM = rand(test.nInFlowCars, 1)*car2.potentialEnd;
    car2.y = ones(test.nInFlowCars, 1)*car.start;
    car2.stimOn = false(test.nInFlowCars, 1);

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
        
        %%%%%%%%%%%%%%%%%%%%%
        %%% Camera
    
        % Handles the setup of the perspective projection for the camera
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        gluPerspective(70 , 1/scrn.ar, 0.1, noise.yNoise(loop.currentFrame));
    
        % Handles camera positioning & fixation
        if ~loop.setOvertake
            gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            loop.subjectXStore= [loop.subjectXStore, camera.xyz(1)];    % Stores the x position of the camera
        elseif loop.setOvertake
            gluLookAt(camera.xyz(1)+car.overtakeWidth, camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            loop.subjectXStore= [loop.subjectXStore, camera.xyz(1)+car.overtakeWidth];  % Stores the x position of the camera
        end
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing road
    
        % Clear out the backbuffer
        glClear();
    
        % Draw Road
        drawSquare([0, 0, 0], road)

        % Draw Centreline
        drawSquare([0, 2, 0], centreline)
    
        % Handling Speed
        loop.roadLeft = loop.roadLeft - loop.carVCurrent*(1/scrn.frameRate);
        loop.relativeSpeed = loop.carVCurrent - cyclist.speed;                              % difference in speed (the velocities are aligned) between driver and bike
        loop.bikeStep = loop.relativeSpeed/scrn.frameRate;                                  % the distance a bike will go in a frame
        loop.oncomingCarStep = (car.oncomingSpeed + loop.carVCurrent)/scrn.frameRate;
        loop.inFlowCarStep = loop.relativeSpeed;
    
        loop.carVStore = [loop.carVStore, loop.carVCurrent];
        loop.roadStore = [loop.roadStore, loop.roadLeft];
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing cyclist
    
        % This loop handles the logic turning a 'cyclist' stimulus on when it
        % reaches the correct frame.
        if cyclist.stimStartM(cyclist.stimCurrent) >= loop.roadLeft
            cyclist.stimOn(cyclist.stimCurrent) = true;
            disp("Cyclist Stimulus Begun at Frame = " + loop.currentFrame);
            if cyclist.stimCurrent < length(cyclist.stimStartM)
                cyclist.stimCurrent = cyclist.stimCurrent + 1; 
            end
        end
    
        % This loop handles the movement of the 'cyclist'
        loop.bikeYtoAppend = nan(test.nCyclists, 1);
        for stimInt = find(cyclist.stimOn, 1, "first"):find(cyclist.stimOn, 1, "last")
            % Draw the cyclist to the screen using the drawCyclist function
            drawCube([cyclist.x, cyclist.y(stimInt), 1], cyclist);
    
            % update position based on relative speed and frame rate
            cyclist.y(stimInt) = cyclist.y(stimInt) - loop.bikeStep;
    
            % If the y position of the 'cyclist' is less than 0 then it must
            % have reached the end of the track
            if cyclist.y(stimInt) < 0
                cyclist.stimOn(stimInt) = false;                        % Turn the stimulus off
                disp(num2str(stimInt) + " finished track")      % Print message
            end

            if cyclist.y(stimInt) < cyclist.potentialEnd
                if rand() < cyclist.chanceOfEnding
                    cyclist.stimOn(stimInt) = false;
                    disp("In-flow Car #" + num2str(stimInt) + " turned off the track")
                end
            end
    
            loop.bikeYtoAppend(stimInt) = cyclist.y(stimInt);
        end
    
        loop.bikeYStore = [loop.bikeYStore, loop.bikeYtoAppend];
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing other oncoming cars
    
        % This loop handles the logic turning a 'car' stimulus on when it
        % reaches the correct frame.
        if car.stimStartM(car.stimCurrent) >= loop.roadLeft
            car.stimOn(car.stimCurrent) = true;
            disp("Oncoming car begun at frame = " + loop.currentFrame);
            if car.stimCurrent < length(car.stimStartM)
                car.stimCurrent = car.stimCurrent + 1; 
            end
        end
    
        % This loop handles the movement of the 'car'
        loop.carYToAppend = nan(test.nOncomingCars, 1);
        for stimInt = find(car.stimOn, 1, "first"):find(car.stimOn, 1, "last")
    
            % Draw the cyclist to the screen using the drawCyclist function
            drawCube([car.x, car.y(stimInt), 1], car);
    
            % update position based on relative speed and frame rate
            car.y(stimInt) = car.y(stimInt) - loop.oncomingCarStep;
    
            % If the y position of the 'car' is less than 0 then it must
            % have reached the end of the track so we can stop drawing it
            if car.y(stimInt) < 0
                car.stimOn(stimInt) = false;                        % Turn the stimulus off
                disp(num2str(stimInt) + " finished track")          % Print message
            end
    
            loop.carYToAppend(stimInt) = car.y(stimInt);
        end
    
        loop.carYStore = [loop.carYStore, loop.carYToAppend];
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing other in flow cars
    
        % This loop handles the logic turning a 'car2' stimulus on when it
        % reaches the correct frame.
        if test.nInFlowCars > 0
            if car2.stimStartM(car2.stimCurrent) >= loop.roadLeft
                car2.stimOn(car2.stimCurrent) = true;
                disp("Oncoming car begun at frame = " + loop.currentFrame);
                if car2.stimCurrent < length(car2.stimStartM)
                    car2.stimCurrent = car2.stimCurrent + 1; 
                end
            end
        end

        % This loop handles the movement of the 'car'
        loop.car2YToAppend = nan(test.nInFlowCars, 1);
        for stimInt = find(car2.stimOn, 1, "first"):find(car2.stimOn, 1, "last")
    
            % Draw the cyclist to the screen using the drawCyclist function
            drawCube([car2.x, car2.y(stimInt), 1], car2);
    
            % update position based on relative speed and frame rate
            car2.y(stimInt) = car2.y(stimInt) - loop.bikeStep;
    
            % If the y position of the 'cyclist' is less than 0 then it must
            % have reached the end of the track
            if car2.y(stimInt) < 0
                car2.stimOn(stimInt) = false;                        % Turn the stimulus off
                disp(num2str(stimInt) + " finished track")          % Print message
            end

            if car2.y(stimInt) < car2.potentialEnd
                if rand() < car2.chanceOfEnding
                    car2.stimOn(stimInt) = false;
                    disp("In-flow Car #" + num2str(stimInt) + " turned off the track")
                end
            end
    
            loop.car2YToAppend(stimInt) = car2.y(stimInt);
        end

        loop.car2YStore = [loop.car2YStore, loop.car2YToAppend];
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Drawing to Screen
    
        % Flipping to the screen
        Screen('EndOpenGL', scrn.win);
        Screen('Flip', scrn.win);
        Screen('BeginOpenGL', scrn.win);
    
        % Inform the debug user    
        disp("Current Frame     = " + loop.currentFrame)                                             % Useful for keeping track
    
        %%%%%%%%%%%%%%%%%%%%%
        %%% Handling Button Presses
    
        % Handles Button Presses
        [~, ~, keys.Code] = KbCheck;
        if all(keys.Code(keys.escape))
            % Handles the escape key
            loop.skipPlot = true;
            loop.escapeFlag = true;
            break;
        end
        if all(keys.Code(keys.up))
            % Handles speeding up
            disp("Speed Up")
            loop.carVCurrent = loop.carVCurrent + car.acceleration*(1/scrn.frameRate);
            if loop.carVCurrent >= car.maxSpeed
                loop.carVCurrent = car.maxSpeed;
            end
    
        end
        if all(keys.Code(keys.dw))
            % Handles slowing down
            disp("Slow Down")
            loop.carVCurrent = loop.carVCurrent - 5*car.acceleration*(1/scrn.frameRate);
            if loop.carVCurrent <= cyclist.speed
                loop.carVCurrent = cyclist.speed;
            end
    
        end
        if all(keys.Code(keys.lt))
            % Handles moving back into your lane
            disp("Back to lane")
            loop.setOvertake = false;
    
        end
        if all(keys.Code(keys.rt))
            % Handles overtaking
            disp("Overtake")
            loop.setOvertake = true;
    
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
if ~loop.skipPlot
    close all;
    averageFrameRate = plotTrialSummary(loop.time{1}, loop.bikeY{1}, loop.carV{1}, noise.yNoise);
end