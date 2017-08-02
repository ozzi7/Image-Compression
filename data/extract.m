function X = extract( I, d )

s = size(I);
width = s(1);
length = s(2);

xi = width*length/d^2;

X = zeros(d^2,xi);
count = 0;

for i = 0:(width/d-1)
    
    for j = 0:(length/d-1)
        
        count = count + 1;
        
        firstx = i*d + 1;
        firsty = j*d + 1;
        
        M = I(firstx:(firstx+d-1),firsty:(firsty+d-1));
        
        X(:,count) = M(:);
        
    end
    
end

