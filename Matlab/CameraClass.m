classdef CameraClass
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        fixPoint                                                    % Position the camera looks at (fixation point)
        maxSpeed                                                    % Maximum speed of the camera
        maxOverTPos                                                 % Maximum x position change (m)
        vCurrent                                                    % Current speed (m/s)
        xyz                                                         % Current XYZ positions
    end

    properties (Constant)
        
        % Positioning of camera in space
        lanePosRatio        = 0.5;                                  % Ratio of where the car is position within a lane
        driverPosRatio      = 0.25;                                 % Ratio of where a driver is positioned within a car
        overtakeWidth       = 1;                                    % How much the camera moves out when 'overtaking'
        driverZ             = 1.05;                                 % between [1.05, 2] https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6480464/

        % Constants for the openGL functions which create it
        upVec               = [0, 0, 1];                            % What direction is up at that fixation point
        FOVY                = 70;                                   % Field of view in the y direction

        % Constants for the movement of the camera
        yAccl               = ((100/3.6)/9);                        % We are assuming this car is a 2015 Golf which does 0-100 in 9 secs https://www.guideautoweb.com/en/articles/27805/volkswagen-golf-tdi-versus-golf-tsi-2015-two-tests-over-4-000-km/
        xAccl_Flying        = 1.12;
        xAccl_Acclerative   = 1.07;
    end

    methods
        function camera = CameraClass(maxV, maxX)
            %CAMERACLASS Construct an instance of this class
            %   Just sets the fixation point
            camera.fixPoint     = [0, 100, 0];                          % Position the camera looks at (fixation point)
            camera.maxSpeed     = maxV;                                 % Maximum speed of the camera, must be given in m/s
            camera.maxOverTPos  = maxX;
        end

        function camera = setSpeed(camera, speed)
            camera.vCurrent = speed;
        end

        function camera = updatePos(camera, scrn)
            camera.xyz(2) = camera.xyz(2) + camera.vCurrent/scrn.frameRate;
            camera.fixPoint(2) = camera.fixPoint(2) + camera.vCurrent/scrn.frameRate;

            disp(camera.xyz(2));
        end

        function camera = getDriverPosition(camera, car, road)
            %GETDRVIERPOSITION Summary of this method goes here
            % xyz = getDriverPosition(camera, car, road)
            % Gives a (3 x 1) array of x, y, z position of where the camera should be
            %
            % Inputs:
            % camera            -   Structure holding details of the camera object
            % car               -   Structure holding details of the car object
            % road              -   Structure holding details of the road object
            % 
            % Outputs:
            % xyz               -   (3 x 1) array of x, y, z position
            
            % x position is determined by a load of ratios.
            camera.xyz(1) = (-1) * (road.laneWidth - road.laneWidth*camera.lanePosRatio + car.width*0.5*camera.driverPosRatio);
            
            % y position is just whatever I set it to be, likely -1
            camera.xyz(2) = -1;
            
            % z position will be the height of the driver
            camera.xyz(3) = camera.driverZ;
        end
    end
end