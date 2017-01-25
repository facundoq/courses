clc;
clear;
load PA3Data;
data=allWords;
model=load('PA3Models');
cases=load('PA3SampleCases');

network=BuildOCRNetwork(data{1}, model.imageModel, [],[]);

% model.imageModel.ignoreSimilarity=true;
 [charAcc, wordAcc] = ScoreModel(data, model.imageModel, model.pairwiseModel, model.tripletList);

