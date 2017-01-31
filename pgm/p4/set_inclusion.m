%set_inclusion(a,b)
% true if all elements of vector a are in vector b
function r=set_inclusion(a,b)
r=all(ismember(a,b));

end