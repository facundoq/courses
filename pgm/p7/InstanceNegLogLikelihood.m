% function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)
% returns the negative log-likelihood and its gradient, given a CRF with parameters theta,
% on data (X, y). 
%
% Inputs:
% X            Data.                           (numCharacters x numImageFeatures matrix)
%              X(:,1) is all ones, i.e., it encodes the intercept/bias term.
% y            Data labels.                    (numCharacters x 1 vector)
% theta        CRF weights/parameters.         (numParams x 1 vector)
%              These are shared among the various singleton / pairwise features.
% modelParams  Struct with three fields:
%   .numHiddenStates     in our case, set to 26 (26 possible characters)
%   .numObservedStates   in our case, set to 2  (each pixel is either on or off)
%   .lambda              the regularization parameter lambda
%
% Outputs:
% nll          Negative log-likelihood of the data.    (scalar)
% grad         Gradient of nll with respect to theta   (numParams x 1 vector)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [nll, grad,theta_count,model_count,reg_grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)

    % featureSet is a struct with two fields:
    %    .numParams - the number of parameters in the CRF (this is not numImageFeatures
    %                 nor numFeatures, because of parameter sharing)
    %    .features  - an array comprising the features in the CRF.
    %
    % Each feature is a binary indicator variable, represented by a struct 
    % with three fields:
    %    .var          - a vector containing the variables in the scope of this feature
    %    .assignment   - the assignment that this indicator variable corresponds to
    %    .paramIdx     - the index in theta that this feature corresponds to
    %
    % For example, if we have:
    %   
    %   feature = struct('var', [2 3], 'assignment', [5 6], 'paramIdx', 8);
    %
    % then feature is an indicator function over X_2 and X_3, which takes on a value of 1
    % if X_2 = 5 and X_3 = 6 (which would be 'e' and 'f'), and 0 otherwise. 
    % Its contribution to the log-likelihood would be theta(8) if it's 1, and 0 otherwise.
    %
    % If you're interested in the implementation details of CRFs, 
    % feel free to read through GenerateAllFeatures.m and the functions it calls!
    % For the purposes of this assignment, though, you don't
    % have to understand how this code works. (It's complicated.)
    
    feature_set = GenerateAllFeatures(X, modelParams);

    % Use the featureSet to calculate nll and grad.
    % This is the main part of the assignment, and it is very tricky - be careful!
    % You might want to code up your own numerical gradient checker to make sure
    % your answers are correct.
    %
    % Hint: you can use CliqueTreeCalibrate to calculate logZ effectively. 
    %       We have halfway-modified CliqueTreeCalibrate; complete our implementation 
    %       if you want to use it to compute logZ.
    
    %%%
    % Your code here:
    n=length(y);
    features=feature_set.features;
    K = modelParams.numHiddenStates;
    lambda=modelParams.lambda;
    [nll,clique_tree]=calculate_nll(features,K,y,theta,lambda);
        
    %grad reg
    reg_grad=lambda * theta;
    theta_count=calculate_theta_count(features,theta,y);
    model_count=calculate_model_count(features,theta,clique_tree.cliqueList,y);
    
    grad=model_count-theta_count+reg_grad;
    
end


function [nll,P]=calculate_nll(features,K,y,theta,lambda)
    feature_sum=calculate_feature_sum(features,theta,y);
    factors=generate_factors(features,theta,K);
    P = CreateCliqueTree(factors);
    fprintf('after create\n');
    isMax=false;
    [P, logZ]=CliqueTreeCalibrate(P,isMax);
    reg =0.5*sum(theta.^2)*lambda;
    %pyx=theta.^theta_count;
    nll = - feature_sum +logZ +reg;
end
function factors=generate_factors(features,theta,K)
    fn=length(features);
    factors=repmat(EmptyFactorStruct(),1,fn);
    for i=1:fn
        feature=features(i);
        f.var=feature.var;
        f.card=repmat(K,1,length(f.var));
        f.val=zeros(1,prod(f.card));
        f=SetValueOfAssignment(f,feature.assignment,theta(feature.paramIdx));
        f.val=exp(f.val);
        factors(i)=f;    
    end
    
end

function feature_sum=calculate_feature_sum(features,theta,y)

feature_sum=0;
for i=1:length(features)
    feature=features(i);
    if all(y(feature.var)==feature.assignment)
        feature_sum=feature_sum+theta(feature.paramIdx);
    end
end

end

function theta_count=calculate_theta_count(features,theta,y)
    theta_count=zeros(size(theta));
    for i=1:length(features)
        feature=features(i);
        if all(y(feature.var)==feature.assignment)
            theta_count(feature.paramIdx)=theta_count(feature.paramIdx)+1;
        end
    end
end

function model_count=calculate_model_count(features,theta,cliques,y)
    model_count=zeros(size(theta));
    
    for i=1:length(features)
        f=features(i);
        
        for j=1:length(cliques)
            clique=cliques(j);
            if all(ismember(f.var,clique.var)) 
                clique=FactorMarginalization(clique,setdiff(clique.var,f.var));    
                clique.val=clique.val/ sum(clique.val);
                p=GetValueOfAssignment(clique,f.assignment,f.var);
                model_count(f.paramIdx)=model_count(f.paramIdx)+p;
                break;
            end
            
        end
        
        
    end
    
    
end