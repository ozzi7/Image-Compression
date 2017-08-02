function step_by_step_pca()

x = mnd(100,2,[5 5],[5 4;2 2])';
str = '1. Original data';
disp(str)
figure('Name',str,'NumberTitle','off')
scatter(x(1,:),x(2,:));
add_lines();
pause

mu = mean(x,2);
x_bar = x-repmat(mu,1,size(x,2));

str = '2. Center data';
disp(str)
figure('Name',str,'NumberTitle','off')
scatter(x_bar(1,:),x_bar(2,:));
add_lines();
pause


str = '3. plot eigen vectots scaled by eigen values';
disp(str)
figure('Name',str,'NumberTitle','off')
scatter(x_bar(1,:),x_bar(2,:));
add_lines();
plot_eigen_vectors(cov(x_bar'));
pause

str = '4. Represent the centered data in the eigen vectors space';
disp(str)
figure('Name',str,'NumberTitle','off')

[U, lambda] = eig(cov(x_bar'));
lambda_vec = diag(lambda);
[sorted_lambdas, ind] = sort(lambda_vec,'descend');
U = U(:,ind); %sort matrix

Z_bar = U'*x_bar;
scatter(Z_bar(1,:),Z_bar(2,:));
add_lines();
plot_eigen_vectors(cov(Z_bar'));
pause


str = '5. Shift back the transformed data';
disp(str)
figure('Name',str,'NumberTitle','off')
Z = Z_bar + repmat(mu,1,size(x,2));
scatter(Z(1,:),Z(2,:));
add_lines();
plot_eigen_vectors(cov(Z_bar'));

disp('original eigen vectors')
U

disp('Lets keep just the eigenvector corresponding to the highest eigenvalue.. ')
Uk = U(:,1);
Uk 
Zk_bar = Uk'*x_bar;
pause

str = '6. Projecting using the k-highest eigenvectors corresponds to a k-rank approximation of the data.'; 
disp(str)
figure('Name',str,'NumberTitle','off')
scatter(Zk_bar,zeros(size(Zk_bar)));
add_lines();
pause


str = '7. Reconstruct the original data';
disp(str)
figure('Name',str,'NumberTitle','off')
X_bar_rec = Uk*Zk_bar;
scatter(X_bar_rec(1,:),X_bar_rec(2,:));
add_lines();
pause

str = '8. Shift back the reconstructed data';
disp(str)
figure('Name',str,'NumberTitle','off')
X_rec = X_bar_rec + repmat(mu,1,size(x,2));
scatter(X_rec(1,:),X_rec(2,:));
add_lines();
pause

end


function add_lines()

	ylim([-20,20]);
	xlim([-20,20]);
	hold on
	plot([-20,20],[0,0],'k-');
	plot([0,0],[-20,20],'k-');
end

function plot_eigen_vectors(mat)

	[U, lambda] = eig(mat);
	lambda_vec = diag(lambda);
	[sorted_lambdas, ind] = sort(lambda_vec,'descend');

	%eigen vectors in the columns 
	Us = U(:,ind); %sorted matrix
	hold on
	scale_f = 5;
	plot(sorted_lambdas(1)*[0,Us(1,1)], sorted_lambdas(1)*[0,Us(2,1)],'r--');
	plot(scale_f*sorted_lambdas(2)*[0,Us(1,2)], scale_f*sorted_lambdas(2)*[0,Us(2,2)],'r--');
end

function x = mnd(N,d,rmean,covariance)
	%Generates a Multivariate Normal Distribution

	[rowsm, colsm] = size(rmean);
	lengthmean = length(rmean);
	[rowsv, colsv] = size(covariance);

	if rowsv ~= colsv 
	    error('Covariance matrix should be square')
	end
	if lengthmean ~= rowsv
	    error('The dimension of the requested mean is not equal to the dimensions of the covariance')
	end
	if d ~= lengthmean
	    error('The mean should have the same dimension as the requested samples')
	end

	if N < 1
	    N=1;
	end

	N=fix(N);

	if (colsm==1)  
	    rmean=rmean';
	end

	x = randn(N,d);  %generate the samples using built in Matlab function
	xmean = mean(x); %calculate the sample mean

	%subtract off the mean when N > 1. This removes any mean from the Matlab generated numbers
	if N>1
	 x=x-repmat(xmean,[N,1]);
	end

	[R,p]=chol(covariance);
	if p>0
	    x=x*sqrtm(covariance);
	else
	    x=x*R;
	end

	x= x+repmat(rmean,[N,1]);
end
