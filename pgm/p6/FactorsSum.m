function u=FactorsSum(us)

u=us(1);

for i=2:length(us)
    u=FactorSum(u,us(i));
end

end