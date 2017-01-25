function error=logistic_regression_error(model,x,y)

y_hat=logistic_regression_classify(model,x);
error0=log(1-y_hat(y==0));
error1=log(y_hat(y==1));
error= -(sum(error1)+sum(error0))/length(y);
