function [labels, avgTraces] = defineNeuroResponse(traces, behaviour)
    [labels, sections] = defineBouts(behaviour);
    avgTraces = [];
    for i = 1:length(sections)
        avgTraces = [avgTraces; mean(traces(:, sections(i, 1):sections(i, 2)), 2)'];
    end
end