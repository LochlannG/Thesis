function [speedometer, needle] = setupSpeedometer()
    
    %%%%%%%%%%%%%%%%%%%%%%
    %%% Speedometer setup
    % Create the output structure
    speedometer = struct();

    % Define constants
    speedometer.height = 0.25;
    speedometer.width = 0.5;


    speedometer.vertexCoords = single([-speedometer.width, 0, 0, ...
                                        speedometer.width, 0, 0, ...
                                        speedometer.width, 0, speedometer.height, ...
                                       -speedometer.width, 0, speedometer.height]);                         % coOrds for each vertex

    speedometer.vertexColors = single([0.29, 0.29,	0.31, ...
                                0.29, 0.29,	0.31, ...
                                0.29, 0.29,	0.31, ...
                                0.29, 0.29,	0.31]);                                                         % colours at each vertex

    speedometer.elementArray = int32([0, 1, 2, 3]);                                                         % vertex numbers for the faces

    % Create the output structure
    needle = struct();


    %%%%%%%%%%%%%%%%%%%%%%
    %%% Needle setup
    % Define constants
    needle.height = 0.2;
    needle.width = 0.1;


    needle.vertexCoords = single([-needle.width, 0, 0, ...
                                   needle.width, 0, 0, ...
                                   needle.width, 0, needle.height, ...
                                  -needle.width, 0, needle.height]);                         % coOrds for each vertex

    needle.vertexColors = single([  1,  1,	1, ...
                                    1,  1,	1, ...
                                    1,  1,	1, ...
                                    1,  1,	1,]);                                                         % colours at each vertex

    needle.elementArray = int32([0, 1, 2, 3]);                                                         % vertex numbers for the faces
end