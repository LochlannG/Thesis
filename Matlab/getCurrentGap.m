function [actualGap, percievedGap] = getCurrentGap(towardsCar, noise)
% [actualGap, percievedGap] = getCurrentGap(towardsCar, noise)
% Calculates the size of the 'gap', or the avialable space in the
% overtaking lane
%
% Inputs:
% towardsCar        -   Structure holding details of the towardsCar object
% noise             -   Structure holding details of the noise object
%
% Outputs:
% actualGap         -   The 'actual' gap at this frame, the distance between the camera and the first oncoming car
% percievedGap      -   What the subject is actual capable of seeing
%
% Author - Lochlann Gallagher
% Changelog (I'm not very good at maintaining this):
% 1.0 - Created function 
    
    % Get what the actual physical gap is 
    actualGap = min(towardsCar.y(towardsCar.y>0));

    % Get what the percieved gap is
    if noise.yNoise >= actualGap
        % if you can see as far as the car is away
        percievedGap = actualGap;
    else
        % if the car is further away than you can see, set it how far you can see
        percievedGap = noise.yNoise;
    end

    if isempty(actualGap)
        % catches where there are no more objects cases
        actualGap = 2000;
    end
end