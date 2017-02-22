
clc;
clear;
load PA8SampleCases
load PA8Data

turnOnVisualizations = false;

constTOL = 1e-2;


testPart=7;

fprintf('\n Testing %d ...\n', testPart);
result = true;

switch testPart
    case 1 % FitGaussianParameters
      [Output.t1o1 Output.t1o2] = FitGaussianParameters( exampleINPUT.t1a1 ); 
      result = isEqualTol(Output.t1o1, exampleOUTPUT.t1o1, 'Output.t1o1', constTOL) && ...
               isEqualTol(Output.t1o2, exampleOUTPUT.t1o2, 'Output.t1o2', constTOL);

    case 2 % FitLinearGaussianParameters
      [Output.t2o1 Output.t2o2] = FitLinearGaussianParameters( exampleINPUT.t2a1, exampleINPUT.t2a2 );
      result = isEqualTol(Output.t2o1, exampleOUTPUT.t2o1, 'Output.t2o1', constTOL) && ...
               isEqualTol(Output.t2o2, exampleOUTPUT.t2o2, 'Output.t2o2', constTOL);

    case 3 % ComputeLogLikelihood
      if turnOnVisualizations
        VisualizeDataset(trainData.data);
      end

      Output.t3 = ComputeLogLikelihood( exampleINPUT.t3a1, exampleINPUT.t3a2, exampleINPUT.t3a3 );
      result = isEqualTol(Output.t3, exampleOUTPUT.t3, 'Output.t3', constTOL);

    case 4 % LearnCPDsGivenGraph
      [Output.t4o1 Output.t4o2] = ...
          LearnCPDsGivenGraph(exampleINPUT.t4a1, exampleINPUT.t4a2, exampleINPUT.t4a3);
      result = isEqualTol(Output.t4o1, exampleOUTPUT.t4o1, 'Output.t4o1', constTOL) && ...
               isEqualTol(Output.t4o2, exampleOUTPUT.t4o2, 'Output.t4o2', constTOL);

    case 5 % ClassifyDataset
      Output.t5 = ClassifyDataset(exampleINPUT.t5a1, exampleINPUT.t5a2, ...
                                exampleINPUT.t5a3, exampleINPUT.t5a4);
      result = isEqualTol(Output.t5, exampleOUTPUT.t5, 'Output.t5', constTOL);

      if turnOnVisualizations
        VisualizeModels(exampleINPUT.t5a3, exampleINPUT.t5a4);
      end

      %Compare structure G1 (no edges) and G2 (tree)
      fprintf('\n- Measuring accuracy for Naive Bayes model\n');
      [P1 ~] = LearnCPDsGivenGraph(trainData.data, G1, trainData.labels);
      accuracyNaiveBayes = ClassifyDataset(exampleINPUT.t5a1, exampleINPUT.t5a2, P1, G1);
      if turnOnVisualizations
        VisualizeModels(P1, G1);
      end

      fprintf('\n- Measuring accuracy for CLG model\n');
      [P2 ~] = LearnCPDsGivenGraph(trainData.data, G2, trainData.labels);
      accuracyCLG = ClassifyDataset(exampleINPUT.t5a1, exampleINPUT.t5a2, P2, G2);
      if turnOnVisualizations
        VisualizeModels(P2, G2);   
      end

      result = result && ( abs(accuracyNaiveBayes - 0.79) <= 0.01 ) && ...
          ( abs(accuracyCLG - 0.84) <= 0.01 );

    case 6 % LearnGraphStructure
      [Output.t6o1 Output.t6o2] = LearnGraphStructure( exampleINPUT.t6a1 );
      result = isEqualTol(Output.t6o1, exampleOUTPUT.t6o1, 'Output.t6o1', constTOL) && ...
               isEqualTol(Output.t6o2, exampleOUTPUT.t6o2, 'Output.t6o2', constTOL);

    case 7 % LearnGraphAndCPDs
      [Output.t7o1 Output.t7o2 Output.t7o3] = ...
          LearnGraphAndCPDs( exampleINPUT.t7a1, exampleINPUT.t7a2 );
      result = isEqualTol(Output.t7o1, exampleOUTPUT.t7o1, 'Output.t7o1', constTOL) && ...
               isEqualTol(Output.t7o2, exampleOUTPUT.t7o2, 'Output.t7o2', constTOL) && ...
               isEqualTol(Output.t7o3, exampleOUTPUT.t7o3, 'Output.t7o3', constTOL);
    case 8 
        
      % Compare accuracy and likelihood from test 5 with accuracy for model
      % with separate graphs
      fprintf('\n- Measuring accuracy for CLG model with separate graphs structures learned from data\n');
      [P3 G3 ~] = LearnGraphAndCPDs(trainData.data, trainData.labels);
      accuracyWithLearnedGraphStructure = ClassifyDataset(testData.data, testData.labels, P3, G3);
      if turnOnVisualizations
        VisualizeModels(P3, G3);
      end
      result = abs(accuracyWithLearnedGraphStructure - 0.93) <= 0.01 ;

end % end switch

if result
    str = 'Correct';
else
    str = 'Incorrect';
end
fprintf('  -----  %s answer!\n', str);


