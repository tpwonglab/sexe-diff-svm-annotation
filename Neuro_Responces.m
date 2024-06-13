function avg_traces = Neuro_Responces(traces, beh)

frames_diff = beh(2:end) - beh(1:end-1);
frames1 = find(frames_diff==1); frames2 = find(frames_diff==-1);

Interactions = [];
for i=1:length(frames1)
    try
        a = frames1(i);
        j = find(frames2>a); j = j(1);
        Interactions = [Interactions; [frames1(i)+1, frames2(j)]];
    end
end

N = size(Interactions, 1);
avg_traces = [];
for i=1:N
    avg_traces = [avg_traces; mean(traces(:,Interactions(i,1):Interactions(i,2)),2)'];
end
