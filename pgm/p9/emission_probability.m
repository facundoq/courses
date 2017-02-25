function logEmissionProbability = emission_probability(P,G,poseData)
  
  Pu=P;
  Pu.c=ones(size(Pu.c)); % since now we dont have just a bag of poses but a 
  % sequence of them, this just calculates the prob of each class for each
  % pose without a prior P(Pose)
  [poses_loglikelihood, EmissionProb, logEmissionProbability]=ComputeLogLikelihood(Pu,G,poseData);
  
end