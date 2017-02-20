function i=difference_info(a,b)

difference=sum(abs(a-b));
a_l1=sum(abs(a));
b_l1=sum(abs(b));
i=sprintf('Difference=%f, a l1=%f, b l1= %f\n', difference,a_l1,b_l1);
end