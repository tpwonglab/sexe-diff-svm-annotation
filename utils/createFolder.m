function folderPath = createFolder()
    folderPath = uigetdir;
    if folderPath == 0
        error('Folder selection canceled.');
    end
    % Check if the folder exists
    if ~exist(folderPath, 'dir')
        % If the folder does not exist, create it
        mkdir(folderPath);
        fprintf('Folder created: %s\n', folderPath);
    else
        fprintf('Folder already exists: %s\n', folderPath);
    end
end