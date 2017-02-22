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
    loglikelihoods(i)=ComputeLogLikelihoodSample(P,G,squeeze(dataset(i,:,:)));
end

loglikelihood=sum(loglikelihoods);
end

function loglikelihood = ComputeLogLikelihoodSample(P, G, sample)

% You should compute the log likelihood of data as in eq. (12) and (13)
% in the PA description
% Hint: Use lognormpdf instead of log(normpdf) to prevent underflow.
%       You may use log(sum(exp(logProb))) to do addition in the original
%       space, sum(Prob).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K = length(P.c); % number of classes
class_likelihoods=zeros(1,K);
for klass=1:K
    class_likelihoods(klass)=class_loglikelihood(P,G,sample,klass);
end

%loglikelihood=log(sum(exp(class_likelihoods)));
loglikelihood=logsumexp(class_likelihoods);

end

function class_ll=class_loglikelihood(P,G,sample,klass)
    [parts,d]=size(sample);
    class_ll=log(P.c(klass));
    for p=1:parts
        part_ll=part_loglikelihood(P.clg(p),p,sample,G,klass);
        class_ll=class_ll+part_ll;
    end
    
end

function part_ll=part_loglikelihood(part_model,part,sample,G,klass)
        has_parent=G(part,1);
        parents=G(part,2:end);
        part_sample=sample(part,:);
        if has_parent
            part_ll=part_loglikelihood_parents(part_model,part_sample,klass,sample(parents,:));
        else
            part_ll=part_loglikelihood_no_parents(part_model,part_sample,klass);
        end
end

function loglikelihood=part_loglikelihood_no_parents(part_model,part_sample,klass)
    variables=size(part_sample,2);
    pll=zeros(1,variables);
    
    % order is y,x,angle
    mus=[part_model.mu_y(klass), part_model.mu_x(klass),part_model.mu_angle(klass)];
    sigmas=[part_model.sigma_y(klass), part_model.sigma_x(klass),part_model.sigma_angle(klass)];
    for i=1:variables
        pll(i)=logprob(part_sample(i),mus(i),sigmas(i));
    end
    loglikelihood=sum(pll);
    
end


function loglikelihood=part_loglikelihood_parents(part_model,part_sample,klass,parents_values)
    [parents,d]=size(parents_values);
    
    % sigmas: order is y,x,angle
    sigmas=[part_model.sigma_y(klass),part_model.sigma_x(klass),part_model.sigma_angle(klass)];
    
    %calculate mus
    beta=part_model.theta(klass,:);
    beta=reshape(beta,4,3);
    beta=beta';
    parents_values=[ones(parents,1) parents_values];
    mus=beta*parents_values';
    
    %calculate log prob for each variable (y,x,angle)
    pll=zeros(1,d);
    for i=1:d
        pll(i)=logprob(part_sample(i),mus(i),sigmas(i));
    end
    loglikelihood=sum(pll);
end

function lp=logprob(x,mu,sigma)
    %lp=-lognpdf(x,mu,sigma);
    lp=lognormpdf(x,mu,sigma); 
end