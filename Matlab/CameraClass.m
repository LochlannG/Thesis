classdef CameraClass
    %CAMERACLASS 
    %   Detailed explanation goes here

    properties
        fixPoint                                                    % Position the camera looks at (fixation point)
        maxSpeed                                                    % Maximum speed of the camera
        maxOverTPos                                                 % Maximum x position change (m)
        vCurrent                                                    % Current speed (m/s)
        xyz                                                         % Current XYZ positions

        startxyz                                                    % First XYZ positions
        startFixPnt                                                 % First fixation point
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
        function camera = CameraClass(maxV, maxX, car, road)
            % CAMERACLASS Construct an instance of this class

            % Just sets the fixation point and a few maximum speeds
            camera.fixPoint     = [0, 100, 0];                          % Position the camera looks at (fixation point)
            camera.maxSpeed     = maxV;                                 % Maximum speed of the camera, must be given in m/s
            camera.maxOverTPos  = maxX;                                 % Maximum overtake position
            camera.xyz          = camera.getDriverPosition(car, road);  % Gets the starting position of the camera. This using a function which should probably be depricated lets be so for real right now

            % This will keep a recorded value from the start
            camera.startxyz     = camera.xyz;
            camera.startFixPnt  = camera.fixPoint;
        end

        function camera = setSpeed(camera, speed)
            % SETSPEED set the speed of the camera to the given value (m/s)
            
            camera.vCurrent = speed;
        end

        function camera = updatePos(camera, scrn, keys)
            % UPDATEPOS update the position of the camera at the end of the
            % frame

            camera.xyz(2) = camera.xyz(2) + camera.vCurrent/scrn.frameRate;             % Move the position of the camera
            camera.fixPoint(2) = camera.fixPoint(2) + camera.vCurrent/scrn.frameRate;   % Move the fixation point of the camera so it doesn't spin around. It's actually pretty cool looking if you want to have a look disable this line.
            
            if keys.overTCounter > 0
                camera.xyz(1) = camera.xyz(1) + camera.xAccl_Flying/scrn.frameRate;

                % Making sure that the cameras position doesn't exceed the
                % set maximum
                if camera.xyz(1) > camera.maxOverTPos; camera.xyz(1) = camera.maxOverTPos; end

            else
                % Do nothing
            end
        end

        function camera = resetStartPosition(camera)
            % RESETSTARTPOSITION reset the position of the camera to the
            % start of the trial
            
            camera.xyz          = camera.startxyz;
            camera.fixPoint     = camera.startFixPnt;

        end

        function xyz = getDriverPosition(camera, car, road)
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
            xyz(1) = (-1) * (road.laneWidth - road.laneWidth*camera.lanePosRatio + car.width*0.5*camera.driverPosRatio);
            
            % y position is just whatever I set it to be, likely -1
            xyz(2) = -1;
            
            % z position will be the height of the driver
            xyz(3) = camera.driverZ;
        end
    end
end