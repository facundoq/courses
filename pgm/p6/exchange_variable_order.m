function f=exchange_variable_order(f,v1,v2)
    if (v1~=v2)
        v1_index=find(f.var==v1);
        v2_index=find(f.var==v2);
        f=exchange_variable_order_indices(f,v1_index,v2_index);
    end
end

function g=exchange_variable_order_indices(f,v1_index,v2_index)

%[sortedVars, order] = sort(F.var);
%G.var = sortedVars;
order=1:length(f.var);
order=swap(order,v1_index,v2_index);

g.var=swap(f.var,v1_index,v2_index);
g.card=swap(f.card,v1_index,v2_index);
g.val = zeros(1,numel(f.val));

assignmentsInF = IndexToAssignment(1:numel(f.val), f.card);
assignmentsInG = assignmentsInF(:,order);
g.val(AssignmentToIndex(assignmentsInG, g.card)) = f.val;

end

function a=swap(a,i,j)
    t=a(j);
    a(j)=a(i);
    a(i)=t;
end