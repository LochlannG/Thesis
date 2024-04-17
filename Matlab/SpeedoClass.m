classdef SpeedoClass
    properties
        height
        width
        xyz
        
        % Flags
        unlocked

        % OpenGL values
        vertexCoords
        vertexColors
        elementArray
        
        rotationAxis
        rotationAngle

    end
    properties (Constant)
        distance    = 2;
        normal      = [0, 0, 1];

    end
    methods
        function speedo = SpeedoClass(givenHeight, givenWidth)
            speedo.height = givenHeight;
            speedo.width  = givenWidth;

        end

        function speedo = getVertexes(speedo, rgb)
            speedo = getShapeVertexes(speedo, speedo.width, speedo.height, 0, rgb, "Square");
        
        end
        
        function drawSpeedometer(speedo, loop, needle, marker, camera)
            % Draws speedometer box, needle and marker at the top of the
            % screen (ish) it tries to handle vectors weirdly
            
            % Define local variables
            upOffset = 1;
            speedRatio = loop.cameraVCurrent/camera.maxSpeed;
        
            % Get the vectors of the 
            [camera.vector, speedo.xyz, needle.xyz, marker.xyz] = speedo.handleSpeedoVectors(camera);
            camera.vector(2) = camera.vector(2) + upOffset;
            
            % Offset them up
            speedo.xyz(3) = speedo.xyz(3) + upOffset + speedo.height;
            needle.xyz(3) = needle.xyz(3) + upOffset + speedo.height/2;
            marker.xyz(3) = marker.xyz(3) + upOffset + speedo.height/2 + marker.height;
        
            % Calculate angles to rotate around
            speedo.rotationAxis = cross(speedo.normal, camera.vector);
            speedo.rotationAngle = rad2deg(acos(dot(speedo.normal, camera.vector)));
            needle.rotationAxis = cross(needle.normal, camera.vector);
            needle.rotationAngle = rad2deg(acos(dot(needle.normal, camera.vector)));
            marker.rotationAxis = cross(marker.normal, camera.vector);
            marker.rotationAngle = rad2deg(acos(dot(marker.normal, camera.vector)));
        
            % Using a 'working width' so that the needle moves within the
            % correct box
            workingWidth = speedo.width*0.75;
            needle.xyz(1) = (speedo.xyz(1) - workingWidth*0.5) + workingWidth*speedRatio;
        
            % Draw the Speedometer box
            drawOpenGLObject(speedo.xyz, speedo.rotationAxis, speedo.rotationAngle, speedo, "Square")
            
            % Draw the needle
            drawOpenGLObject(needle.xyz, needle.rotationAxis, needle.rotationAngle, needle, "Square")
        
            % Draw the markers
            drawOpenGLObject([marker.xyz(1) - workingWidth/2, marker.xyz(2), marker.xyz(3)], marker.rotationAxis, marker.rotationAngle, marker, "Square")
            drawOpenGLObject([marker.xyz(1)                 , marker.xyz(2), marker.xyz(3)], marker.rotationAxis, marker.rotationAngle, marker, "Square")
            drawOpenGLObject([marker.xyz(1) + workingWidth/2, marker.xyz(2), marker.xyz(3)], marker.rotationAxis, marker.rotationAngle, marker, "Square")
        
        end

        function speedo = unlock(speedo)
            % Turn it green
            rgb = [0, 1, 0];
            speedo.vertexColors = reshape(single(ones(4, 3).*rgb)', 1, length(single(ones(4, 3).*rgb))*3);
            speedo.unlocked = true;
        end
        
        function speedo = relock(speedo)
            % Turn it back to white
            rgb = [0, 0, 0];
            speedo.vertexColors = reshape(single(ones(4, 3).*rgb)', 1, length(single(ones(4, 3).*rgb))*3);
            speedo.unlocked = false;
        end

        function [vector, speedoPos, needlePos, markerPos] = handleSpeedoVectors(speedo, camera)
            vector = camera.fixPoint - camera.xyz;
            vector = (vector/norm(vector));

            speedoPos = vector*speedo.distance + camera.xyz;
            needlePos = speedoPos - vector*0.004;
            markerPos = speedoPos - vector*0.003;
        end
        
    end
end