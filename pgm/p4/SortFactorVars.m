function G = SortFactorVars(F)

[sortedVars, order] = sort(F.var);
G.var = sortedVars;
% if (isrow(G.var))
%     G.var=G.var';
% end

G.card = F.card(order);
G.val = zeros(1,numel(F.val));

assignmentsInF = IndexToAssignment(1:numel(F.val), F.card);
assignmentsInG = assignmentsInF(:,order);
G.val(AssignmentToIndex(assignmentsInG, G.card)) = F.val;

end
