function y= logistic_regression_classify(model, x);
y=exp(- x * model)+1;
y=1./y;
