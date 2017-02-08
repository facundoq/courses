% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = SimpleOptimizeMEU(I)
  
  % We assume there is only one decision rule in this function.
  D = I.DecisionFactors(1);
  
  PossibleDecisionRules = EnumerateDecisionRules(D);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE
  % 1.  You must find which of the decision rules you have enumerated has the 
  %     highest expected utility.  You should use your implementation of 
  %     SimpleCalcExpectedUtility from P1.  Set the values of MEU and OptimalDecisionRule
  %     to the best achieved expected utility and the corresponding decision
  %     rule respectively.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    D1 = D;
    D2 = D;
    D2.val = [0 1];
    AllDs = [D1 D2];

    allEU = zeros(length(AllDs),1);
    for i=1:length(AllDs)
      I1.DecisionFactors = AllDs(i);
      allEU(i) = SimpleCalcExpectedUtility(I1);
    end

  
end

  
  
  
      
