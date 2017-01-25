clc;
clear all;

x = load('ex2x.dat');
y = load('ex2y.dat');

% figure % open a new figure window
% plot(x, y, 'o');
% ylabel('Height in meters')
% xlabel('Age in years')

m= length(y);
x = [ones(m,1) x];


alpha=0.07;

for a=0.01:0.01:0.2
    model=zeros(size(x,2),1);
    [first_model,first_error]=linear_regression_gradient_descent(model,alpha,x,y);
    model=first_model;
    for i=1:1500
        [model,error(i)]=linear_regression_gradient_descent(model,alpha,x,y);
    end 
end