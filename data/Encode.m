% Encodes matrix in custom binary sequence
% k = number of fraction bits to keep, max 23
% epsilon = if distance to 0 smaller than epsilon -> round to 0
function I_enc = Encode(I,fracBits,epsilon)

% Convert doubles to float
M = single(I);
% Round floats to 0.0 if closer than epsilon
indices = find(abs(M)<epsilon);
M(indices) = single(0);

nofRows = size(M,1);
nofCols = size(M,2);

% Convert matrix to column vector, cast to unsignedInt
% -> Some binary ops work only on integers
M = M(:);
M = typecast(M,'uint32');

% signmask 1000000.. expMask 011111111000..
signMask = bitshift(uint32(1),31);
expMask = bitshift(uint32(255),23);
fractionMask = bitshift(bitshift(uint32(intmax),32-fracBits),-9);
% create matrix which only stores exponents
f = @(a) (bitshift(bitand(a,expMask),-23));
f2 = @(a) (bitshift(bitand(a,signMask),-31));
f3 = @(a) (bitshift(bitand(a,fractionMask),-(32-fracBits-9)));
exponents = arrayfun(f, M);
signs = arrayfun(f2,M);
fractionBits = arrayfun(f3,M);

% DEBUG
% I(1:10,1,1)
% exponents(1:10,1,1)
% signs(1:10,1,1)
% fractionBits(1:10,1,1)

% Find difference between min and max exponent values
% Note: 0 has exponent 00000000, ignore it (we set flags for 0)
[maxExp, maxExpInd] = max(exponents);
[minExp, minExpInd] = min(exponents(exponents ~= 0));
newBias = 127 -minExp; %Convert back: current exp - newBias + 127

% Find number of bits required
if(maxExp-minExp == 0)
    expBitsRequired = 0;
else
    expBitsRequired = floor(log2(double(int32(maxExp-minExp)))) + 1;
end

% Calculate new exponents (Note that exponents are unsigned -> 0000.. is now
% 000 again)
for k=1:length(exponents)
    exponents(k)=exponents(k)+newBias;
    exponents(k)=exponents(k)-127;
end

% create binary stream
% 4 bits to store max exp bits needed
% 5 bits to store length of fraction bits
% 12 bits to store number of rows 
% 7 bits to sore newBias for exponent
% 12 bits to store number of cols 
% for each entry: 1 bit for 0 or not, 1 bit for negativ or not
% some bits for exp (specified in param)
% k bits for fraction
params = uint32(0);

for k = 0:3
    if(bitget(expBitsRequired,4-k) == 1)
        params = bitset(params, 32-k);
    end
end
for k = 0:4
    if(bitget(fracBits,5-k) == 1)
        params = bitset(params, 32-4-k);
    end
end
for k = 0:11
    if(bitget(nofRows,12-k) == 1)
        params = bitset(params, 32-4-5-k);
    end
end
for k = 0:6
    if(bitget(newBias,7-k) == 1)
        params = bitset(params, 32-4-5-12-k);
    end
end
% Assuming no compression -> max matrix size we would need
I_enc_temp = uint32(zeros(nofRows* nofCols,1));
I_enc_temp(1) = params;

params = uint32(0);
for k = 0:20
    if(bitget(nofCols,21-k) == 1)
        params = bitset(params, 32-k);
    end
end
I_enc_temp(2) = params;

% Note: fraction, exp are reversed compared to params entries
currentPos = 1;
newVal = uint32(0);

currIndex = 3;
for k = 1:length(M)
    if(M(k) == 0)
        % if value is zero set 0-flag to 1
        newVal = bitset(newVal,currentPos);
        updateCurrentBit;
    else
        updateCurrentBit;
        if(signs(k) == 1)
            % if value negativ set sign flag
            newVal = bitset(newVal,currentPos);
        end
        updateCurrentBit;
        % safe exponent part
        for h = 1:expBitsRequired
            if(bitget(exponents(k),h) == 1)
                newVal = bitset(newVal,currentPos);
            end
            updateCurrentBit;
        end
        % safe fraction part
        for h = 1:fracBits
            if(bitget(fractionBits(k),h) == 1)
                newVal = bitset(newVal,currentPos);
            end
            updateCurrentBit;
        end
    end
end
% currIndex is 1 above last element in vector
I_enc_temp(currIndex) = newVal;
I_enc = I_enc_temp(1:currIndex);
    function updateCurrentBit
     if(currentPos == 32)
         currentPos = 1;
         I_enc_temp(currIndex) = newVal;
         currIndex = currIndex +1;
         newVal = uint32(0);
     else
        currentPos = currentPos +1;
     end
    end
end





