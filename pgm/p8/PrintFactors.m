function PrintFactors(F)

for i=1:length(F)
    fprintf('Factor %d\n',i);
    PrintFactor(F(i));
end