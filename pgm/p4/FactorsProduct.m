function p=FactorsProduct(factors)
p=empty_factor();
for i=1:length(factors)
    p=FactorProduct(factors(i),p);
end