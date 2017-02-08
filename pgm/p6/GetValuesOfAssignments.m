function values=GetValuesOfAssignments(F, A, v0)

n=size(A,1);
values=zeros(1,n);
 
for i=1:n
        values(i)=GetValueOfAssignment(F,A(i,:),v0);
end

% 
% if (nargin == 2),    
%     for i=1:n
%         values(i)=GetValueOfAssignment(F,A(i,:));
%     end
% else
%     nargin 
%     V0
%     for i=1:n
%         values(i)=GetValueOfAssignment(F,A(i,:),V0);
%     end
% end;

end
