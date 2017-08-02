function [ mu, lamda, U ] = PCAanalyse( X )
% computes the covariance matrix of X, then applies the eigenvalue
% decomposition to get a matrix of eigenvectors U and their corresponding
% eigenvalues lamda.

sigma = cov(X');

[U, lamda] = eig(sigma);

mu = 333; % not needed

%plotEigenvalues(lamda);

end

