function [loop, noise] = getPostEventResponse(loop, noise, scrn, cyclist, road, centreline, keys, test, camera)
% [loop, noise] = getPostEventResponse(loop, noise, scrn, cyclist, road, centreline, keys, test, camera)
% Pauses the current situation following an event, shows a subject their
% new view distance and allows them to set a new speed
%
% Inputs:
% loop              -   Structure holding details of the current trial loop
% noise             -   Structure holding details of the noise object
% scrn              -   Structure holding details of the scrn object
% cyclist           -   Structure holding details of the road object
% road              -   Structure holding details of the road object
% centreline        -   Structure holding details of the centreline object
% keys              -   Structure holding details of the keys object
% test              -   Structure containing details of how the test is setup
% camera            -   Structure holding details of the camera object
%
% Outputs:
% loop              -   Updated structure holding details of the current trial loop
% noise             -   Updated structure holding details of nois structure
%
% Author - Lochlann Gallagher
% Changelog (I'm not very good at maintaining this):
% 1.0 - Created function 

    global GL

    %% Tell the user that they have to adjust their speed
    waitingTime = 2;
    
    while waitingTime>0
        % Displays a message to the user
        textString = ['Event Passed\nPlease set your speed based on the new view distance in:\n' num2str(waitingTime)];
        DrawFormattedText(scrn.win, textString, 'center', 'center', scrn.whit);
        Screen('Flip', scrn.win)
        pause(1)
        waitingTime = waitingTime - 1;
    end

    %% Display the new view distance to the user
    % Change the distance that the camera can see
    noise.yNoise = getDiscreteViewDist(noise.levels);

    % OpenGL setup taken directly from the main loop
    Screen('BeginOpenGL', scrn.win);
    glMatrixMode(GL.MODELVIEW);             % Setup up which mode OpenGL will draw within
    glLoadIdentity;
    glEnable(GL.DEPTH_TEST);                % This ensures closer objects are drawn on top
    glShadeModel(GL.SMOOTH);
    glClearColor(0.5,0.5,0.5,1);            % Sets the background colour
    glMatrixMode(GL.PROJECTION);
    glLoadIdentity;
    gluPerspective(70 , 1/scrn.ar, 0.1, noise.yNoise);
    gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
    glClear();                              % Clear out the backbuffer

    % Draw Road & Centrelines
    drawOpenGLObject([0, 0, 0], road, "Square")
    for i = 1:length(centreline.y)
        drawOpenGLObject([0, centreline.y(i), 0], centreline, "Square")
    end

    Screen('EndOpenGL', scrn.win);
    Screen('Flip', scrn.win);
    pause(waitingTime)
    
    %% Get user feedback about their new speed
    loop.cameraVCurrent = 50/3.6;   % Bring them to 50 km/h so they don't have to go up and down the spectrum
    loop.setOvertake = false;       % Move them in if they overtook in the last frame

    % Loop which keeps a frame up that tells users about their 
    while true

        % Displays a message to the user
        textString = ['Use the up and down keys to set your new speed' '\nSpeed: ' num2str(loop.cameraVCurrent*3.6) '\nPress return to continue'];
        DrawFormattedText(scrn.win, textString, 'center', 'center', scrn.whit);
        Screen('Flip', scrn.win)
        
        % Handles Button Presses
        loop = getKeyMakeChange(loop, cyclist, keys, test, camera, scrn, [0, 1, 1, 1, 0, 0]);
        if loop.breakFlag == true
            break;
        end

    end

end