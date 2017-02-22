clc;
clear;

load PA8Data
human=trainData.labels(:,1)==1;
alien=trainData.labels(:,2)==1;

VisualizeDataset(trainData.data(human,:,:));

%VisualizeDataset(trainData.data(alien,:,:));