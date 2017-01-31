%GETNEXTCLIQUES Find a pair of cliques ready for message passing
%   [i, j] = GETNEXTCLIQUES(P, messages) finds ready cliques in a given
%   clique tree, P, and a matrix of current messages. Returns indices i and j
%   such that clique i is ready to transmit a message to clique j.
%
%   We are doing clique tree message passing, so
%   do not return (i,j) if clique i has already passed a message to clique j.
%
%	 messages is a n x n matrix of passed messages, where messages(i,j)
% 	 represents the message going from clique i to clique j. 
%   This matrix is initialized in CliqueTreeCalibrate as such:
%      MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
%
%   If more than one message is ready to be transmitted, return 
%   the pair (i,j) that is numerically smallest. If you use an outer
%   for loop over i and an inner for loop over j, breaking when you find a 
%   ready pair of cliques, you will get the right answer.
%

%   If no such cliques exist, returns i = j = 0.
%
%   See also CLIQUETREECALIBRATE
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function [i, j] = GetNextCliques(P, messages)

% initialization
% you should set them to the correct values in your code
i = 0;
j = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=size(messages,1);
edges=P.edges;

for from=1:N
    [messages_to_receive,messages_to_send]=remaining_messages(from,messages,edges);
    
    if ~((messages_to_receive<=1) && (messages_to_send>0))
        continue;% need to receive all messages except maybe one from the "to" clique
    end
%         k
%         edges(k,:)
%         edges(:,k)
    for to=1:N
        %
        if ~(edges(from,to) && isempty(messages(from,to).var)) 
            continue; % if message has already been sent do nothing
        end
        if (messages_to_receive==1 && ~(isempty(messages(to,from).var)))
            continue; % if the remaining message is not from clique "to" do nothing
        end
        i=from;
        j=to;
        return;
    end
end

end

%counts how many messages those clique "clique" still needs to send or receive
function [messages_to_receive,messages_to_send]=remaining_messages(clique,messages,edges)
N=size(messages,1); 

messages_to_receive=0;
messages_to_send=0;
for i=1:N
    if edges(i,clique) 
        if isempty(messages(i,clique).var)
            messages_to_receive=messages_to_receive+1;
%             fprintf('Need to recv message from %d to %d\n',i,clique);
        end
        if isempty(messages(clique,i).var)
%             fprintf('Need to send message from %d to %d\n',clique,i);
            messages_to_send=messages_to_send+1;
        end
    end
end

end