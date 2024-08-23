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

        code        % Stores what keys have been pressed in the last frame (1x256 array)
        oldBinary   % Records every relevent key pressed in the last frame in a (1x6 array)
        nowBinary   % Records every relevent key pressed in this frame in a (1x6 array)

        breakFlag   % Break out of the trial loop
        escapeFlag  % Escape button pressed
        setOvertake % Set the thing to overtake

        counter     % How many frames the right button has been pressed down


    end
    
    methods
        function keys = KeysClass()
            keys.escape     = KbName('ESCAPE');
            keys.enter      = KbName('return');
            keys.lt         = KbName('LeftArrow');
            keys.rt         = KbName('RightArrow');
            keys.dw         = KbName('DownArrow');
            keys.up         = KbName('UpArrow');

            keys.oldBinary  = zeros(1, 6);
            keys.counter    = zeros(1, 6);
        end

        function keys = getKey(keys, whichKeys)
           
            [~, ~, keys.code]       = KbCheck;    % Checks the keys that are down
            keys.breakFlag          = false;         % Will close the loop if returned true, defaults to false
            keys.nowBinary          = zeros(1, 6);   % Opens an all zero array to record which keys
            
            % Escape
            if all(keys.code(keys.escape)) && whichKeys(1) == 1
                keys.nowBinary(1)   = 1;
                keys.escapeFlag     = true;
                keys.breakFlag      = true;
            end

            % Enter
            if all(keys.code(keys.enter)) && whichKeys(2) == 1
                keys.nowBinary(2)   = 1;
                keys.breakFlag      = true;
            end

            % Up
            if all(keys.code(keys.up)) && whichKeys(3) == 1
                keys.nowBinary(3)   = 1;
                if keys.oldBinary(3) == 0; keys.counter(3) = 0; else; keys.counter(3) = keys.counter(3) + 1; end
            end

            % Down
            if all(keys.code(keys.dw)) && whichKeys(4) == 1
                keys.nowBinary(4)   = 1;
                if keys.oldBinary(4) == 0; keys.counter(4) = 0; else; keys.counter(4) = keys.counter(4) + 1; end
            end

            % Left
            if all(keys.code(keys.lt)) && whichKeys(5) == 1
                keys.nowBinary(5)   = 1;
                if keys.oldBinary(5) == 0; keys.counter(5) = 0; else; keys.counter(5) = keys.counter(5) + 1; end
            end
            
            % Right
            if all(keys.code(keys.rt)) && whichKeys(6) == 1
                keys.nowBinary(6)   = 1;
                if keys.oldBinary(6) == 0; keys.counter(6) = 0; else; keys.counter(6) = keys.counter(6) + 1; end
            end

            % This is just an error checker to be sure that the overtaking
            % thing doesn't keep going when the button hasn't been pressed.
            for i = 1:6
                if keys.oldBinary(i) == 0 && keys.nowBinary(i) == 0
                    keys.counter(i) = 0;
                end
            end

            % Record which keys were pressed
            keys.oldBinary = keys.nowBinary;
        end

    end
end

