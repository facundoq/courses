%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
P.edges = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
assignments = zeros(1, length(C.factorList));
for v=1:length(C.factorList)
    for i=1:length(C.nodes)
        if(all(ismember(C.factorList(v).var, C.nodes{i})))
            assignments(v) = i;
            break;
        end;        
    end;    
end;
for i=1:length(C.nodes)
    P.cliqueList(i).var = C.nodes{i};
    factors = C.factorList(assignments == i);
    P.cliqueList(i).card = computeCardinalities(C.factorList, C.nodes{i});
    P.cliqueList(i).val = ones(1, prod(P.cliqueList(i).card));
    for p=1:length(factors)
       P.cliqueList(i) = FactorProduct(P.cliqueList(i), factors(p));
       %P.cliqueList(i) = FactorProduct(factors(p), P.cliqueList(i));
    end;
    %P.cliqueList(i) = reorderFactor(P.cliqueList(i), C.nodes{i});
end;
P.edges = C.edges;


function cards = computeCardinalities(factors, vars)
    cards = zeros(1, length(vars));    
    for p=1:length(factors)
        for v=1:length(factors(p).var)
            index = vars == factors(p).var(v);
            cards(index) = factors(p).card(v);
        end;
    end;
end
end