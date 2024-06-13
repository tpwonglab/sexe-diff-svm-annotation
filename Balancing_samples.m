function [X Y] = Balancing_samples(X, Y)

s = unique(Y);

a1 = find(Y==s(1));
a2 = find(Y==s(2));

if length(a1)>length(a2)
    n = length(a1) - length(a2);
    idx = randi([1 length(a1)],1,n);
    idx = a1(idx); Y(idx,:) = []; X(idx,:) = [];
end

if length(a2)>length(a1)
    n = length(a2) - length(a1);
    idx = randi([1 length(a2)],1,n);
    idx = a2(idx); Y(idx,:) = []; X(idx,:) = [];
end

end