function [ newI] = pad( I,d )

newI = I;

s = size(I);
width = s(1);
length = s(2);

% padd image so width mod d == 0 and length mod d == 0
epsilon = d - mod(width,d);
delta = d - mod(length,d);

if epsilon < d
    
    for i = 1:epsilon
        
        newI(width+i,:) = newI(width,:);
        
    end

end

if delta < d
    
    for i = 1:delta
        
        newI(:,length+i) = newI(:,length);
        
    end

end

end

