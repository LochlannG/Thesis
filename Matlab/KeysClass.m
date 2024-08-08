classdef KeysClass
    %KEYSCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % Keys values
        escape      % Escape
        enter       % Enter
        lt          % Left
        rt          % Right
        dw          % Down
        up          % Up

        code        % Stores what keys have been pressed in the last frame

        breakFlag   % Break out of the trial loop
        escapeFlag  % Escape button pressed
        setOvertake % Set the thing to overtake


    end
    
    methods
        function keys = KeysClass()
            keys.escape = KbName('ESCAPE');
            keys.enter  = KbName('return');
            keys.lt = KbName('LeftArrow');
            keys.rt = KbName('RightArrow');
            keys.dw = KbName('DownArrow');
            keys.up = KbName('UpArrow');
        end

        function keys = getKey(keys, whichKeys)
           
            [~, ~, keys.code] = KbCheck;    %Checks the keys that are down
            keys.breakFlag = false;         % Will close the loop if returned true, defaults to false
            keyBinary = zeros(1, 6);        % Opens an all zero array to record which keys
            
            % Escape
            if all(keys.code(keys.escape)) && whichKeys(1) == 1
                keyBinary(1) = 1;
                keys.escapeFlag = true;
                keys.breakFlag = true;
            end

            % Enter
            if all(keys.code(keys.enter)) && whichKeys(2) == 1
                keyBinary(2) = 1;
                keys.breakFlag = true;
            end

            % Up
            if all(keys.code(keys.up)) && whichKeys(3) == 1
                keyBinary(3) = 1;
            end

            % Down
            if all(keys.code(keys.dw)) && whichKeys(4) == 1
                keyBinary(4) = 1;
            end

            % Left
            if all(keys.code(keys.lt)) && whichKeys(5) == 1
                keyBinary(5) = 1;
                keys.setOvertake = false;
            end
            
            % Right
            if all(keys.code(keys.rt)) && whichKeys(6) == 1
                keyBinary(6) = 1;
            end
            
            % Record which keys were pressed
%             loop.keysPressed = keyBinary;
        end

    end
end

