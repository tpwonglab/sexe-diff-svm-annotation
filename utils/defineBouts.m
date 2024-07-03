function [labels, sections] = defineBouts(behaviour)
    labels = [];
    sections = [];
    startPointer = 1;
    isPrevTouch = behaviour(1);
    for i = 2:length(behaviour)
        isTouch = behaviour(i);
        if isTouch ~= isPrevTouch
            sections = [sections; [startPointer, i - 1]];
            labels = [labels, isPrevTouch];
            startPointer = i;
            if i == length(behaviour)
                sections = [sections; [i, i]];
                labels = [labels, isTouch];
                return
            end
        elseif i == length(behaviour)
            sections = [sections; [startPointer, i]];
            labels = [labels, isTouch];
        end
        isPrevTouch = isTouch;
    end
end