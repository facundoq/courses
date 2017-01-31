clc;
clear;
gt=load('PA4Sample.mat');

gt.InitPotential.computed=ComputeInitialPotentials(gt.InitPotential.INPUT);

checkResult('InitPotential',gt.InitPotential.RESULT.cliqueList,gt.InitPotential.computed.cliqueList);
%assert(eq_factors(gt.InitPotential.RESULT.cliqueList,gt.InitPotential.computed.cliqueList));

edges=gt.GetNextC.INPUT1.edges;
[gt.GetNextC.computed1,gt.GetNextC.computed2]=GetNextCliques(gt.GetNextC.INPUT1,gt.GetNextC.INPUT2);
% [gt.GetNextC.computed1,gt.GetNextC.computed2]
% [gt.GetNextC.RESULT1,gt.GetNextC.RESULT2]
assert(gt.GetNextC.RESULT1==gt.GetNextC.computed1);
assert(gt.GetNextC.RESULT2==gt.GetNextC.computed2);

isMax=false;
gt.SumProdCalibrate.computed=CliqueTreeCalibrate(gt.SumProdCalibrate.INPUT,isMax);
checkResult('SumProdCalibrate',gt.SumProdCalibrate.RESULT.cliqueList,gt.SumProdCalibrate.computed.cliqueList);


gt.ExactMarginal.computed=ComputeExactMarginalsBP(gt.ExactMarginal.INPUT,[],isMax);
checkResult('ExactMarginal',gt.ExactMarginal.RESULT,gt.ExactMarginal.computed);


% load('PA4Sample.mat', 'SixPersonPedigree');
% ComputeExactMarginalsBP(SixPersonPedigree, [], 0);
% 
% evidence=zeros(1,12);
% var=3;
% val=3;
% evidence(var)=val;
% M = ComputeExactMarginalsBP(SixPersonPedigree, evidence, 0);
% M1=   ComputeMarginal(1, SixPersonPedigree, [var val])
% M(1)
% M5 = ComputeMarginal(5,SixPersonPedigree,[var val])
% M(5)

gt.FactorMax.computed=FactorMaxMarginalization(gt.FactorMax.INPUT1,gt.FactorMax.INPUT2);
checkResult('FactorMax',gt.FactorMax.RESULT,gt.FactorMax.computed);

isMax=true;
gt.MaxSumCalibrate.computed=CliqueTreeCalibrate(gt.MaxSumCalibrate.INPUT,isMax);
checkResult('MaxSumCalibrate',gt.MaxSumCalibrate.RESULT.cliqueList,gt.MaxSumCalibrate.computed.cliqueList);

gt.MaxMarginals.computed=ComputeExactMarginalsBP(gt.MaxMarginals.INPUT,[],isMax);
checkResult('MaxMarginals',gt.MaxMarginals.RESULT,gt.MaxMarginals.computed);

gt.MaxDecoded.computed=MaxDecoding(gt.MaxDecoded.INPUT);
assert(all(gt.MaxDecoded.RESULT==gt.MaxDecoded.computed));



load('PA4Sample.mat', 'OCRNetworkToRun');
maxMarginals = ComputeExactMarginalsBP(OCRNetworkToRun, [], 1);
MAPAssignment = MaxDecoding(maxMarginals);
DecodedMarginalsToChars(MAPAssignment)