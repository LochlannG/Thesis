classdef LoopClass
    properties
        % Counters
        nFramShown
        nFramesSlowing
        currentTrial
        currentFrame
        eventOverTimer
        allowResponseTimer
        endResponseTimer
        
        roadLeft
        speedUpLeft

        % Flags
        escapeFlag
        setOvertake
        skipPlot
        hitMinSpeed
        stopResponse
        eventOverFlag
        oneVis
        breakFlag
        hitMinSpeedFlag
        firstDisplay

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
        
    end
    properties (Constant)
        
    end
    methods
        function loop = LoopClass(scrn)
            loop.nFramShown = 2*scrn.frameRate;                 % stimulus will disappear if it has been in front for more than 2 seconds
    
            % Flags and counters
            loop.escapeFlag = false;
            loop.currentTrial = 1;

        end

        function loop = resetLoopVars(loop, camera, test, scrn)

            % Counters
            loop.currentFrame       = 1;
            loop.eventOverTimer     = -1;
            loop.firstDisplay       = 1;
            loop.roadLeft           = test.lengthM;
            loop.speedUpLeft        = loop.speedUpMaxFrames;
            loop.nFramShown         = 0;

            % Flags
            loop.setOvertake        = false;
            loop.skipPlot           = false;
            loop.hitMinSpeed        = false;
            loop.stopResponse       = true;

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
            
        end

        function loop = updateSpeed(loop, scrn, cyclist, towardsCar, withCar)
            loop.roadLeft           = loop.roadLeft - loop.cameraVCurrent*(1/scrn.frameRate);                               % Update the amount of "road" left with the camera's "relative" speed (it's a static image)
            loop.bikeStep           = (loop.cameraVCurrent - cyclist.speed)/scrn.frameRate;                                 % The distance a bike will move in a frame
            loop.oncomingCarStep    = (towardsCar.speed + loop.cameraVCurrent)/scrn.frameRate;                      % The distance a car in the other lane will move in a frame
            loop.inFlowCarStep      = (loop.cameraVCurrent - withCar.speed)/scrn.frameRate;                                 % The distance a car in the camera lane will move in a frame

        end
        
        function loop = restartTimers(loop, scrn, noise)
            howLongToWait           = 0.5;                                          % How long after an event has passed to change the horizon
            loop.eventOverTimer     = howLongToWait*scrn.frameRate;                 % That value converted to a number of frames
            loop.allowResponseTimer = loop.eventOverTimer + noise.maxIter;          % How long after the event to allow the speed to be changed
            loop.endResponseTimer   = loop.allowResponseTimer + 2*scrn.frameRate;   % How long after that to stop allowing the speed to be changed
            
        end
        
        function loop = resetTopFrameFlags(loop)
            loop.eventOverFlag = false;
            
        end
        
        function loop = endOfFrameWrapUp(loop, toc)
            loop.eventOverTimer     = loop.eventOverTimer       - 1;
            loop.allowResponseTimer = loop.allowResponseTimer   - 1;
            loop.endResponseTimer   = loop.endResponseTimer     - 1;
            loop.currentFrame       = loop.currentFrame + 1;                        % The tracker of current frame
            loop.timeStore          = [loop.timeStore toc];                         % Update the time tracking values
        
        end
        
        function [l, n, w, s, c] = getUserResponse(loop, noise, withCar, speedo, cyclist, keys, camera, test, scrn, emg)
            
            % So I can return them without throwing errors
            l   = loop;
            n   = noise;
            w   = withCar;
            s   = speedo;
            c   = cyclist;
            
            % Statements to handle when to change things
            if l.eventOverTimer == 0 % Handles when an event has occured
                % Step 1 - Change noise level
                l.firstDisplay = false;
                l.setOvertake = false;
                currentNoise = n.yNoise;
                n.yNoise = getDiscreteViewDist(n.levels);

                n.vector = linspace(currentNoise, n.yNoise, n.maxIter);
                n.iteration = 1;
                
                % Update the areas where the cyclist & with car are allowed disappear
                c = c.setEndingVals(n.yNoise);
                w.potentialEnd = n.yNoise;

            elseif l.allowResponseTimer == 0

                % Step 2 - Turn Speedometer Green & allow a response
                s = s.unlock();
                l.stopResponse = false;
                
            elseif l.endResponseTimer == 0
                l.stopResponse = true;
                s = s.relock();
            end
            
            % Get the users key input
            l = getKeyMakeChange(l, s, cyclist, keys, test, camera, scrn, [1, 0, 1, 1, 0, 1], emg);

            
        end
        
    end
    
end