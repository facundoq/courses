function loglikelihood = ComputeLogLikelihood(P, G, dataset)
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
for i=1:N
    class_likelihoods=ComputeClassLikelihoodSample(P,G,squeeze(dataset(i,:,:)));
    %loglikelihood=log(sum(exp(class_likelihoods)));
    loglikelihoods(i) =logsumexp(class_likelihoods);
end

loglikelihood=sum(loglikelihoods);
end

