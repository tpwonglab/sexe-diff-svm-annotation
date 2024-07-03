clear;
[fileName, filePath] = uigetfile('*.mat', 'Select a MAT-file');
fileLabel = split(fileName, ".");
fileLabel = fileLabel{1};
fullFileName = fullfile(filePath, fileName);
data = load(fullFileName);
A = [1 2 3 4 5 7];
disp(size(data.NeuAll, 1))
disp(size(A, 2));

B = zeros(size(data.NeuAll, 1), size(A, 2));
for i = 1:size(A)
    B(i) = data.NeuAll(:, A(i));
end
disp(B);





