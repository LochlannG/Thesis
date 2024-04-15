function loop = setupLoop(scrn)
    
    % Main structure
    loop = struct();
        
    loop.nFramShown = 2*scrn.frameRate;                 % stimulus will disappear if it has been in front for more than 2 seconds
    
    % Flags and counters
    loop.escapeFlag = false;
    loop.currentTrial = 1;
    
end