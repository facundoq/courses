function eq=eq_factors(F1,F2)
    assert(length(F1)==length(F2),'Both factor lists must have the same number of elements');
    eq=true;
    for i=1:length(F1)
        if ~eq_factor(F1(i),F2(i))
            eq=false;
            break;
        end
    end
end

function eq=eq_factor(f1,f2)
eq= eq_eps(f1.var,f2.var) && eq_eps(f1.card,f2.card) && eq_eps(f1.val,f2.val);
end