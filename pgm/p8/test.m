clc;
clear;

load PA8Data
human=trainData.labels(:,1)==1;
alien=trainData.labels(:,2)==1;

% VisualizeDataset(trainData.data(human,:,:));
%VisualizeDataset(trainData.data(alien,:,:));

[P1 likelihood1] = LearnCPDsGivenGraph(trainData.data, G1, trainData.labels);
accuracy1 = ClassifyDataset(testData.data, testData.labels, P1, G1);



[P2 likelihood2] = LearnCPDsGivenGraph(trainData.data, G2, trainData.labels);
accuracy2 = ClassifyDataset(testData.data, testData.labels, P2, G2);


[P G likelihood3] = LearnGraphAndCPDs(trainData.data, trainData.labels);
ClassifyDataset(testData.data, testData.labels, P, G);


VisualizeModels(P, G);
%VisualizeModels(P1, G1);
% VisualizeModels(P2, G2);
