    % CLUSTERGRAPHCALIBRATE Loopy belief propagation for cluster graph calibration.
    %   P = CLUSTERGRAPHCALIBRATE(P, useSmart) calibrates a given cluster graph, G,
    %   and set of of factors, F. The function returns the final potentials for
    %   each cluster. 
    %   The cluster graph data structure has the following fields:
    %   - .clusterList: a list of the cluster beliefs in this graph. These entries
    %                   have the following subfields:
    %     - .var:  indices of variables in the specified cluster
    %     - .card: cardinality of variables in the specified cluster
    %     - .val:  the cluster's beliefs about these variables
    %   - .edges: A cluster adjacency matrix where edges(i,j)=1 implies clusters i
    %             and j share an edge.
    %  
    %   UseSmart is an indicator variable that tells us whether to use the Naive or Smart
    %   implementation of GetNextClusters for our message ordering
    %
    %   See also FACTORPRODUCT, FACTORMARGINALIZATION
    %
    % Copyright (C) Daphne Koller, Stanford University, 2012

function [P messages] = ClusterGraphCalibrate(P,useSmartMP)

if(~exist('useSmartMP','var'))
  useSmartMP = 0;
end

N = length(P.clusterList);

messages= repmat(struct('var', [], 'card', [], 'val', []), N, N);
[edgeFromIndx, edgeToIndx] = find(P.edges ~= 0);
%imshow(P.edges);

for m = 1:length(edgeFromIndx),
    from = edgeFromIndx(m);
    to = edgeToIndx(m);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %
    %
    %
    % Set the initial message values
    % messages(i,j) should be set to the initial value for the
    % message from cluster i to cluster j
    %
    % The matlab/octave functions 'intersect' and 'find' may
    % be useful here (for making your code faster)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    from_factor=P.clusterList(from);
    to_factor=P.clusterList(to);
    newm.var=intersect(from_factor.var,to_factor.var);
    
    newm.card=from_factor.card(ismember(from_factor.var,newm.var));
    newm.val=ones(1,prod(newm.card));
    messages(to,from)=newm;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;



% perform loopy belief propagation
tic;
iteration = 0;

lastMessages = messages;

while (1),
    iteration = iteration + 1;
    [from, to] = GetNextClusters(P, messages,lastMessages, iteration, useSmartMP); 
    prevMessage = messages(from,to);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    % We have already selected a message to pass, \delta_ij.
    % Compute the message from clique i to clique j and put it
    % in messages(i,j)
    % Finally, normalize the message to prevent overflow
    %
    % The function 'setdiff' may be useful to help you
    % obtain some speedup in this function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m=compute_message(P.clusterList,P.edges,messages,from,to,false);
    messages(from,to)=m;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(useSmartMP==1)
      lastMessages(from,to)=prevMessage;
    end
    
    % Check for convergence every m iterations
    if mod(iteration, length(edgeFromIndx)) == 0
        if (CheckConvergence(messages, lastMessages))
            break;
        end
        disp(['LBP Messages Passed: ', int2str(iteration), '...']);
        if(useSmartMP~=1)
          lastMessages=messages;
        end
    end
    
end;
toc;
disp(['Total number of messages passed: ', num2str(iteration)]);


% Compute final potentials and place them in P
for m = 1:length(edgeFromIndx),
    to = edgeFromIndx(m);
    from = edgeToIndx(m);
    P.clusterList(from) = FactorProduct(P.clusterList(from), messages(to, from));
end

end

% Get the max difference between the marginal entries of 2 messages -------
function delta = MessageDelta(Mes1, Mes2)
delta = max(abs(Mes1.val - Mes2.val));
return;
end

function m=compute_message(cliqueList,edges,messages,from,to,isMax)
    %n=length(cliqueList);
    from_clique=cliqueList(from);
    to_clique=cliqueList(to);
    input_cliques= edges(:,from)==1;
    input_cliques(to)=0; % remove to from this list
    
    input_messages=messages(input_cliques,from);
    
    intersection_variables=intersect(from_clique.var,to_clique.var);
    variables_to_eliminate=setdiff(from_clique.var,intersection_variables);
    
    if (isMax)
        unmarginalized_factor=FactorSum(from_clique,FactorsSum(input_messages));
        m=FactorMaxMarginalization(unmarginalized_factor,variables_to_eliminate);
    else
        unmarginalized_factor=FactorProduct(from_clique,FactorsProduct(input_messages));
        m=FactorMarginalization(unmarginalized_factor,variables_to_eliminate);
        m=normalize_factor(m);
    end
    
    
end
