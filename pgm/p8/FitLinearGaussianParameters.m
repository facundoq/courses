function [Beta, sigma] = FitLinearGaussianParameters(X, U)

% Estimate parameters of the linear Gaussian model:
% X|U ~ N(Beta(1)*U(1) + ... + Beta(n)*U(n) + Beta(n+1), sigma^2);

% Note that Matlab/Octave index from 1, we can't write Beta(0).
% So Beta(n+1) is essentially Beta(0) in the text book.

% X: (M x 1), the child variable, M examples
% U: (M x N), N parent variables, M examples
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

M = size(U,1);
N = size(U,2);


% collect expectations and solve the linear system
% A = [ E[U(1)],      E[U(2)],      ... , E[U(n)],      1     ; 
%       E[U(1)*U(1)], E[U(2)*U(1)], ... , E[U(n)*U(1)], E[U(1)];
%       ...         , ...         , ... , ...         , ...   ;
%       E[U(1)*U(n)], E[U(2)*U(n)], ... , E[U(n)*U(n)], E[U(n)] ]

% construct A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=zeros(N+1,N+1);
mU=mean(U,1);
a(1,:)=[mU 1];
a(2:end,end)=mU';
UU=U'*U;
a(2:end,1:end-1)=UU/M;

% B = [ E[X]; E[X*U(1)]; ... ; E[X*U(n)] ]

% construct B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UX= U'*X;
b=[mean(X); UX/M];

% solve A*Beta = B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Beta= a\b;

% then compute sigma according to eq. (11) in PA description
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
covU=cov(U);
betaMatrix=Beta(1:N)*Beta(1:N)';

sigmaU= covU.*betaMatrix;
sigmaU=sum(sum(sigmaU));
sigmaX=var(X);
sigma=sqrt(sigmaX-sigmaU);

%sigma=1.524499;