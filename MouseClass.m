classdef MouseClass
    properties
        startFrame
        endFrame
    end
    methods
        function obj = MouseClass(val1, val2)
            if nargin > 0
                obj.startFrame = val1;
                obj.endFrame = val2;
            end
        end
    end
end