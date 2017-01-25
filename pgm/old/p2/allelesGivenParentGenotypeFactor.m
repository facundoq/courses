function alleleFactor = allelesGivenParentGenotypeFactor(numAlleles, geneVarChild, geneVarParentOne, geneVarParentTwo)

alleleFactor = struct('var', [geneVarChild, geneVarParentOne, geneVarParentTwo], 'card', [numAlleles numAlleles numAlleles], 'val', []);
alleleFactor.val = zeros(1, prod(alleleFactor.card));

for i=1:numAlleles
    for j=1:numAlleles
        for k=1:numAlleles
            gene_index = AssignmentToIndex([k i j], alleleFactor.card);
            if i == k
               alleleFactor.val(gene_index) = alleleFactor.val(gene_index) + 0.5;
            end;
            if j == k
               alleleFactor.val(gene_index) = alleleFactor.val(gene_index) + 0.5;
            end;
        end;
    end;
end;


