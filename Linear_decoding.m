function accuracy = Linear_decoding(X,Y)

preds = [];
for i = 1:length(Y)
    X_train = X; X_train(i,:) = []; Y_train = Y; Y_train(i,:) = [];
    X_test = X(i,:); Y_test = Y(i,:);
    [X_train, Y_train] = Balancing_samples(X_train,Y_train);
    Model = fitclinear(X_train, Y_train);
    [label, score] = predict(Model, X_test);
    preds = [preds; label];
end

accuracy = sum(preds==Y)/length(Y);