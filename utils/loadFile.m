function [fileName, filePath, fileLabel] = loadFile()
    [fileName, filePath] = uigetfile('*.mat');
    if filePath == 0
        error('File selection canceled.');
    end
    fileLabel = split(fileName, "."); fileLabel = fileLabel{1};
    fileLabel = regexp(fileLabel, '\d*', 'Match'); fileLabel = fileLabel{1};
    disp("Loaded File: " + fileName);
end