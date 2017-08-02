% Decodes matrix from custom binary sequence to float matrix
% Enc/Dec R,G,B separately, handles 2D matrices only
function I_dec = Decode(Encoded)

% Read parameters
params = Encoded(1);
params2 = Encoded(2);
expBitsRequired = uint32(0);
fracBits = uint32(0);
nofRows = uint32(0);
nofCols = uint32(0);
newBias = uint32(0);
for k = 0:3
    if(bitget(params,32-k) == 1)
        expBitsRequired = bitset(expBitsRequired, 4-k);
    end
end
for k = 0:4
    if(bitget(params,32-4-k) == 1)
        fracBits = bitset(fracBits, 5-k);
    end
end
for k = 0:11
    if(bitget(params,32-4-5-k) == 1)
        nofRows = bitset(nofRows, 12-k);
    end
end
for k = 0:20
    if(bitget(params2,32-k) == 1)
        nofCols = bitset(nofCols, 21-k);
    end
end
for k = 0:6
    if(bitget(params,32-4-5-12-k) == 1)
        newBias = bitset(newBias, 7-k);
    end
end

% Note: fraction, exp are reversed compared to params entries
currentPos = 1;
newVal = uint32(0); % binary ops only defined on integers
I_dec_vec = uint32(zeros(nofRows*nofCols,1));
k = 3;

currIndex = 0;
while(true)
    currIndex = currIndex + 1;
    if(currIndex > nofCols*nofRows)
     break; % add no more values
    else
        if(bitget(Encoded(k),currentPos) == 1)
            % if 0 flag is 1 create 0
            I_dec_vec(currIndex) = 0;
            updateCurrentBit;
        else
            updateCurrentBit;
            if(bitget(Encoded(k),currentPos) == 1)
                % sign flag 1 -> negative
                newVal = bitset(newVal,32);
            end
            updateCurrentBit;
            % get exponent
            exponentTemp = uint32(0);
            for h = 1:expBitsRequired
                if(bitget(Encoded(k),currentPos) == 1)
                    exponentTemp = bitset(exponentTemp,h);
                end
                updateCurrentBit;
            end
            originalExponent = (exponentTemp + 127)-newBias;
            newVal = bitor(newVal,bitshift(originalExponent,23));
            % get fraction part
            tempFraction = uint32(0);

            for h = 1:fracBits
                if(bitget(Encoded(k),currentPos) == 1)
                    tempFraction = bitset(tempFraction,h);
                end
                updateCurrentBit;
            end       
            newVal = bitor(newVal,bitshift(tempFraction,23-fracBits));
            
            I_dec_vec(currIndex) = newVal;
            newVal = uint32(0);
        end
    end
end
    function updateCurrentBit
     if(currentPos == 32)
         currentPos = 1;
         k = k + 1;
     else
         currentPos = currentPos +1;
     end
    end 
I_dec_vec = typecast(I_dec_vec,'single');
I_dec = vec2mat(I_dec_vec,nofRows);
I_dec = transpose(I_dec);
end





