% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeMEU( I,euf )

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
  if nargin==1
    euf= CalculateExpectedUtilityFactor(I); 
  end
  D = I.DecisionFactors(1);
  assert(all(sort(D.var)==sort(euf.var)));
  
% parent_variables=D.var(2:end);
  decision_variable=D.var(1);
  decision_values=D.card(1);
  euf_var1=euf.var(1);
  euf=exchange_variable_order(euf,decision_variable,euf_var1);
  
  odr=euf;
  %decision_variable_column_odr=find(decision_variable==odr.var);
  
  
  if (length(D.var)==1)
      [MEU i]=max(euf.val);
      odr.val(:)=0;
      odr.val(i)=1;
      OptimalDecisionRule=odr;
      return
  end
  
  parent_assignments=prod(D.card(2:end));   
  MEU=0;
  for i=1:parent_assignments
      from=(i-1)*decision_values+1;
      to=from+decision_values-1;
      decision_indices=from:to;
      assignments=IndexToAssignment(decision_indices,euf.card);
      values=GetValuesOfAssignments(euf,assignments);
      [v, i_max]=max(values);
      odr.val(decision_indices)=0;
      odr.val(from+i_max-1)=1;
      MEU=MEU+v;
  end
  
  odr=exchange_variable_order(odr,decision_variable,euf_var1);
  
  OptimalDecisionRule=odr;
end
