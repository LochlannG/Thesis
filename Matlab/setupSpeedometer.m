function [speedometer, needle, marker] = setupSpeedometer()
    
    %%%%%%%%%%%%%%%%%%%%%%
    %%% Speedometer setup
    % Create the output structure
    speedometer = struct();

    % Define constants
    speedometer.height = 0.2;
    speedometer.width = 1;
    speedometer.distance = 2;
    
    speedometer.normal = [0, 0, 1];

    speedometer = getShapeVertexes(speedometer, speedometer.width, speedometer.height, 0, [1, 1, 1], "Square");


    %%%%%%%%%%%%%%%%%%%%%%
    %%% Needle setup
    % Create the output structure
    needle = struct();

    % Define constants
    needle.height = 0.02;
    needle.width = 0.01;
    needle.normal = [0, 0, 1];
    
    needle = getShapeVertexes(needle, needle.width, needle.height, 0, [0, 0, 0], "Square");
% 
%     needle.vertexCoords = single([-needle.width, 0, 0, ...
%                                    needle.width, 0, 0, ...
%                                    needle.width, needle.height, 0, ...
%                                   -needle.width, needle.height, 0]);                         % coOrds for each vertex
% 
%     needle.vertexColors = single([  0,  0,	0, ...
%                                     0,  0,	0, ...
%                                     0,  0,	0, ...
%                                     0,  0,	0]);                                                         % colours at each vertex
% 
%     needle.elementArray = int32([0, 1, 2, 3]);                                                         % vertex numbers for the faces

    %%%%%%%%%%%%%%%%%%%%%%
    %%% Needle setup
    % Create the output structure
    marker = struct();

    % Define constants
    marker.height = 0.1;
    marker.width = 0.01;
    marker.normal = [0, 0, 1];

    marker = getShapeVertexes(marker, marker.width, marker.height, 0, [0.4, 0.4, 0.4], "Square");

%     marker.vertexCoords = single([-marker.width, 0, 0, ...
%                                    marker.width, 0, 0, ...
%                                    marker.width, marker.height, 0, ...
%                                   -marker.width, marker.height, 0]);                         % coOrds for each vertex
% 
%     marker.vertexColors = single([  0.4,  0.4,	0.4, ...
%                                     0.4,  0.4,	0.4, ...
%                                     0.4,  0.4,	0.4, ...
%                                     0.4,  0.4,	0.4]);                                                         % colours at each vertex
% 
%     marker.elementArray = int32([0, 1, 2, 3]);                                                         % vertex numbers for the faces
end