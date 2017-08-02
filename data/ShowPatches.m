function ShowPatches( Uk )
%This file displays the patches chosen for compression

d = sqrt(size(Uk,1));
k = size(Uk,2); 

patches = zeros(d,d*k);

for i = 1 : k
    
    M = zeros(d,d);

    for j = 1:d
        
        M(:,j) = Uk((j-1)*d+1:j*d,i);
        
    end
    
    patches(:,(i-1)*d+1:i*d) = M;

end

patches = 10* patches;
figure;
imshow(patches);

end

