function [data, fileLabel] = loadData(fileName, filePath)
    data = load(fullfile(filePath, fileName));
    fileLabel = split(fileName, "."); fileLabel = fileLabel{1};
    fileLabel = regexp(fileLabel, '\d*', 'Match'); fileLabel = fileLabel{1};
    disp("Loaded Data: " + fileLabel);
end