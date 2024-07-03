% Load all files from given folder
% Note that the data will be generated in a subfolder called data under
% the selected folder
[folderPath, matFiles] = processMatFiles();

% YOU MAY EDIT THIS LINE TO RUN # TESTS
N = 25;

% Generate all combinations to compare all scenarios
sections = 1:4;
sectionNames = ["N1", "N2", "A1", "A2"];
sectionCombinations = nchoosek(sections, 2);
rowNames = "mouseID";
for i = 1:length(sectionCombinations)
    currentCombination = sectionCombinations(i, :);
    section1 = sectionNames(currentCombination(1));
    section2 = sectionNames(currentCombination(2));
    rowNames = [rowNames; 
        strcat("c", section1, section2); strcat("std_c", section1, section2);
        strcat(section1, section2); strcat("std_", section1, section2)];
end
disp(rowNames);

for k = 1:length(matFiles)
    % Get the full file path
    filePath = fullfile(folderPath, matFiles(k).name);
    createFolder(strcat(folderPath, "/data"));
    createCsvIfNotExist( ...
        strcat(folderPath, "/data/", "svm_analysis_reverse_eng", ".csv"), ...
        rowNames);

    % Load the .mat file
    data = load(filePath);
    % Define dataset mouse ID
    fileLabel = regexp(matFiles(k).name, '\d*', 'Match'); fileLabel = fileLabel{1};

    % Display the name of the file being processed
    fprintf('Processing file: %s\n', matFiles(k).name);

    % Process the loaded data (this is where you can add your custom processing code)
    % For example, let's just display the variables in the .mat file
    disp('Variables in the file:');
    disp(fieldnames(data));

    disp('Applying Gaussian Filtering to dataset')
    neuronalTraces = gaussFilt(data.NeuAll, 0, 2);

    disp('Creating all experiment sections')
    mouseN1 = MouseClass(data.frameSec1Start, data.frameSec1End);
    mouseN2 = MouseClass(data.frameSec2Start, data.frameSec2End);
    mouseA1 = MouseClass(data.frameSec1Start, data.frameSec1End);
    mouseA2 = MouseClass(data.frameSec2Start, data.frameSec2End);

    disp('Defining all bouts on each sections')
    neuronalResponsesN1 = Neuro_Responces( ...
        neuronalTraces(:, mouseN1.startFrame:mouseN1.endFrame), ...
        data.BehavMouseN(mouseN1.startFrame:mouseN1.endFrame));
    neuronalResponsesN2 = Neuro_Responces( ...
        neuronalTraces(:, mouseN2.startFrame:mouseN2.endFrame), ...
        data.BehavMouseN(mouseN2.startFrame:mouseN2.endFrame));
    neuronalResponsesA1 = Neuro_Responces( ...
        neuronalTraces(:, mouseA1.startFrame:mouseA1.endFrame), ...
        data.BehavMouseA(mouseA1.startFrame:mouseA1.endFrame));
    neuronalResponsesA2 = Neuro_Responces( ...
        neuronalTraces(:, mouseA1.startFrame:mouseA2.endFrame), ...
        data.BehavMouseA(mouseA2.startFrame:mouseA2.endFrame));
    ids = 1:4;
    names = {neuronalResponsesN1 neuronalResponsesN2 neuronalResponsesA1 neuronalResponsesA2};
    neuronalSections = containers.Map(ids, names);
    svmData = [];
    for i = 1:length(sectionCombinations)
        currentCombination = sectionCombinations(i, :);
        section1 = currentCombination(1);
        section2 = currentCombination(2);
    
        disp("Processing " + sectionNames(section1) + sectionNames(section2));
        svmResult = decodeSVM(neuronalSections(section1), ...
            neuronalSections(section2), N);
        svmData = [svmData; svmResult];
    end
    disp(svmData);
    appendRowToCsv(strcat(folderPath, "/data/", "svm_analysis_reverse_eng", ".csv"), ...
            svmData, fileLabel);
end
%% Appendix - Helper Functions
function [folderPath, matFiles] = processMatFiles()
    % Function to allow user to choose a folder and loop through all .mat files

    % Let the user choose the folder
    folderPath = uigetdir;

    % Check if the user canceled the folder selection
    if folderPath == 0
        disp('Folder selection canceled. Exiting.');
        return;
    end

    % Get a list of all .mat files in the chosen folder
    matFiles = dir(fullfile(folderPath, '*.mat'));
end

function svmData = decodeSVM(trace1, trace2, numTests)
    X = [trace1; trace2];
    Y = [ones(size(trace1, 1), 1); zeros(size(trace2, 1), 1)];
    accuracyControl = zeros(1, numTests);
    for i = 1:numTests
        accuracyControl(i) = Linear_decoding(X, Y);
    end
    accuracyShuffle = zeros(1, numTests);
    for i = 1:numTests
        Y = Y(randperm(length(Y)));
        accuracyShuffle(i) = Linear_decoding(X, Y);
    end
    y = [mean(accuracyControl), mean(accuracyShuffle)]; 
    err = [std(accuracyControl), std(accuracyShuffle)]/sqrt(numTests);
    svmData = zeros(1, length(y) + length(err));
    svmData(1:2:end) = y;
    svmData(2:2:end) = err;
end

function createFolder(folderPath)
    % Check if the folder exists
    if ~exist(folderPath, 'dir')
        % If the folder does not exist, create it
        mkdir(folderPath);
        fprintf('Folder created: %s\n', folderPath);
    else
        fprintf('Folder already exists: %s\n', folderPath);
    end
end

function createCsvIfNotExist(csvFileName, columnNames)
    if exist(csvFileName, 'file') ~= 2
        fid = fopen(csvFileName, 'w');
        for i = 1:length(columnNames) - 1
            fprintf(fid, '%s,', columnNames{i});
        end
        fprintf(fid, '%s\n', columnNames{end});
        fclose(fid);
    end
end

function appendRowToCsv(csvFileName, rowData, mouseID)
    fid = fopen(csvFileName, 'a');
    fprintf(fid, '%s, ', mouseID);
    for i = 1:length(rowData)
        for j = 1:length(rowData(i, :))
            value = rowData(i, j);
            if value > 0
                fprintf(fid, '%s, ', rowData(i, j));
            else
                fprintf(fid, '%s, ', "0");
            end
        end
    end
    fprintf(fid, '\n');
    fclose(fid);
end
