clc;
clear all;

x = load('ex3x.dat');
y = load('ex3y.dat');
[m,features]= size(x);
sigma = std(x);
mu = mean(x);
x= (x - ones(m,1)* mu)./ (ones(m,1)*sigma);

% figure % open a new figure window
% plot(x, y, 'o');
% ylabel('Height in meters')
% xlabel('Age in years')


x = [ones(m,1) x];



alphas=0.01:1:5;
for alpha=alphas
    alpha=0.07;
    model=zeros(size(x,2),1);
    [first_model,first_error]=linear_regression_gradient_descent(model,alpha,x,y);
    model=first_model;
    for i=1:3000
        [model,error(i)]=linear_regression_gradient_descent(model,alpha,x,y);
    end
    plot(error);
    %hold on;
end

x_new=[1650 3];
x_new= (x_new - mu)./ sigma;
x_new=[1 x_new];
y_new= linear_regression_classify(model, x_new);

model_normal= inv(x' *x) * (x'* y);