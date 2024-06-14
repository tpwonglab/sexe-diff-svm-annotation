[folderPath, matFiles] = processMatFiles();

for file = 1:1%length(matFiles)
    filePath = fullfile(folderPath, matFiles(file).name);
    data = load(filePath);
    disp(matFiles(file).name);

    neuronalTraces = gaussFilt(data.NeuAll, 0, 2);
    avgTraces = defineNeuroResponse(neuronalTraces, data.BehaveMouseN);

    
end

function avgTraces = defineNeuroResponse(traces, behaviour)
    disp(behaviour);
end

function [folderPath, matFiles] = processMatFiles()
    folderPath = uigetdir;
    if folderPath == 0
        disp('Folder selection canceled. Exiting.');
        return;
    end
    matFiles = dir(fullfile(folderPath, '*.mat'));
end