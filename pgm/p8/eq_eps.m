function eq=eq_eps(a,b)
diff=sum(abs(a-b))/ length(a);
eq=diff<(1E-6);

end