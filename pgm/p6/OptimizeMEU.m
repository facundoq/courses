% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeMEU( I )

  % Inputs: An influence diagram I with a single decision node and a single utility node.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  
  % We assume I has a single decision node.
  % You may assume that there is a unique optimal decision.

  %PrintFactor(D);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE...
  % 
  % Some other information that might be useful for some implementations
  % (note that there are multiple ways to implement this):
  % 1.  It is probably easiest to think of two cases - D has parents and D 
  %     has no parents.
  % 2.  You may find the Matlab/Octave function setdiff useful.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  EUF= CalculateExpectedUtilityFactor( I ); 
  D = I.DecisionFactors(1);
  OptimalDecisionRule=D;
  if (length(D.var)==1)
      [MEU i]=max(EUF.val);
      OptimalDecisionRule.val(:)=0;
      OptimalDecisionRule.val(i)=1;
      return
  end
  
  parent_assigments=prod(D.card(2:end)); %the decision variable should be the first in the EUF
  decision_values=D.card(1);
  indices=[];
  D.var
  EUF.var
  MEU=0;
  for i=1:parent_assigments
      from=(i-1)*decision_values+1;
      to=from+decision_values-1;
      decision_indices=from:to;
      assignments=IndexToAssignment(decision_indices,D.card);
      %assignments=assignments(:,mappingDtoEUF);
      values=GetValuesOfAssignments(EUF,assignments,D.var);
      [v, i_max]=max(values);
      OptimalDecisionRule.val(decision_indices)=0;
      OptimalDecisionRule.val(i+i_max-1)=1;
      MEU=MEU+v;
  end
  OptimalDecisionRule.val
  %OptimalDecisionRule=SortFactorVars(OptimalDecisionRule);
  %OptimalDecisionRule.val
  
  %MEU=7.500000;max(EUF.val);

end


