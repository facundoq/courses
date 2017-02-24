function [loglikelihood, per_class_prob,per_class_ll] = ComputeLogLikelihood(P, G, dataset)
% returns the (natural) log-likelihood of data given the model and graph structure
%
% Inputs:
% P: struct array parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description)
%
%    NOTICE that G could be either 10x2 (same graph shared by all classes)
%    or 10x2x2 (each class has its own graph). your code should compute
%    the log-likelihood using the right graph.
%
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% 
% Output:
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012


N = size(dataset,1); % number of examples
loglikelihoods = zeros(1,N);
K=length(P.c);
per_class_ll=zeros(N,K);
per_class_prob=zeros(N,K);
for i=1:N
    per_class_ll(i,:)=ComputeClassLikelihoodSample(P,G,squeeze(dataset(i,:,:)));
    per_class_prob(i,:)=exp(per_class_ll(i,:));
    per_class_prob(i,:)=per_class_prob(i,:) /sum(per_class_prob(i,:));
    %loglikelihood=log(sum(exp(class_likelihoods)));
    loglikelihoods(i) =logsumexp(per_class_ll(i,:));
end

loglikelihood=sum(loglikelihoods);

end

