function [J, grad] = costFunctionReg(theta, X, y, lambda)
%COSTFUNCTIONREG Compute cost and gradient for logistic regression with regularization
%   J = COSTFUNCTIONREG(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta.
%               You should set J to the cost.
%               Compute the partial derivatives and set grad to the partial
%               derivatives of the cost w.r.t. each parameter in theta

% Old costFunction
y_hat= sigmoid(X * theta);

error0=log(1-y_hat(y==0));
error1=log(y_hat(y==1));
J= -(sum(error1)+sum(error0))/m;
grad=  (X' * (y_hat-y)) /m ;

% With added regularization:
regularization_penalty= (lambda/(2*m)) * sum (theta(2:end).^2);
J= J + regularization_penalty;
regularization_grad= (lambda/m) * theta;
regularization_grad(1)=0;
grad=grad+regularization_grad;
    

% =============================================================

end
