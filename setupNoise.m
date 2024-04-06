function noise = setupNoise()
    noise.limits = [0, 50];                                      % range limits for the generation of noise (caution: don't use negative values)
    noise.nWaves = 5;
    noise.noiseAmp = 20;
    noise.avK = 200;
    noise.maxSinF = 0.5;
    noise.minViewDistance = 20;
    noise.levels = [noise.minViewDistance, noise.minViewDistance*2, noise.minViewDistance*4];
end