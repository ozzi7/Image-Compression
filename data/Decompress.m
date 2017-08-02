function I_rec = Decompress(I_compEnc)

% we first decode our input and read the settings. (See Decode.m for
% detailed explanation)
isGrayscale = I_compEnc.settings(7);
if(isGrayscale)
    I_comp = [Decode(I_compEnc.dataUkTransX), Decode(I_compEnc.dataUkTrans)]; 
else
    I_comp = [Decode(I_compEnc.dataRedComp), Decode(I_compEnc.dataGreenComp),...
       Decode(I_compEnc.dataBlueComp), Decode(I_compEnc.dataUkTrans)];
end

% we reed the settings
width = I_compEnc.settings(1);
length = I_compEnc.settings(2);
d = I_compEnc.settings(3);
paddedX = I_compEnc.settings(4);
paddedY = I_compEnc.settings(5);
isColor = I_compEnc.settings(6);

xi = width*length/d^2;

if (isColor == 0) % the image is grayscale
    
    Z = I_comp(:,1:xi); % read out the coefficients
    UkT = I_comp(:,xi+1:xi+d^2); % read out the basis (in its transposed form)
    
    Uk = UkT'; % get real basis

    % we mutliply the basis with the coeffcents, we get the reconstructed
    % image, but it's still int the form of patches as column vectors. We
    % restore it to its original from later
    Tau = Uk * Z;

    I_rec = zeros(width,length);
    
else
    % read the coefficients to the chosen basis of each color channel 
    redCompr = I_comp(:, 1:xi);
    greenCompr = I_comp(:, xi+1:2*xi);
    blueCompr = I_comp(:, 2*xi+1:3*xi);
    
    UkT = I_comp(:, 3*xi+1:3*xi+d^2); % get the basis in transposed form
    
    Uk = UkT'; % get real basis
    
    % we mutliply the basis with the coeffcents, we get the reconstructed
    % image, but it's still int the form of patches as column vectors. We
    % restore it to its original from later
    redTau = Uk * redCompr;
    greenTau = Uk * greenCompr;
    blueTau = Uk * blueCompr;    
    
    red = zeros(width,length);
    green = zeros(width,length);
    blue = zeros(width, length);
    
end


% the following loop contains the code for reconstructing the image to its
% original form. Now each patch is a column vector. We want to write each
% patch to the original place in the original image. 

x = 1;
y = 1;

for i = 1 : width*length/d^2

    if (y > length/d)
        x = x+1;
        y = 1;
    end
    
    if (isColor == 0)
        M = zeros(d,d);
    else
        rM = zeros(d,d);
        gM = zeros(d,d);
        bM = zeros(d,d);
    end

    for j = 1:d
        
        if (isColor == 0)
            M(:,j) = Tau((j-1)*d+1:j*d,i);
        else
            rM(:,j) = redTau((j-1)*d+1:j*d,i);
            gM(:,j) = greenTau((j-1)*d+1:j*d,i);
            bM(:,j) = blueTau((j-1)*d+1:j*d,i);
        end
    end
    
    if (isColor == 0)
        I_rec((x-1)*d+1:x*d, (y-1)*d+1:y*d) = M;
    else
        red((x-1)*d+1:x*d, (y-1)*d+1:y*d) = rM;
        green((x-1)*d+1:x*d, (y-1)*d+1:y*d) = gM;
        blue((x-1)*d+1:x*d, (y-1)*d+1:y*d) = bM;        
    end
    
    y = y+1;

end

% remove the padded rows added in the compression
if (paddedX > 0)
    
    if (isColor == 0)
        I_rec(width-paddedX+1:width,:) = [];
    else
        red(width-paddedX+1:width,:) = [];
        green(width-paddedX+1:width,:) = [];
        blue(width-paddedX+1:width,:) = [];
    end

end

% remove the padded columns added in the compression
if (paddedY > 0)
    
    if (isColor == 0)
        I_rec(:,length-paddedY+1:length) = [];
    else
        red(:,length-paddedY+1:length) = [];
        green(:,length-paddedY+1:length) = [];
        blue(:,length-paddedY+1:length) = [];        
    end

end

% if the image is colored, return it to its orignal 3dimensional form 
if (isColor == 1)
    I_rec(:,:,1) = red;
    I_rec(:,:,2) = green;
    I_rec(:,:,3) = blue;
    
    % We tried using ycbcr as color channels instead of
    % rgb (like jpeg does) but we realized that there was no noticable
    % improvement. To test compression with ycbcr, uncomment the following
    % line and the line at the start of Compress.m:
    %I_rec = ycbcr2rgb(I_rec);
end

end