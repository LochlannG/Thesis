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
                disp("emg triggers ready")
            end
            emg.address = portAddress;

        end
        
        function onMarker(emg)
            io64(emg.ioObj,emg.address,1);
        end
        
        function offMarker(emg)
            io64(emg.ioObj,emg.address,0);
        end
        
        function smlTaskMarker(emg)
            io64(emg.ioObj,emg.address,0);
            WaitSecs(0.01)
            io64(emg.ioObj,emg.address,1);
            WaitSecs(0.01)
            io64(emg.ioObj,emg.address,0);
        end

        function bigTaskMarker(emg)
            io64(emg.ioObj,emg.address,0);
            WaitSecs(0.1)
            io64(emg.ioObj,emg.address,1);
            WaitSecs(0.1)
            io64(emg.ioObj,emg.address,0);
            WaitSecs(0.1)
            io64(emg.ioObj,emg.address,1);
            WaitSecs(0.1)
            io64(emg.ioObj,emg.address,0);
        end


    end
end
