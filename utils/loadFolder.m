function [folderPath, matFiles] = loadFolder()
    folderPath = uigetdir;
    if folderPath == 0
        error('Folder selection canceled.');
    end
    matFiles = dir(fullfile(folderPath, '*.mat'));
    disp("Loaded Folder: " + folderPath);
end