%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization
% you should set it to the correct value in your code


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p=CreateCliqueTree(F,E);
p=CliqueTreeCalibrate(p,isMax);

clique_beliefs=p.cliqueList;
variables=sort(unique([clique_beliefs.var]));
M = repmat(empty_factor(),length(variables),1);

for i=1:length(variables)
    var=variables(i);
    clique_for_var=compute_clique_for_var(clique_beliefs,var);
    clique_beliefs_for_var=clique_beliefs(clique_for_var);
    variables_to_marginalize=setdiff(clique_beliefs_for_var.var,var);
    if isMax==0
        M(i)=FactorMarginalization(clique_beliefs_for_var,variables_to_marginalize);
        M(i)=normalize_factor(M(i));
    else
        M(i)=FactorMaxMarginalization(clique_beliefs_for_var,variables_to_marginalize);
        %M(i)=normalize_factor(M(i));
        
    end
end

end

function clique_for_var=compute_clique_for_var(clique_beliefs,var)
    clique_for_var=0;
    for j=1:length(clique_beliefs)
        if(ismember(var,clique_beliefs(j).var))
            clique_for_var=j;
            break;
        end
    end
    assert(clique_for_var~=0);
end