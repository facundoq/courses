function f = SortAllFactors(factors)
n=length(factors);
for i = 1:n
    factors(i) = SortFactorVars(factors(i));
end
max_variables=0;
for i=1:n
    max_variables=max(max_variables,length(factors(i).var));
end
order_matrix=ones(n,max_variables)*realmax();
for i=1:n
    order_matrix(i,1:length(factors(i).var))=factors(i).var;
end

[unused, order] = sortrows(order_matrix);

%f = factors(order);
f=factors;

end
