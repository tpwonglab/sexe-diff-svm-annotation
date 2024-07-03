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