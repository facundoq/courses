function error=linear_regression_error(model,x,y)

y_hat=linear_regression_classify(model,x);
error = mean((y_hat-y).^2)/2;