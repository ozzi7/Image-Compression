function k = FindBestBasis( lamdaIn, threshold )
%FindBestBasis

eigenvalues = diag(lamdaIn);
eigenvalues = eigenvalues';
lamda = fliplr(eigenvalues);

%plotEigenvalues(lamdaIn);

total = sum(lamda);

count = 0;

for i = 1:size(lamda,2)
    
    count = count + lamda(i);
    
    if ( count > threshold*total)
        k = i;
        break;
    end 
    
end

end

