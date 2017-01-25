function F = normalizeFactors(F)
for i=1:length(F)
    F(i).val = F(i).val ./ sum(F(i).val);
end;