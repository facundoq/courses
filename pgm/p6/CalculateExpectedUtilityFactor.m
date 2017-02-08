% Copyright (C) Daphne Koller, Stanford University, 2012

function EUF = CalculateExpectedUtilityFactor( I )

  % Inputs: An influence diagram I with a single decision node and a single utility node.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: A factor over the scope of the decision rule D from I that
  % gives the conditional utility given each assignment for D.var
  %
  % Note - We assume I has a single decision node and utility node.
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE...
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
  F = [I.RandomFactors I.UtilityFactors];
  D = I.DecisionFactors(1);

  non_parent_variables=setdiff( unique([F.var]),D.var);
  parents_factor=VariableElimination(F,non_parent_variables);
  EUF =FactorsProduct(parents_factor);
 
  
  
%   for h=1:length(I.RandomFactors)
%         fprintf('f%d\n',h);
%         PrintFactor(I.RandomFactors(h));
%     end
%     fprintf('fd\n');
%     PrintFactor(I.DecisionFactors)
%     fprintf('fu\n');
%     PrintFactor(I.UtilityFactors)
%       fprintf('ff\n');
%   PrintFactor(final_factor);

  
end  
