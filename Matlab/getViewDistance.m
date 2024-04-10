function yposition = getViewDistance(sampFreq, testLengthM, type, params)

    sampleFactorOffset = 20;

    % converting to local variables
    lowerLimit = params.limits(1);
    upperLimit = params.limits(2);

    if type == "osc"

        trial_time = 0:1/sampFreq:testLengthM*sampleFactorOffset/sampFreq;      % offset the number of samples by a factor of 20 to be sure there are sufficient

        % creating sins to sum
        maxfreq = params.maxSinF*2*pi; %rad/s
        maxamp = upperLimit - lowerLimit; %m
        
        for i = 1:params.nWaves
            sinwaves(i, :) = maxamp*rand*sin((maxfreq*rand)*trial_time);
        end
        
        yposition = sum(sinwaves, 1);

    elseif type == "WN"
            
        % Noise limits multiplied by a factor of ten to correct for the
        % limit reduction due to the filtering regime.
        lowerLimit = lowerLimit*10; upperLimit = upperLimit*10;
        noise = (lowerLimit + rand(1, testLengthM*sampleFactorOffset))*(upperLimit - lowerLimit); %rand(1, testLengthM*sampleFactorOffset);
        lowpassed = lowpass(noise, 0.005);
        smoothed = movmean(lowpassed, params.avK);
        yposition = smoothed - min(smoothed);
            
    end

end