function scrn = setupPsychTLBX()

    Screen('Preference', 'SkipSyncTests', 1)
    
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

end