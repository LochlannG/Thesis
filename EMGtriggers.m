classdef EMGtriggers
    properties
        ioObj
        address
    end
    methods
        function emg = EMGtriggers(portAddress)
            
            emg.ioObj = io64;
            %initialize the inpoutx64 system driver
            status = io64(emg.ioObj);
            if(status ==0)
                "emg triggers ready"
            end
            emg.address = portAddress;

        end
        function triggerEMG(emg, trigger)
            io64(emg.ioObj,emg.address,trigger);
        end%output trigger

        function sendOnOffEMG(emg)
            io64(emg.ioObj,emg.address,0);
            WaitSecs(0.002)
            io64(emg.ioObj,emg.address,1);
            WaitSecs(0.002)
            io64(emg.ioObj,emg.address,0);
        end


    end
end
