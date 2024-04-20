classdef LoopClass
    % Class handling the variables and methods that are needed within a single trial
    % 
    
    properties
        % Counters
        nFramShown                                      % 
        nFramesSlowing                                  %
        currentTrial                                    % What the current trial is
        currentFrame                                    % What the current frame is
        roadLeft
        speedUpLeft
        lengthShown
        
        % Timers
        eventOverTimer                                  % Timer counting down from when an event finishes
        allowResponseTimer                              % Timer counting down from when an event finishes until a response allowed
        endResponseTimer                                % Timer counting down from when a response is allowed until it isn't
        overtakeTimer                                   % Timer counting down from when an event finishes
        

        % Flags
        escapeFlag
        overtakeFlag
        overtakeOngoingFlag
        skipPlot
        stopResponse
        eventOverFlag
        oneVis
        breakFlag
        hitMinSpeedFlag
        firstDisplay
        slowingDownFlag

        % Variables
        cameraVCurrent
        whichType
        whichInstance
        bikeStep
        oncomingCarStep
        inFlowCarStep
        bikeYCurrent
        withCarYCurrent
        towardsCarYCurrent
        gap
        overtakeSpeed
        yNoise
        overtakeCurrent
        keysPressed

        % Semi Constants
        cameraStartX
        speedUpMaxFrames

        % Storage
        whichTypeStore
        whichInstanceStore
        gapStore
        timeStore
        bikeYStore
        cameraVStore
        roadStore
        towardsCarYStore
        withCarYStore
        cameraXStore
        yNoiseStore
        overtakeStore
        keysStore
        
    end
    properties (Constant)
        
    end
    methods
        function loop = LoopClass(scrn)
            
            % Flags and counters
            loop.escapeFlag         = false;
            loop.currentTrial       = 1;

        end

        function [loop, speedo] = resetLoopVars(loop, camera, test, scrn, speedo)

            % Counters
            loop.currentFrame       = 1;
            loop.eventOverTimer     = -1;
            loop.firstDisplay       = 1;
            loop.roadLeft           = test.lengthM;
            loop.speedUpLeft        = loop.speedUpMaxFrames;
            loop.nFramShown         = 0;
            loop.nFramesSlowing     = 0;
            loop.lengthShown        = 0;

            % Flags
            loop.overtakeFlag      	= false;
            loop.skipPlot           = false;
            loop.hitMinSpeedFlag    = false;
            loop.stopResponse       = true;
            loop.overtakeOngoingFlag    = false;

            % Variables
            loop.cameraVCurrent     = camera.startSpeed;
            loop.whichType = 0;
            loop.whichInstance = 0;

            % Constants
            loop.cameraStartX       = camera.xyz(1);
            loop.speedUpMaxFrames   = round(scrn.frameRate*2, 0);     % You're allowed speed up for 2 seconds following a stimulus

            % Storage
            loop.whichTypeStore     = [];
            loop.whichInstanceStore = [];
            loop.gapStore           = [];
            loop.timeStore          = [];
            loop.bikeYStore         = [];
            loop.cameraVStore       = [];
            loop.roadStore          = [];
            loop.towardsCarYStore   = [];
            loop.withCarYStore      = [];
            loop.cameraXStore       = [];
            loop.yNoiseStore        = [];
            
            % Change other object values
            speedo = speedo.relock(loop);
            
        end

        function loop = updateStorage(loop)
            loop.whichTypeStore     = [loop.whichTypeStore,     loop.whichType];
            loop.whichInstanceStore = [loop.whichInstanceStore, loop.whichInstance];
            loop.gapStore           = [loop.gapStore,           loop.gap];
            loop.cameraVStore       = [loop.cameraVStore,       loop.cameraVCurrent];
            loop.bikeYStore         = [loop.bikeYStore,         loop.bikeYCurrent];
            loop.withCarYStore      = [loop.withCarYStore,      loop.withCarYCurrent];
            loop.towardsCarYStore   = [loop.towardsCarYStore,   loop.towardsCarYCurrent];
            loop.roadStore          = [loop.roadStore,          loop.roadLeft];
            loop.yNoiseStore        = [loop.yNoiseStore,        loop.yNoise];
            loop.overtakeStore      = [loop.overtakeStore,      loop.overtakeCurrent];
            loop.keysStore          = [loop.keysStore,          loop.keysPressed'];
            
        end

        function loop = updateSpeed(loop, scrn, cyclist, towardsCar, withCar)
            loop.roadLeft           = loop.roadLeft - loop.cameraVCurrent*(1/scrn.frameRate);      	% Update the amount of "road" left with the camera's "relative" speed (it's a static image)
            loop.bikeStep           = (loop.cameraVCurrent - cyclist.speed)/scrn.frameRate;       	% The distance a bike will move in a frame
            loop.oncomingCarStep    = (towardsCar.speed + loop.cameraVCurrent)/scrn.frameRate;   	% The distance a car in the other lane will move in a frame
            loop.inFlowCarStep      = (loop.cameraVCurrent - withCar.speed)/scrn.frameRate;     	% The distance a car in the camera lane will move in a frame

        end
        
        function loop = restartTimers(loop, scrn, noise)
            howLongToWait           = 0.5;                                                          % How long after an event has passed to change the horizon
            loop.eventOverTimer     = howLongToWait*scrn.frameRate;                                 % That value converted to a number of frames
            loop.allowResponseTimer = loop.eventOverTimer + noise.maxIter;                          % How long after the event to allow the speed to be changed
            loop.endResponseTimer   = loop.allowResponseTimer + 2*scrn.frameRate;                   % How long after that to stop allowing the speed to be changed
            
        end
        
        function loop = resetTopFrameFlags(loop)
            loop.eventOverFlag      = false;
            
        end
        
        function loop = endOfFrameWrapUp(loop, toc, noise)
            % Changes some values at the end of a frame that are used to
            % track times during the trials
            
            % Reduce the timers by 1
            loop.eventOverTimer     = loop.eventOverTimer       - 1;
            loop.allowResponseTimer = loop.allowResponseTimer   - 1;
            loop.endResponseTimer   = loop.endResponseTimer     - 1;
            loop.overtakeTimer      = loop.overtakeTimer        - 1;
            
            % Other trackers
            loop.currentFrame       = loop.currentFrame + 1;                                        % The tracker of current frame
            loop.timeStore          = [loop.timeStore toc];                                         % Update the time tracking values
            loop.yNoise             = noise.yNoise;
            
            if loop.overtakeFlag
               loop.overtakeCurrent = 1;
            else
                loop.overtakeCurrent = 0;
            end
        
        end
        
        function [l, n, w, s, c] = getUserResponse(loop, noise, withCar, speedo, cyclist, keys, camera, test, scrn, emg)
            % Handle user response within a given frame
            
            % So I can return them without throwing errors
            l   = loop;
            n   = noise;
            w   = withCar;
            s   = speedo;
            c   = cyclist;
            
            % Statements to handle when to change things
            if l.eventOverTimer == 0 % Handles when an event has occured
                % Step 1 - Change noise level
                l.firstDisplay  = false;
