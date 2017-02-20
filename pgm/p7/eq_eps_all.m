function eq=eq_eps_all(a,b)
diff=abs(a-b);
eq=all( diff <(1E-4));
 
end