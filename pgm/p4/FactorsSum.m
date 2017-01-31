% FactorSum Computes the sum of two factors.
%   C = FactorProduct(A,B) computes the sum between two factors, A and B,
%   where each factor is defined over a set of variables with given dimension.
%   The factor data structure has the following fields:
%       .var    Vector of variables in the factor, e.g. [1 2 3]
%       .card   Vector of cardinalities corresponding to .var, e.g. [2 2 2]
%       .val    Value table of size prod(.card)
%
%   See also FactorMarginalization.m, IndexToAssignment.m, and
%   AssignmentToIndex.m
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function p = FactorsSum(factors)

p=empty_factor();
for i=1:length(factors)
    p=FactorSum(factors(i),p);
end

end
