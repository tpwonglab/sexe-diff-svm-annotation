addpath("utils/");
addpath("svm/")

main();

function main
    clear main;
    clc;
    try
        choice = printInput("Choose the load data method:", ...
            ["Load a File", "Load a Folder"]);
        if choice == 1
           [fileName, filePath] = loadFile();
           [analysisChoice, N] = inputRun();
           [dataPath] = createFolder();
           dataName = input("Name data file (excluding .csv): ", "s");
           sizeShufflePerm = 1;
           numPerm = 1;
           if analysisChoice == 2
               sizeShufflePerm = input("How many permutations: ");
               numPerm = input("How many test: ");
           end
           [data, fileLabel] = loadData(fileName, filePath);
           applySVM(fileLabel, analysisChoice, data, N, dataPath, dataName, sizeShufflePerm, numPerm);
        else
           [folderPath, matFiles] = loadFolder();
           [analysisChoice, N] = inputRun();
           [dataPath] = createFolder();
           dataName = input("Name data file (excluding .csv): ", "s");
           sizeShufflePerm = 1;
           numPerm = 1;
           if analysisChoice == 2
               sizeShufflePerm = input("How many permutations: ");
               numPerm = input("How many test: ");
           end
           for file = 1:length(matFiles)
               [data, fileLabel] = loadData(matFiles(file).name, folderPath);
               applySVM(fileLabel, analysisChoice, data, N, dataPath, dataName, sizeShufflePerm, numPerm);
           end
        end
        disp("All data " + dataName + " generated under " + dataPath);
    catch ME
        fprintf("Error caught: %s\n", ME.message);
    end
end

function choice = printInput(title, choices)
    choice = -1;
    while choice < 1 || choice > length(choices)
        disp(title);
        for i = 1:length(choices)
            fprintf("\t%d. %s\n", i, choices(i));
        end
        choice = input("Enter your choice as a number (or -1 to quit): ");
        if choice == -1
            error("User quits the program.");
        end
        fprintf("\n");
    end
end

function applySVM(fileLabel, analysisChoice, data, N, dataPath, dataName, sizeShufflePerm, numPerm)
    switch analysisChoice
        case 1
            svmBouts(dataPath, dataName, data, N, fileLabel);
        case 2
            svmCell(numPerm, sizeShufflePerm, dataPath, dataName, data, N, fileLabel);
        otherwise
            disp("Analytical method does not exist.");
    end
end

function [analysisChoice, N] = inputRun()
    analysisChoice = printInput( ...
        "Choose the analytical method:", ...
        ["Classification by sections", ...
        "Classification by cell"]);
    N = input("How many SVM runs: ");
end

function svmBouts(dataPath, dataName, data, N, fileLabel)
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
    path = strcat(dataPath, "/", dataName, ".csv");
    createCsvIfNotExist(path, rowNames);
    disp('Applying Gaussian Filtering to dataset');
    neuronalTraces = gaussFilt(data.NeuAll, 0 , 2);
    disp('Creating all experiment sections');
    mouseN1 = MouseClass(data.frameSec1Start, data.frameSec1End);
    mouseN2 = MouseClass(data.frameSec2Start, data.frameSec2End);
    mouseA1 = MouseClass(data.frameSec1Start, data.frameSec1End);
    mouseA2 = MouseClass(data.frameSec2Start, data.frameSec2End);
    disp('Defining all bouts on each sections');
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
    appendSpecialRowToCsv(path, ...
        svmData, fileLabel);
end

function svmCell(numPerm, sizeShufflePerm, dataPath, dataName, data, N, fileLabel)
    rowNames = ["mouseID", "control", "shuffle"];
    path = strcat(dataPath, "/", dataName, ".csv");
    createCsvIfNotExist(path, rowNames);
    [labels, traces] = defineNeuroResponse(data.NeuAll, data.BehavMouseN);
    labels = labels';
    permIndices = randperm(size(traces, 2), sizeShufflePerm);
    allTraces = zeros(size(traces, 1), sizeShufflePerm, numPerm);
    for i = 1:numPerm
        for j = 1:sizeShufflePerm
            allTraces(:, j, i) = traces(:, permIndices(j));
        end
    end
    result = zeros(numPerm, 2);
    for k = 1:numPerm
        selectedTraces = allTraces(:, :, k);
        accuracyControl = zeros(1, N);
        for i = 1:N
            accuracyControl(i) = Linear_decoding(selectedTraces, labels);
        end
    
        accuracyShuffle = zeros(1, N);
        for i = 1:N
            labels = labels(randperm(length(labels)));
            accuracyShuffle(i) = Linear_decoding(selectedTraces, labels);
        end
        result(k, :) = [mean(accuracyControl), mean(accuracyShuffle)];
    end    
    appendDefaultRowToCsv(path, ...
        [mean(result(:, 1)), mean(result(:, 2))], ...
        fileLabel);
end