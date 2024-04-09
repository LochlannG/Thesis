function loop = setupLoop(scrn)
    
    % Main structure
    loop = struct();

%     % Variable to keep track of different values throughout the trials
%     loop.time = {};
%     loop.bikeY = {};
%     loop.carV ={};
%     loop.road = {};
%     loop.carY ={};
%     loop.car2Y = {};
%     loop.subjectX = {};
        
    loop.nFramShown = 2*scrn.frameRate;                 % stimulus will disappear if it has been in front for more than 2 seconds
    
    % Flags and counters
    loop.escapeFlag = false;
    loop.currentTrial = 1;
    
end