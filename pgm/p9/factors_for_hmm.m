function factors=factors_for_hmm(P,log_emission_probabilities)
[N,K]=size(log_emission_probabilities);
factors=repmat(EmptyFactorStruct(),1,2*N);
tm=log(P.transMatrix);
for i=1:N
    if i==1
        factors(1).var=[1];
        factors(1).card=[K]; % K poses
        factors(1).val=log(P.c);
    else
        factors(i).var=[i,i-1];
        factors(i).card=[K,K];
        % maybe this could be done with a reshape(tm,1,K*K) but just to be
        % on the safe side...
        n_assigments=K*K;
        assigments=IndexToAssignment(1:n_assigments,factors(i).card);
        for j=1:n_assigments
            factors(i).val(j)=tm(assigments(1),assigments(2));
        end
    end
    factors(i+N).var=i;
    factors(i+N).card=K;
    factors(i+N).val=log_emission_probabilities(i,:);
    

end

