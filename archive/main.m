%% 1. Upload Dataset
% It opens a dialog for the user to choose the dataset
[fileName, filePath] = uigetfile('*.mat', 'Select a MAT-file');
fileLabel = split(fileName, "."); fileLabel = fileLabel{1};
fileLabel = regexp(fileLabel, '\d*', 'Match'); fileLabel = fileLabel{1};
data = loadData(fileName, filePath);
createFolder(strcat(filePath, "data"));
disp("1. Uploading dataset completed.");
%% 2. Clean Dataset
% Apply a Gaussian Filter to the cell activity dataset
% which improves the classification due to shadowing effect
neuronalTraces = gaussFilt(data.NeuAll, 0, 2);
disp("2. Gaussian filter completed.");
%% 3. Define Mice
mouseN1 = MouseClass(data.frameSec1Start, data.frameSec1End);
mouseN2 = MouseClass(data.frameSec2Start, data.frameSec2End);
mouseA1 = MouseClass(data.frameSec1Start, data.frameSec1End);
mouseA2 = MouseClass(data.frameSec2Start, data.frameSec2End);
disp("3. Mice object creation completed.");
%% 4. Annotate Bouts
% Create a list of bouts of given mouse section
% with their corresponding timestamp of its cell activities
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
disp("4. Bout annotation completed.");
%% 5. Draw Coefficient Correlation
% Plot a correlation graph on list of bouts between bouts
% The number of plots corresponds to all the possible permutations
createFolder(strcat(filePath, "data/", fileLabel));
fig1 = drawCorrelation(neuronalResponsesN1, neuronalResponsesN2, ...
    "N1Sec", "N2Sec");
writeFile(fig1, "N1Sec", "N2Sec", fileLabel, filePath, fileLabel);
fig2 = drawCorrelation(neuronalResponsesA1, neuronalResponsesA2, ...
    "A1Sec", "A2Sec");
writeFile(fig2, "A1Sec", "A2Sec", fileLabel, filePath, fileLabel);
fig3 = drawCorrelation(neuronalResponsesN1, neuronalResponsesA1, ...
    "N1Sec", "A1Sec");
writeFile(fig3, "N1Sec", "A1Sec", fileLabel, filePath, fileLabel);
fig4 = drawCorrelation(neuronalResponsesN2, neuronalResponsesA2, ...
    "N2Sec", "A2Sec");
writeFile(fig4, "N2Sec", "A2Sec", fileLabel, filePath, fileLabel);
disp("5. Coefficient colleration generation completed.")
%% 6. Decode SVM
createCsvIfNotExist(strcat(filePath, "/data/", "svm_analysis_reverse_eng", ".csv"), ...
    ["mouseID", ...
     "cN1N2", "std_cN1N2", ...
     "N1N2", "std_N1N2", ...
     "cA1A2", "std_cA1A2", ...
     "A1A2", "std_A1A2", ...
     "cN1A1", "std_cN1A1", ...
     "N1A1", "std_N1A1", ...
     "cN2A2", "std_cN2A2", ...
     "N2A2", "std_N2A2"]);
numTests = 100;
svmN1N2 = decodeSVM(neuronalResponsesN1, neuronalResponsesN2, numTests);
svmA1A2 = decodeSVM(neuronalResponsesA1, neuronalResponsesA2, numTests);
svmN1A1 = decodeSVM(neuronalResponsesN1, neuronalResponsesA1, numTests);
svmN2A2 = decodeSVM(neuronalResponsesN2, neuronalResponsesA2, numTests);
svmData = [svmN1N2, svmA1A2, svmN1A1, svmN2A2];
appendRowToCsv(strcat(filePath, "/data/", "svm_analysis_reverse_eng", ".csv"), ...
    svmData, fileLabel);
disp("6. SVM generation completed.")
%% Appendix - All helper functions and classes
function data = loadData(fileName, filePath)
    if isequal(fileName,0)
        disp('User selected Cancel');
    else
        fullFileName = fullfile(filePath, fileName);
        disp(['User selected ', fullFileName]);
    
        % Load the selected file
        data = load(fullFileName);
        disp('File loaded successfully');
        disp(data); % Display loaded data
    end
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

function writeFile(fig, section1, section2, file, filePath, folder)
    fileName = strcat(file, "_", section1, "_", section2, ".jpg");
    folderPath = strcat(filePath, "data/", folder);
    createFolder(folderPath);
    exportgraphics(fig, fullfile(folderPath, fileName), ...
        'Resolution', 300);
    close(fig);
end

function fig = drawCorrelation(section1, section2, s1Name, s2Name)
    fig = figure('Name', strcat(s1Name, "_", s2Name), 'Visible', 'off');
    traces = [section1; section2];
    length = size(section1, 1);
    subplot(1, 1, 1);
    hold on;
    imagesc(corrcoef(traces'));
    % Draw separation between sections 
    % (i.e., horizontal and vertical respectively
    plot([1, size(traces, 1)], [length, length], 'LineWidth', 1, 'Color', 'w');
    plot([length, length,], [1, size(traces, 1)], 'LineWidth', 1, 'Color', 'w');
    xlim([0, size(traces, 1)]); xlabel('Bout #');
    ylim([0, size(traces, 1)]); ylabel('Bout #');
    title('NSsec1 vs NSec2');
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
    fprintf(fid, '%s,', mouseID);
    for i = 1:(length(rowData) - 1)
        fprintf(fid, '%s,', rowData(i));
    end
    fprintf(fid, '%s\n', rowData(end));
    fclose(fid);
end
