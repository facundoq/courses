%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
messages = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isMax
 for i=1:length(P.cliqueList)
     P.cliqueList(i).val=log(P.cliqueList(i).val);
 end
end
 
[from,to]=GetNextCliques(P,messages);
while ([from,to]~=[0,0])
    %TODO update message
    m=compute_message(P.cliqueList,P.edges,messages,from,to,isMax);
    messages(from,to)=m;
    [from,to]=GetNextCliques(P,messages);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P=final_potentials(P.cliqueList,P.edges,messages,isMax);

return
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

function p=final_potentials(cliqueList,edges,messages,isMax)

n=length(cliqueList);
newCliqueList=repmat(empty_factor(),1, n);

for from=1:n
    from_clique=cliqueList(from);
    input_cliques=edges(:,from)==1;
    input_messages=messages(input_cliques,from);
    if (isMax)
       newCliqueList(from)=FactorSum(from_clique,FactorsSum(input_messages));
    else
       newCliqueList(from)=FactorProduct(from_clique,FactorsProduct(input_messages));
    end
end

p.cliqueList=newCliqueList;
p.edges=edges;

end
