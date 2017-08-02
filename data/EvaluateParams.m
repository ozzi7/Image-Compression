function Evaluation = EvaluateParams

Evaluation = zeros(3,100);

I = imread('lena.jpg');
I = double(I)/255;

size_orig = whos('I');

for d =  10:50

   tic;
   I_comp = Compress(I,d);
   I_rec = Decompress(I_comp);

   Evaluation(1,d) = toc;

   Evaluation(2,d) = mean(mean(mean( ((I - I_rec) ).^2)));

   size_comp = whos('I_comp');
   Evaluation(3,d) = size_comp.bytes / size_orig.bytes;

   disp(d);
end

plot(Evaluation(1,:)); title('Time'); % plot the time for each d
% plot the error for each d
figure;plot(Evaluation(2,:)); title('Mean Squared Error');
% plot the compression rate for each d
figure;plot(Evaluation(3,:)); title('Compression Rate');


end

