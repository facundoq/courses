clc;
clear;
%% Change this to test the different parts of the assignment.
%% Or, you can comment it out and set it globally from the command line.
testNum = 5

%% Load all the necessary files:
load('Train1X.mat');
load('Train1Y.mat');
load('Validation1X.mat');
load('Validation1Y.mat');
load('Part1Lambdas.mat');
load('ValidationAccuracy.mat');
%% Part 2:
load('Part2Sample.mat');


switch testNum
  case 1
    thetaOpt = LRTrainSGD(Train1X, Train1Y, 0);
    predY = LRPredict(Train1X, thetaOpt);
    accuracy = LRAccuracy(Train1Y, predY);
    assert(eq_eps(accuracy, 0.96));

  case 2
    allAcc = LRSearchLambdaSGD(Train1X, Train1Y, Validation1X, Validation1Y, Part1Lambdas);
    assert(eq_eps(allAcc,ValidationAccuracy));
    %assert(allAcc(:), ValidationAccuracy(:), 1e-6);

  case 3
    [~, logZ] = CliqueTreeCalibrate(sampleUncalibratedTree, false);
    assert(eq_eps(logZ, sampleLogZ));

  case 4
    %% This is vastly inadequate, you should probably test the different
    %% components of nll computation separately. Unfortunately, we don't
    %% have the problem divided into canonical subtasks. But, you should
    %% probably try to create your own tests for those.
    [nll, ~] = InstanceNegLogLikelihood(sampleX, sampleY, sampleTheta, sampleModelParams);
    assert(eq_eps(nll, sampleNLL),sprintf('Calculated nll: %f, true nll: %f',nll,sampleNLL));

  case 5
    [~, grad,theta_count,model_count,reg_grad] = InstanceNegLogLikelihood(sampleX, sampleY, sampleTheta, sampleModelParams);
    
    cgrad=[grad',sampleGrad'];
    cmodel=[model_count',sampleModelFeatureCounts'];
    ctheta=[theta_count',sampleFeatureCounts'];
    creg=[reg_grad',sampleRegularizationGradient'];
    
    
    fprintf('theta_count: ');
    assert(eq_eps(theta_count, sampleFeatureCounts),difference_info(theta_count, sampleFeatureCounts));
    fprintf('ok\nreg: ');
    assert(eq_eps(reg_grad, sampleRegularizationGradient),difference_info(reg_grad, sampleRegularizationGradient));
    fprintf('ok\nmodel_count: ');
    assert(eq_eps_all(model_count, sampleModelFeatureCounts),difference_info(model_count, sampleModelFeatureCounts));
    fprintf('ok\ngrad: ');
    assert(eq_eps_all(grad, sampleGrad), difference_info(grad,sampleGrad));
 
end

disp('Test finished successfully!');