%                 l.overtakeFlag  = false;
                currentNoise    = n.yNoise;
                n.yNoise        = getDiscreteViewDist(n.levels);

                n.vector        = linspace(currentNoise, n.yNoise, n.maxIter);
                n.iteration     = 1;
                
                % Update the areas where the cyclist & with car are allowed disappear
                c               = c.setEndingVals(n.yNoise);
                w.potentialEnd  = n.yNoise;

            elseif l.allowResponseTimer == 0

                % Step 2 - Turn Speedometer Green & allow a response
                s               = s.unlock(l);
                l.stopResponse  = false;
                
            elseif l.endResponseTimer == 0
                s               = s.relock(l);
                l.stopResponse  = true;
            end
            
            % Get the users key input
            l = getKeyMakeChange(l, s, cyclist, keys, test, camera, scrn, [1, 0, 1, 1, 0, 1], emg);

            
        end
        
        function loop = setEventOver(loop)
           loop.eventOverFlag = true;
           loop.hitMinSpeedFlag = false;
        end
        
        function loop = startOvertake(loop, scrn)
            loop.overtakeFlag           = true;
            loop.overtakeTimer          = scrn.frameRate*3;
            loop.overtakeSpeed          = loop.cameraVCurrent;
            loop.overtakeOngoingFlag    = true;
        end

        function [loop, camera] = overtakeHandling(loop, camera, scrn)
            if ~loop.overtakeFlag % This is default setting if not overtaking

                camera.xyz(1) = loop.cameraStartX;
                gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));
                loop.cameraXStore = [loop.cameraXStore, camera.xyz(1)];    % Stores the x position of the camera
                
            elseif loop.overtakeFlag % This is the special case where the camera is overtaking

                if loop.overtakeTimer > scrn.frameRate*1
                    % Speed up the car
                    camera.xyz(1) = loop.cameraStartX + camera.overtakeWidth;
                    loop.cameraVCurrent = loop.cameraVCurrent + camera.continuousAcceleration*2*(1/scrn.frameRate);
                    if loop.cameraVCurrent >= camera.maxSpeed
                        loop.cameraVCurrent = camera.maxSpeed;
                    end
                elseif loop.overtakeTimer > 0        
                    camera.xyz(1) = loop.cameraStartX;
                    loop.cameraVCurrent = loop.cameraVCurrent - camera.continuousAcceleration*4*(1/scrn.frameRate);
                    if loop.cameraVCurrent <= loop.overtakeSpeed
                        loop.cameraVCurrent =  loop.overtakeSpeed;
                    end

                elseif loop.overtakeTimer == 0
                    camera.xyz(1)               = loop.cameraStartX;
                    loop.overtakeFlag           = false;
                    loop.overtakeOngoingFlag    = false;
                end
                
                loop.cameraXStore = [loop.cameraXStore, camera.xyz(1)];  % Stores the x position of the camera
                gluLookAt(camera.xyz(1), camera.xyz(2), camera.xyz(3), camera.fixPoint(1), camera.fixPoint(2), camera.fixPoint(3), camera.upVec(1), camera.upVec(2), camera.upVec(3));

            end
        end
        
        function loop = startSlowDown(loop)
            loop.slowingDownFlag = true;
        end
        
        function loop = slowDown(loop, cyclist, speedo, camera, scrn, emg)
            
            if loop.nFramesSlowing == 0
                loop.nFramesSlowing = 1;
                if emg ~= 0
                    emg.onMarker();
                end
            end


            % Defining a minimum value for speed, I love getting a chance
            % to use switch - case statements they are very fancy
            if any(strcmp(fieldnames(loop), 'whichType'))
                switch loop.whichType
                    case 1
                         minSpeed = cyclist.speed(loop.whichInstance(1));
                    otherwise
                        minSpeed = min(cyclist.speed);
                end
            else
                minSpeed = min(cyclist.speed);
            end

            if speedo.unlocked % if an event has passed

                loop.cameraVCurrent = loop.cameraVCurrent - camera.discreteAcceleration;

            elseif loop.oneVis      % if something isn't visible you can't slow down

                % When the trial screen is in place
                loop.cameraVCurrent = loop.cameraVCurrent - (loop.nFramesSlowing)*camera.slopeOfAccFun*(1/scrn.frameRate);
                loop.nFramesSlowing = loop.nFramesSlowing + 1;

            elseif ~loop.oneVis
                loop.nFramesSlowing = 0;
                loop.slowingDownFlag = false;
                loop.lengthShown = 0;
            end

            if loop.cameraVCurrent <= minSpeed
                loop.hitMinSpeedFlag = true;
                loop.cameraVCurrent = minSpeed;
                loop.slowingDownFlag = false;
                loop.nFramesSlowing = 0;
                loop.lengthShown = 0;

            end

            if loop.cameraVCurrent <= 0
                loop.cameraVCurrent = 0;
            end

        end
        
    end
    
end