function TestCompression( file )
%this simple script was written to quickly test the compression of a file.
%It then also displays the error and compression rate. 

I = imread(file);
I = double(I)/255;
tic;
Icomp = Compress(I);
Irec = Decompress(Icomp);
time = toc
error = mean(mean(mean( ((I - Irec) ).^2)))

size_orig = whos('I');
size_comp = whos('Icomp');

compressionRate = size_comp.bytes / size_orig.bytes

figure;
imshow(I);
figure;
imshow(Irec);

end

