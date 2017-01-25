clc;
clear all;
%g=inline('1.0 ./ (1.0 + exp(-z))');

x = load('ex4x.dat');
y = load('ex4y.dat');
[m,features]= size(x);

sigma = std(x);
mu = mean(x);
%x= bsxfun(@minus,x, mu);
%x= bsxfun(@rdivide,x,sigma);
x = [ones(m,1) x];

logistic_regression_optimization_function=@logistic_regression_gradient_descent;
logistic_regression_optimization_function=@logistic_regression_newton;
alphas=[4];%,2,3,4];
iterations=10;
error=zeros(1,iterations);
colors=varycolor(length(alphas));
for a=1:length(alphas)
    model=zeros(size(x,2),1);
    alpha=alphas(a);
    %[first_model,first_error]=logistic_regression_optimize(model,alpha,x,y);
    [first_model,first_error]=logistic_regression_optimization_function(model,alpha,x,y);
    model=first_model;
    for i=1:iterations
        %[model,error(i)]=logistic_regression_optimize(model,alpha,x,y);
        [model,error(i)]=logistic_regression_optimization_function(model,alpha,x,y);
    end
    plot(error,'Color',colors(a,:));
    hold on;
    models(:,a)=model;
end
legend show Location NorthEastOutside
%%


new_x=[20 80];
%new_x= bsxfun(@minus,new_x, mu);
%new_x= bsxfun(@rdivide,new_x,sigma);
new_x=[1 new_x];
new_y=logistic_regression_classify(model,new_x);



