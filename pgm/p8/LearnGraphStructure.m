function [A W] = LearnGraphStructure(dataset)

% Input:
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% 
% Output:
% A: maximum spanning tree computed from the weight matrix W
% W: 10 x 10 weight matrix, where W(i,j) is the mutual information between
%    node i and j. 
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset,1);
K = size(dataset,3);
parts=size(dataset,2);
W = zeros(parts,parts);
% Compute weight matrix W
% set the weights following Eq. (14) in PA description
% you don't have to include M since all entries are scaled by the same M
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE        
%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:parts
    for j=(i+1):parts
        di=squeeze(dataset(:,i,:));
        dj=squeeze(dataset(:,j,:));
        W(i,j)= GaussianMutualInformation(di,dj);
        W(j,i)=W(i,j);
    end
end

% Compute maximum spanning tree
A = MaxSpanningTree(W);