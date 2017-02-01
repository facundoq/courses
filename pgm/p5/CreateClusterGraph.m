%CREATECLUSTERGRAPH Takes in a list of factors and returns a Bethe cluster
%   graph. It also returns an assignment of factors to cliques.
%
%   C = CREATECLUSTERGRAPH(F) Takes a list of factors and creates a Bethe
%   cluster graph with nodes representing single variable clusters and
%   pairwise clusters. The value of the clusters should be initialized to 
%   the initial potential. 
%   It returns a cluster graph that has the following fields:
%   - .clusterList: a list of the cluster beliefs in this graph. These entries
%                   have the following subfields:
%     - .var:  indices of variables in the specified cluster
%     - .card: cardinality of variables in the specified cluster
%     - .val:  the cluster's beliefs about these variables
%   - .edges: A cluster adjacency matrix where edges(i,j)=1 implies clusters i
%             and j share an edge.
%  
%   NOTE: The index of the cluster for each factor should be the same within the
%   clusterList as it is within the initial list of factors.  Thus, the cluster
%   for factor F(i) should be found in P.clusterList(i) 
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CreateClusterGraph(F, Evidence)
P.clusterList = [];
P.edges = [];
for j = 1:length(Evidence),
    if (Evidence(j) > 0),
        F = ObserveEvidence(F, [j, Evidence(j)]);
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=length(F);
variables=unique([F.var]);
n=length(variables);

P.clusterList = F;

P.edges = zeros(k,k);
%indices=[];

%     This is the actual way to generate the Bethe cluster graph, but it
%     would need a graph with k+n nodes, which is not expected by the rest
%     of the code.
%     A way to fake it is to consider consider "columns" of the matrix as
%     variables and rows as factors, and so all factors f that use
%     variable i have P.edges(f,i)=1.
    for i=1:k
    for var=F(i).var 
        if (var~=i)
            P.edges(i,var)=1;
            P.edges(var,i)=1;
        end
    end
    end

% % Another way to implement this is to connect factors that share variables
% for i=1:k
%     for j=i+1:k
%         if ~isempty(intersect(F(i).var,F(j).var))
%             P.edges(i,j)=1;
%             P.edges(j,i)=1;
%         end
%     end
% end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

