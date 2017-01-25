function eq=eq_eps(a,b)

eq=sum(abs(a-b))<(eps*1E2);

end