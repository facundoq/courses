% Copyright (C) Daphne Koller, Stanford University, 2012

function EU = SimpleCalcExpectedUtility(I)

  % Inputs: An influence diagram, I (as described in the writeup).
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return Value: the expected utility of I
  % Given a fully instantiated influence diagram with a single utility node and decision node,
  % calculate and return the expected utility.  Note - assumes that the decision rule for the 
  % decision node is fully assigned.

  % In this function, we assume there is only one utility node.
  F = [I.RandomFactors I.DecisionFactors];
  U = I.UtilityFactors(1);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %parents of U
  non_parent_variables=setdiff( unique([F.var]),U.var);
  parents_factor=VariableElimination(F,non_parent_variables);
  final_factor=FactorsProduct(parents_factor);
  P = FactorProduct(final_factor, U);
  EU=sum(P.val);
  
  %assignments=IndexToAssignment(length(final_factor.val),final_factor.card);
  
  %ff_values=GetValueOfAssignment(final_factor,assignments);
  
  
  
end
