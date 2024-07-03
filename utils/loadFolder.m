function matFiles = loadFolder()
    folderPath = uigetdir;
    if folderPath == 0
        error('Folder selection canceled.');
        quit;
    end
    matFiles = dir(fullfile(folderPath, '*.mat'));
    disp("Loaded Folder: " + folderPath);
end