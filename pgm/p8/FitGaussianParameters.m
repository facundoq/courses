function [mu sigma] = FitGaussianParameters(x)
% X: (N x 1): N examples (1 dimensional)
% Fit N(mu, sigma^2) to the empirical distribution
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012


%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%

mu=mean(x);
sigma=std(x,1);