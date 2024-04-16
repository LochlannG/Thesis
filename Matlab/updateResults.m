function results = updateResults(results, loop)
    % Updates the result fields
    results.time{loop.currentTrial}             = loop.timeStore;           % Records the frame times
    results.road{loop.currentTrial}             = loop.roadStore;           % Records the road left at each frame
    results.bikeY{loop.currentTrial}            = loop.bikeYStore;          % Records the y position of the bikes
    results.towardsCarY{loop.currentTrial}      = loop.towardsCarYStore;    % Records the y position of the oncoming cars
    results.withCarY{loop.currentTrial}         = loop.withCarYStore;       % Records the y position of the cars in the lane
    results.cameraX{loop.currentTrial}          = loop.cameraXStore;        % Records the x position of the camera
    results.cameraV{loop.currentTrial}          = loop.cameraVStore;        % Records the speed of the camera
    results.whatFirst{loop.currentTrial}        = loop.whichTypeStore;      % Records what type of object is first in your lane
    results.whchFirst{loop.currentTrial}        = loop.whichInstanceStore;  % Records which instance of that object is first in your lane
    results.gap{loop.currentTrial}              = loop.gapStore;            % Records the gaps in the right lane
end