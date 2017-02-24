
clc;
clear;
load PA9SampleCases
load PA9Data

turnOnVisualizations = false;

constTOL = 1e-2;
in=exampleINPUT;
out=exampleOUTPUT;

testPart=2;

fprintf('\n Testing %d ...\n', testPart);
result = true;

switch testPart
    case 1 
      [P, loglikelihood, ClassProb] = EM_cluster(in.t1a1,in.t1a2,in.t1a3,in.t1a4);
      result = isEqualTol(P, out.t1a1, 'P', constTOL) && ...
               isEqualTol(loglikelihood , out.t1a2, 'loglikelihood', constTOL) && ...
               isEqualTol(ClassProb, out.t1a3, 'classprob', constTOL);
    case 2
      [P, loglikelihood, ClassProb, PairProb] = EM_HMM(in.t2a1,in.t2a2,in.t2a3,in.t2a4,in.t2a5,in.t2a6);
      result = isEqualTol(P, out.t2a1, 'P', constTOL) && ...
               isEqualTol(loglikelihood , out.t2a2, 'loglikelihood', constTOL) && ...
               isEqualTol(ClassProb, out.t2a3, 'classprob', constTOL) && ...
               isEqualTol(PairProb, out.t2a4b, 'PairProb', constTOL);
    case 3
      [P, loglikelihood, ClassProb, PairProb] = EM_HMM(in.t2a1b,in.t2a2b,in.t2a3b,in.t2a4b,in.t2a5b,in.t2a6b);
      result = isEqualTol(P, out.t2a1b, 'P', constTOL) && ...
               isEqualTol(loglikelihood , out.t2a2b, 'loglikelihood', constTOL) && ...
               isEqualTol(ClassProb, out.t2a3b, 'classprob', constTOL) && ...
               isEqualTol(PairProb, out.t2a4b, 'PairProb', constTOL);
    case 4
      [accuracy, predicted_labels] = RecognizeActions(in.t3a1,in.t3a2,in.t3a3,in.t3a4);
      result = isEqualTol(accuracy, out.t3a1, 'acc', constTOL) && ...
               isEqualTol(predicted_labels, out.t3a3, 'pred_labels', constTOL);
           
end % end switch

if result
    str = 'Correct';
else
    str = 'Incorrect';
end
fprintf('  -----  %s answer!\n', str);


