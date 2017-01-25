function f = SortAllFactors(factors)

for i = 1:length(factors)
    factors(i) = SortFactorVars(factors(i));
end

varMat = vertcat(factors(:).var);
[unused, order] = sortrows(varMat);

f = factors(order);

end
