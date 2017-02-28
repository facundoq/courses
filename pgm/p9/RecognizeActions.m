% File: RecognizeActions.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012
    
function [accuracy, predicted_labels] = RecognizeActions(datasetTrain, datasetTest, G, maxIter)

% INPUTS
% datasetTrain: dataset for training models, see PA for details
% datasetTest: dataset for testing models, see PA for details
% G: graph parameterization as explained in PA decription
% maxIter: max number of iterations to run for EM

% OUTPUTS
% accuracy: recognition accuracy, defined as (#correctly classified examples / #total examples)
% predicted_labels: N x 1 vector with the predicted labels for each of the instances in datasetTest, with N being the number of unknown test instances


% Train a model for each action
% Note that all actions share the same graph parameterization and number of max iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expand_factor=4;
perturbation_factor=2e-1;
datasetTrain=expand_dataset(datasetTrain,expand_factor,perturbation_factor);

%TODO recalculate PairProb and MargProb
k_poses=2;
datasetTrain=estimate_initial_probabilities(datasetTrain,k_poses);

models=[];
for i=1:length(datasetTrain)
    action_samples=datasetTrain(i);
    fprintf('Training model for class %d, %d samples:\n',i,length(action_samples.actionData));
    
%     subplot(1,2,1)
%     imagesc(action_samples.InitialClassProb);colorbar;
%     subplot(1,2,2)
%     imagesc(action_samples.InitialPairProb);colorbar;
    [model, loglikelihood, ClassProb, PairProb]=EM_HMM(action_samples.actionData, action_samples.poseData, G, action_samples.InitialClassProb, action_samples.InitialPairProb, maxIter);
    models=[models model];
end

 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Classify each of the instances in datasetTrain
% Compute and return the predicted labels and accuracy
% Accuracy is defined as (#correctly classified examples / #total examples)
% Note that all actions share the same graph parameterization

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[predicted_labels,likelihood]=classify_actions(models,G,datasetTest);
accuracy=mean(datasetTest.labels==predicted_labels);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end
function [labels likelihoods]=classify_actions(models,G,action_samples)
    K=length(models);
    N=length(action_samples.actionData);
    likelihoods=zeros(N,K);
     for m=1:length(models)
         likelihoods(:,m)=classify_actions_model(models(m),G,action_samples);
     end
     [~,labels]=max(likelihoods,[],2);
    
end

function loglikelihoods=classify_actions_model(model,G,action_samples)
    actionData=action_samples.actionData;
    N=length(actionData);
    loglikelihoods=zeros(1,N);
    poseData=action_samples.poseData;
    logEmissionProb=emission_probability(model,G,poseData);
    for i=1:N
        action_poses_indices=actionData(i).marg_ind;
%         n_poses=length(action_poses_indices);
%         n_transitions=n_poses-1;
        factors=factors_for_hmm(model,logEmissionProb(action_poses_indices,:));
        [M, calibratedTree]=ComputeExactMarginalsHMM(factors); 
        cs=calibratedTree.cliqueList;
        loglikelihoods(i)=logsumexp(cs(end).val);
    end
end

