function [P loglikelihood] = LearnCPDsGivenGraph(dataset, G, labels)
%
% Inputs:
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% G: graph parameterization as explained in PA description
% labels: N x 2 true class labels for the examples. labels(i,j)=1 if the 
%         the ith example belongs to class j and 0 elsewhere        
%
% Outputs:
% P: struct array parameters (explained in PA description)
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
K = size(labels,2);

parts=size(G,1);

% estimate parameters
% fill in P.c, MLE for class probabilities
% fill in P.clg for each body part and each class
% choose the right parameterization based on G(i,1)
% compute the likelihood - you may want to use ComputeLogLikelihood.m
% you just implemented.
%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P.c = zeros(1,K);
P.clg=repmat(empty_part_model(K),1,parts);
for klass=1:K
    P.c(klass)=mean(labels(:,klass));
    samples=dataset(labels(:,klass)==1,:,:);
    for part=1:parts
        has_parent=G(part,1);
        parent=G(part,2);
        part_model=P.clg(part);
        part_samples=squeeze(samples(:,part,:));
        
        if has_parent
            parent_samples=squeeze(samples(:,parent,:));
            [a, part_model.sigma_y(klass)]=FitLinearGaussianParameters(part_samples(:,1),parent_samples);
            part_model.theta(klass,1:4)=[a(end) a(1:end-1)'];
            [a, part_model.sigma_x(klass)]=FitLinearGaussianParameters(part_samples(:,2),parent_samples);
            part_model.theta(klass,5:8)=[a(end) a(1:end-1)'];
            [a, part_model.sigma_angle(klass)]=FitLinearGaussianParameters(part_samples(:,3),parent_samples);
            part_model.theta(klass,9:12)=[a(end) a(1:end-1)'];
            % we need to store thetas in a and then flip because
            % sample outputs are wrong, in one instance the constant term
            % in the clg is the first element, in other instance it is the
            % last
            
            part_model.mu_y=[];
            part_model.mu_x=[];
            part_model.mu_angle=[];
        else
            [part_model.mu_y(klass), part_model.sigma_y(klass)]=FitGaussianParameters(part_samples(:,1));
            [part_model.mu_x(klass), part_model.sigma_x(klass)]=FitGaussianParameters(part_samples(:,2));
            [part_model.mu_angle(klass), part_model.sigma_angle(klass)]=FitGaussianParameters(part_samples(:,3));
            part_model.theta=[];
        end
        
        P.clg(part)=part_model;
    end
    
end


loglikelihood=ComputeLogLikelihood(P,G,dataset);
fprintf('log likelihood: %f\n', loglikelihood);

end
function p=empty_part_model(K)
    a=zeros(1,K);
    p=struct('mu_y',a,'sigma_y',a,'mu_x',a,'sigma_x',a,'mu_angle',a,'sigma_angle',a,'theta',zeros(2,12));
end