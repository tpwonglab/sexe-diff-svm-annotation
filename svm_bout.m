main();

function main()
    [folderPath, matFiles] = processMatFiles();
    createCsvIfNotExist(strcat(folderPath, "/incident-svm-analysis.csv"), ...
        ["mouseID", "control", "shuffle"]);
    for file = 1:length(matFiles)
        filePath = fullfile(folderPath, matFiles(file).name);
        fileLabel = regexp(matFiles(file).name, '\d*', 'Match'); fileLabel = fileLabel{1};
        data = load(filePath);
        disp("Processing file " ...
            + "[" + file + "/" + length(matFiles) + "]: " ...
            + matFiles(file).name);
        [labels, traces] = defineNeuroResponse(data.NeuAll, data.BehavMouseN);
        labels = labels';
        accuracyControl = zeros(1, 25);
        for i = 1:25
            accuracyControl(i) = Linear_decoding(traces, labels);
        end
    
        accuracyShuffle = zeros(1, 25);
        for i = 1:25
            labels = labels(randperm(length(labels)));
            accuracyShuffle(i) = Linear_decoding(traces, labels);
        end
        disp("Control: " + mean(accuracyControl) + " Shuffle: " + mean(accuracyShuffle));
        appendRowToCsv(strcat(folderPath, "/incident-svm-analysis.csv"), ...
            [mean(accuracyControl), mean(accuracyShuffle)], ...
            fileLabel);
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
    fprintf(fid, '%s, ', rowData(1));
    fprintf(fid, '%s\n', rowData(2));
    fclose(fid);
end

function [labels, sections] = defineBouts(behaviour)
    labels = [];
    sections = [];
    startPointer = 1;
    isPrevTouch = behaviour(1);
    for i = 2:length(behaviour)
        isTouch = behaviour(i);
        if isTouch ~= isPrevTouch
            sections = [sections; [startPointer, i - 1]];
            labels = [labels, isPrevTouch];
            startPointer = i;
            if i == length(behaviour)
                sections = [sections; [i, i]];
                labels = [labels, isTouch];
                return
            end
        elseif i == length(behaviour)
            sections = [sections; [startPointer, i]];
            labels = [labels, isTouch];
        end
        isPrevTouch = isTouch;
    end
end

function [labels, avgTraces] = defineNeuroResponse(traces, behaviour)
    [labels, sections] = defineBouts(behaviour);
    avgTraces = [];
    for i = 1:length(sections)
        avgTraces = [avgTraces; mean(traces(:, sections(i, 1):sections(i, 2)), 2)'];
    end
end

function [folderPath, matFiles] = processMatFiles()
    folderPath = uigetdir;
    if folderPath == 0
        disp('Folder selection canceled. Exiting.');
        return;
    end
    matFiles = dir(fullfile(folderPath, '*.mat'));
end