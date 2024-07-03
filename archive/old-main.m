clear all; warning off;

load("1209Amanda.mat");

Neuronal_traces = gaussFilt(NeuAll, 0, 2);

%% Detecting interaction moments.
% and creating the neuronal population vector for each of the interations.
Neuronal_Responses_N_1 = Neuro_Responces(Neuronal_traces(:,frameSec1Start:frameSec1End), BehavMouseN(frameSec1Start:frameSec1End));
Neuronal_Responses_N_2 = Neuro_Responces(Neuronal_traces(:,frameSec2Start:frameSec2End), BehavMouseN(frameSec2Start:frameSec2End));

Neuronal_Responses_A_1 = Neuro_Responces(Neuronal_traces(:,frameSec1Start:frameSec1End), BehavMouseA(frameSec1Start:frameSec1End));
Neuronal_Responses_A_2 = Neuro_Responces(Neuronal_traces(:,frameSec2Start:frameSec2End), BehavMouseA(frameSec2Start:frameSec2End));

%% Visualizing the correlation between traces. 
% Hypothesis would be to get higher correlations for population vectors within the same condition.
figure; 
traces = [Neuronal_Responses_N_1; Neuronal_Responses_N_2]; L = size(Neuronal_Responses_N_1,1);
subplot(1,5,1); hold on;  imagesc(corrcoef(traces')); 
plot([1, size(traces,1)], [L, L], 'LineWidth', 3, 'Color', 'w');
plot([L, L], [1, size(traces,1)], 'LineWidth', 3, 'Color', 'w');
xlim([0, size(traces,1)]); ylim([0, size(traces,1)]);  title('NSec1 vs NSec2');

traces = [Neuronal_Responses_A_1; Neuronal_Responses_A_2]; L = size(Neuronal_Responses_A_1,1);
subplot(1,5,2); hold on;  imagesc(corrcoef(traces')); 
plot([1, size(traces,1)], [L, L], 'LineWidth', 3, 'Color', 'w');
plot([L, L], [1, size(traces,1)], 'LineWidth', 3, 'Color', 'w');
xlim([0, size(traces,1)]); ylim([0, size(traces,1)]);  title('ASec1 vs ASec2');

traces = [Neuronal_Responses_N_1; Neuronal_Responses_A_1]; L = size(Neuronal_Responses_N_1,1);
subplot(1,5,3); hold on;  imagesc(corrcoef(traces')); 
plot([1, size(traces,1)], [L, L], 'LineWidth', 3, 'Color', 'w');
plot([L, L], [1, size(traces,1)], 'LineWidth', 3, 'Color', 'w');
xlim([0, size(traces,1)]); ylim([0, size(traces,1)]);  title('NSec1 vs ASec1');

traces = [Neuronal_Responses_N_2; Neuronal_Responses_A_2]; L = size(Neuronal_Responses_N_2,1);
subplot(1,5,4); hold on;  imagesc(corrcoef(traces')); 
plot([1, size(traces,1)], [L, L], 'LineWidth', 3, 'Color', 'w');
plot([L, L], [1, size(traces,1)], 'LineWidth', 3, 'Color', 'w');
xlim([0, size(traces,1)]); ylim([0, size(traces,1)]);  title('NSec2 vs ASec2');


%% SVM Decoding
traces_1 = Neuronal_Responses_N_1; traces_2 = Neuronal_Responses_N_2;
X = [traces_1; traces_2];  Y = [ones(size(traces_1,1),1); zeros(size(traces_2,1),1)];
N = 25;
acc_control = [];
for i=1:N
    acc_control = [acc_control; Linear_decoding(X,Y)]; disp(i);
end 
acc_shuffle = [];
for i=1:N
    Y = Y(randperm(length(Y)));
    acc_shuffle = [acc_shuffle; Linear_decoding(X,Y)]; disp(i);
end
subplot(1,5,5); hold on;
x = [1-.2, 1+.2]; y = [mean(acc_shuffle), mean(acc_control)]; err = [std(acc_shuffle), std(acc_control)]/sqrt(N);
bar(x, y); er = errorbar(x, y ,err, err); er.Color = [0 0 0]; er.LineStyle = 'none';  

traces_1 = Neuronal_Responses_A_1; traces_2 = Neuronal_Responses_A_2;
X = [traces_1; traces_2];  Y = [ones(size(traces_1,1),1); zeros(size(traces_2,1),1)];

acc_control = [];
for i=1:N
    acc_control = [acc_control; Linear_decoding(X,Y)]; disp(i);
end

acc_shuffle = [];
for i=1:N
    Y = Y(randperm(length(Y)));
    acc_shuffle = [acc_shuffle; Linear_decoding(X,Y)]; disp(i);
end

x = [2-.2, 2+.2]; y = [mean(acc_shuffle), mean(acc_control)]; err = [std(acc_shuffle), std(acc_control)]/sqrt(N);
bar(x, y); er = errorbar(x, y ,err, err); er.Color = [0 0 0]; er.LineStyle = 'none';  

traces_1 = Neuronal_Responses_N_1; traces_2 = Neuronal_Responses_A_1;
X = [traces_1; traces_2];  Y = [ones(size(traces_1,1),1); zeros(size(traces_2,1),1)];

acc_control = [];
for i=1:N
    acc_control = [acc_control; Linear_decoding(X,Y)]; disp(i);
end

acc_shuffle = [];
for i=1:N
    Y = Y(randperm(length(Y)));
    acc_shuffle = [acc_shuffle; Linear_decoding(X,Y)]; disp(i);
end

x = [3-.2, 3+.2]; y = [mean(acc_shuffle), mean(acc_control)]; err = [std(acc_shuffle), std(acc_control)]/sqrt(N);
bar(x, y); er = errorbar(x, y ,err, err); er.Color = [0 0 0]; er.LineStyle = 'none';  


traces_1 = Neuronal_Responses_N_2; traces_2 = Neuronal_Responses_A_2;
X = [traces_1; traces_2];  Y = [ones(size(traces_1,1),1); zeros(size(traces_2,1),1)];

acc_control = [];
for i=1:N
    acc_control = [acc_control; Linear_decoding(X,Y)]; disp(i);
end

acc_shuffle = [];
for i=1:N
    Y = Y(randperm(length(Y)));
    acc_shuffle = [acc_shuffle; Linear_decoding(X,Y)]; disp(i);
end

x = [4-.2, 4+.2]; y = [mean(acc_shuffle), mean(acc_control)]; err = [std(acc_shuffle), std(acc_control)]/sqrt(N);
bar(x, y); er = errorbar(x, y ,err, err); er.Color = [0 0 0]; er.LineStyle = 'none';  