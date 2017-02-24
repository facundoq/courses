clc;
clear;
load PA9Data

[P loglikelihood ClassProb] = EM_cluster(poseData1, G, InitialClassProb2, 20);
K=length(P.c);
[maxprob, assignments] = max(ClassProb, [], 2);

VisualizeDataset(poseData1(assignments == 2, :, :));
for i=1:K
    VisualizeDataset(poseData1(assignments == i, :, :));
    pause;
end