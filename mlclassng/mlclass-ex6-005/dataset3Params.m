function [C, sigma] = dataset3Params(X, y, Xval, yval)
%EX6PARAMS returns your choice of C and sigma for Part 3 of the exercise
%where you select the optimal (C, sigma) learning parameters to use for SVM
%with RBF kernel
%   [C, sigma] = EX6PARAMS(X, y, Xval, yval) returns your choice of C and 
%   sigma. You should complete this function to return the optimal C and 
%   sigma based on a cross-validation set.
%

% You need to return the following variables correctly.
C = 1;
sigma = 0.3;

% ====================== YOUR CODE HERE ======================
% Instructions: Fill in this function to return the optimal C and sigma
%               learning parameters found using the cross validation set.
%               You can use svmPredict to predict the labels on the cross
%               validation set. For example, 
%                   predictions = svmPredict(model, Xval);
%               will return the predictions on the cross validation set.
%
%  Note: You can compute the prediction error using 
%        mean(double(predictions ~= yval))
%

values=[0.01,0.03,0.1,0.3,1,3,10,30];
min_error=flintmax();
min_values=[0 0];
for cs=values
    for sigmas=values
        model= svmTrain(X, y, cs, @(x1, x2) gaussianKernel(x1, x2, sigmas)); 
        predictions = svmPredict(model, Xval);
        error=mean(double(predictions ~= yval));
        if (error<min_error)
            min_error=error;
            min_values=[cs,sigmas];
        end
    end
    
end

C= min_values(1);
sigma= min_values(2);



% =========================================================================

end
