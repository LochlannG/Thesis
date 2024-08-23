% Task Code for the collection of data regarding driver-cyclist interaction
% Written by Lochlann Gallagher

clc; clear; close all;


%%%%%%%%%%%%%%%%%%%%
%%% Pyschtoolbox setup
AssertOpenGL;
PsychDefaultSetup(2);
InitializeMatlabOpenGL(0, 0, 0, 0);                 % Initialise this with all zeros to improve performance

%%%%%%%%%%%%%%%%%%%%
%%% Defining Parameters
% Call setup functions
trial                       = TrialClass();             % Create instance of the trial class
scrn                        = setupPsychTLBX();       	% Call psychtoolbox setup function
[road, verge, centreline]   = setupRoad(trial);         % Setup road & centreline

car                         = CarClass(road, "right");  % Create car class on the right hand side
car                         = car.getVertexes();        % Create it's openGL parts

car2                        = CarClass(road, "left");   % Create car class on the left hand side
car2                        = car2.getVertexes();       % Create it's openGL parts
car2                        = car2.setSpeed(35/3.6);    % Set the speed of this car

camera                      = CameraClass(200/3.6, road.laneWidth, car, road);
keys                        = KeysClass();              % Create instance of the keys class

%%%%%%%%%%%%%%%%%%%
%%% Main trial loop
camera = camera.setSpeed(200/3.6);

while trial.currentBlock <= trial.nBlocks
    
    %%%%%%%%%%%%%%%%%%%
    %%% Displays a message to the user at the start of the block
    trial.printBlock(scrn, keys)

    % Set up the car positions
    car     = car.setPosition(200);
    car2    = car2.setPosition(100);
    
    while trial.currentTrial < trial.nTrials + 1

        trial.printTrial(scrn, 0.1);
        
        %%%%%%%%%%%%%%%%%%%
        %%% OpenGL setup
        
        Screen('BeginOpenGL', scrn.win);        % This is required at the start of every OpenGL frame
        glMatrixMode(GL.MODELVIEW);             % Setup up which mode OpenGL will draw within
        glLoadIdentity;                         % Haven't a clue what this does but don't get rid of it
        glEnable(GL.DEPTH_TEST);                % This ensures closer objects are drawn on top
        glShadeModel(GL.SMOOTH);                % Choses the shader model, wouldn't really change
        glClearColor(0.5, 0.5, 0.5, 1);         % Sets the background colour
    
        [trial, camera] = trial.resetTrial(camera);

        % Frame Loop
        while  camera.xyz(2) <= trial.roadLength
        
            % Timing
            tic
            
            %%%%%%%%%%%%%%%%%%%
            %%% Camera
            % Handles the setup of the perspective projection for the camera
            glMatrixMode(GL.PROJECTION);
            glLoadIdentity;
            gluPerspective(70 , 1/scrn.ar, 0.1, 80);
            gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
            
            %%%%%%%%%%%%%%%%%%%
            %%% Drawing road and centrelines
            % Clear out the backbuffer
            glClear();
        
            % Draw Road, Verges
            drawOpenGLObject([0, 0, 0], [], [], road, "Square")         % Draw Road
            drawOpenGLObject([0, 0, -0.01], [], [], verge, "Square")    % Draw Verges
    
            % Draw Centreline
            for i = 1:length(centreline.y)                      
                drawOpenGLObject([0, centreline.y(i), 0], [], [], centreline, "Square")
            end
            
            %%%%%%%%%%%%%%%%%%%
            %%% Drawing objects
            % Drawing the various 'road users' to the screen
            drawOpenGLObject([car.x, car.y, 0], [], [], car, "Cube")
            drawOpenGLObject([car2.x, car2.y, 0], [], [], car2, "Cube")

            %%%%%%%%%%%%%%%%%%%
            %%% End of Frame Wrapup
            % Flipping to the screen
            Screen('EndOpenGL', scrn.win);
            Screen('Flip', scrn.win);

            % Update the position of the objects
            car = car.updateCarPos(scrn);
            
            % Get the keys values
            keys = keys.getKey([1, 0, 1, 1, 0, 1]);
            if keys.breakFlag == true
                break;
            end

            % Update the position of the Camera
            camera = camera.updatePos(scrn, keys);
            
            % Start another openGL session
            Screen('BeginOpenGL', scrn.win);
        
        end
        
        %%%%%%%%%%%%%%%%%%%
        %%% End of Trial Wrapup
        if keys.escapeFlag
            break;
        else
            trial = trial.iterateTrial();
            Screen('EndOpenGL', scrn.win);
        end

    end

    %%%%%%%%%%%%%%%%%%%
    %%%% End of Block Wrapup
    trial = trial.iterateBlock();
end

%%%%%%%%%%%%%%%%%%%
%%%% End of Experiment Wrapup
Screen('CloseAll');% Close open screen at end of trial