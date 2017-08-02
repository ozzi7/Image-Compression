function I_comp =  Compress(I) %Compress(I, d)

d = 12; % size of patch
threshold = 0.99; % threshold for selecting eigenvectors for basis

sizeOrig = size(I);

if (ndims(I) == 2) % the image is Grayscale
    
    newI = pad(I,d); % pad the image, so that length and width of I mod d = 0
   
    % extract the features, i.e. restructure the image with patches as column vectors
    X = extract (newI, d);

    % make Principal Components Analysis with Eigenvalue decomposition
    [mu, lamda, U] = PCAanalyse(X); 
    
    % find the best amount of basis vectors
    k = FindBestBasis(lamda, threshold);

    Uk = U(:,size(U,2)-k+1:size(U,2)); % form Basis from k best eigenvectors
    
     %k
    %ShowPatches(Uk);

    % the compression consists of the Coefficients for the basis Uk for our
    % image and the basis itself. This is all we need to reconstruct our
    % image
    I_comp.dataUkTransX = Encode((Uk' * X), 5, 0.15);
    I_comp.dataUkTrans = Encode((Uk'), 6, 0.01);
    
    % set values for settings
    sizeNew = size(newI);
    isColor = 0;
    
else % the image is color
    
    % We tried using ycbcr as color channels instead of
    % rgb (like jpeg does) but we realized that there was no noticable
    % improvement. To test compression with ycbcr, uncomment the following
    % line and the line at the end of Decompress.m:
    % I = rgb2ycbcr(I);
    
    % pad the rgb part of the image, so that length and width of I mod d = 0
    paddedRed = pad(I(:,:,1),d);
    paddedGreen = pad(I(:,:,2),d);
    paddedBlue = pad(I(:,:,3),d);
    
    % extract the features, i.e. restructure the image with patches as column vectors
    red = extract(paddedRed, d);
    green = extract(paddedGreen, d);
    blue = extract(paddedBlue,d);
    
    % in the following we do this: We know that the bases gained by pca are
    % very similar for the 3 channels of the image, rgb. So we encode each
    % channel (r,g,b) with the same basis. From line 60 to 112 we encode
    % all 3 channels with each base of the 3 channels seperately and select
    % the one base with the smallest error for our final encryption of the
    % image.
    [muRed, lamdaRed, Ured] = PCAanalyse(red);
    kRed = FindBestBasis(lamdaRed, threshold);
    
    [muGreen, lamdaGreen, Ugreen] = PCAanalyse(green);
    kGreen = FindBestBasis(lamdaGreen, threshold);
    
    [muBlue, lamdaBlue, Ublue] = PCAanalyse(blue);
    kBlue = FindBestBasis(lamdaBlue, threshold);
    
    UkRed = Ured(:,size(Ured,2)-kRed+1:size(Ured,2));
    UkGreen = Ugreen(:,size(Ugreen,2)-kGreen+1:size(Ugreen,2));
    UkBlue = Ublue(:,size(Ublue,2)-kBlue+1:size(Ublue,2));
    
    redApprox(:,:,1) = UkRed*(UkRed'*red);
    redApprox(:,:,2) = UkRed*(UkRed'*green);
    redApprox(:,:,3) = UkRed*(UkRed'*blue);
    
    greenApprox(:,:,1) = UkGreen*UkGreen'*red;
    greenApprox(:,:,2) = UkGreen*UkGreen'*green;
    greenApprox(:,:,3) = UkGreen*UkGreen'*blue;

    blueApprox(:,:,1) = UkBlue*UkBlue'*red;
    blueApprox(:,:,2) = UkBlue*UkBlue'*green;
    blueApprox(:,:,3) = UkBlue*UkBlue'*blue;
    
    Orig(:,:,1) = red; Orig(:,:,2) = green; Orig(:,:,3) = blue;
    redError = mean(mean(mean( ((Orig - redApprox) ).^2)));
    greenError = mean(mean(mean( ((Orig - greenApprox) ).^2)));
    blueError = mean(mean(mean( ((Orig - blueApprox) ).^2)));
    
    if (redError == min([redError, greenError, blueError]) );
        Uk = UkRed;
        k = kRed;
    elseif (greenError == min([redError, greenError, blueError]) )
       Uk = UkGreen;
       k = kGreen;
    else
        Uk = UkBlue;
        k = kBlue;
    end

    redComp = Uk' * red;
    greenComp = Uk' * green;
    blueComp = Uk' * blue;
    
    % the compression consits of the following: the 3 coefficient matrices
    % for the bases Uk of the r,g and b channel of the original image.% we
    % apend the selected basis last. This is all we need to reconstruct our
    % image.
    I_comp.dataRedComp = Encode(redComp, 5, 0.15);
    I_comp.dataGreenComp = Encode(greenComp, 5, 0.15);
    I_comp.dataBlueComp = Encode(blueComp, 5, 0.15);
    I_comp.dataUkTrans = Encode((Uk'), 6, 0.01);
    % configuring settings
    sizeNew = size(paddedRed);
    isColor = 1;

end

% we now initialize our settings used for decompression. They consist of
% the 6 values: 1. Width of padded image, 2. length of padded image 
% 3. the chosen patchsize for the compression 4. amount of padded rows to
% the original image, 5. amount of padded columns for the original
% a 1/0 destinction if the image is color/grayscale
settingsVec = zeros(k,1);
settingsVec(1:7,1) = [sizeNew(1); sizeNew(2); d; sizeNew(1)-sizeOrig(1); sizeNew(2)-sizeOrig(2); isColor; ndims(I) == 2];

% we now encode our data structure in a more efficent way (see Encode.m
% for a detailed explanation)

I_comp.settings = single(settingsVec);

end
