function [J, grad] = linearRegCostFunction(X, y, theta, lambda)
%LINEARREGCOSTFUNCTION Compute cost and gradient for regularized linear 
%regression with multiple variables
%   [J, grad] = LINEARREGCOSTFUNCTION(X, y, theta, lambda) computes the 
%   cost of using theta as the parameter for linear regression to fit the 
%   data points in X and y. Returns the cost in J and the gradient in grad

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost and gradient of regularized linear 
%               regression for a particular choice of theta.
%
%               You should set J to the cost and grad to the gradient.
%

h=X*theta;
delta= h-y;
c=(1/(2*m));
J= c* dot(delta,delta) ;
r_theta=theta(2:end);
R= c * lambda * dot(r_theta,r_theta);
J=J+R;


c=(1/m);
grad= c * sum(bsxfun(@times,X,delta));
r_grad=c * lambda * [0; r_theta] ; 
grad=grad'+r_grad;








% =========================================================================

grad = grad(:);

end
