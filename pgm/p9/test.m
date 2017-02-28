
clc;
clear;
load PA9Data

% [P loglikelihood ClassProb] = EM_cluster(poseData1, G, InitialClassProb2, 20);
% K=length(P.c);
% [maxprob, assignments] = max(ClassProb, [], 2);
% 
% VisualizeDataset(poseData1(assignments == 2, :, :));
% for i=1:K
%     VisualizeDataset(poseData1(assignments == i, :, :));
%     pause;
% end


[accuracy, predicted_labels] = RecognizeActions(datasetTrain1, datasetTest1, G, 7)
%[accuracy, predicted_labels] = RecognizeActions(datasetTrain2, datasetTest2, G, 10)
