function result=cartesian(p,q)
[X,Y] = meshgrid(p,q);
result = [X(:) Y(:)];
end