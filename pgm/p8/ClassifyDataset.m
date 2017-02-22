function accuracy = ClassifyDataset(dataset, labels, P, G)
% returns the accuracy of the model P and graph G on the dataset 
%
% Inputs:
% dataset: N x 10 x 3, N test instances represented by 10 parts
% labels:  N x 2 true class labels for the instances.
%          labels(i,j)=1 if the ith instance belongs to class j 
% P: struct array model parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description) 
%
% Outputs:
% accuracy: fraction of correctly classified instances (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
predicted=zeros(1,N);
for i=1:N
    class_l = ComputeClassLikelihoodSample(P, G, squeeze(dataset(i,:,:)));
    [~, predicted(i)]=max(class_l);
end
c= (labels(:,1)==1) +  (labels(:,2)==1)*2;

accuracy=mean(c==predicted');




fprintf('Accuracy: %.2f\n', accuracy);