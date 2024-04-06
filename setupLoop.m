function loop = setupLoop()
    
    % Main structure
    loop = struct();

    % Variable to keep track of different values throughout the trials
    loop.time = {};
    loop.bikeY = {};
    loop.carV ={};
    loop.road = {};
    loop.carY ={};
    loop.car2Y = {};
    loop.subjectX = {};
    
    % Flags and counters
    loop.escapeFlag = false;
    loop.currentTrial = 1;
    
end