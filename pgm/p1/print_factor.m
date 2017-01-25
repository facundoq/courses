function result=print_factor(factor)

result=[factor.var 0];
n=length(factor.val);
assignments=IndexToAssignment(1:n,factor.card);
values=zeros(n,1);
for i=1:n
    values(i)=factor.val(AssignmentToIndex(assignments(i,:),factor.card));
end

result=[result; [assignments values]];
