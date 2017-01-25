function [new_model,error]=logistic_regression_newton(model,parameters,x,y)

yhat=logistic_regression_classify(model,x);
dy=yhat-y;
de= mean(bsxfun(@times,x,dy));
dde_y=yhat.*(1-yhat);
[samples,features]=size(x);
hessian=zeros(features);
for i=1:size(x,samples)
   hessian=hessian+ dde_y(i) * (x(i,:)' * x(i,:));
end
hessian=hessian/length(y);

hessian = (1/length(y)).*x' * diag(yhat) * diag(1-yhat) * x;

new_model=model- hessian \ de';
error=logistic_regression_error(model,x,y);
