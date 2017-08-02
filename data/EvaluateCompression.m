% Measure approximation error and compression ratio for several images.
%
% NOTE Images must be have .jpg ending and reside in the same folder.

file_list = dir(); 
k = 1;

Errors = []; % mean squared errors for each image would be stored here
Comp_rates = []; % compression rate for each image would be stored here

for i = 3:length(dir) % runing through the folder
    
    file_name = file_list(i).name; % get current filename
    
    if(max(file_name(end-3:end) ~= '.jpg')) % check that it is an image
        continue;
    end
    
    % Read image, convert to double precision and map to [0,1] interval
    I = imread(file_name); 
    I = double(I) / 255;
    
    size_orig = whos('I'); % size of original image
    
    I_comp = Compress(I); % compress image
    I_rec = Decompress(I_comp); % decompress it
    
    % Measure approximation error
    Errors(k) = mean(mean(mean( ((I - I_rec) ).^2)));

    % Measure compression rate
    size_comp = whos('I_comp'); % size of compresseed image
    Comp_rates(k) = size_comp.bytes / size_orig.bytes; 
    
    k = k+1;
    
end

Result(1) = mean(Errors);
Result(2) = mean(Comp_rates);

disp(['Average quadratic error: ' num2str(Result(1))])
disp(['Average compression rate: ' num2str(Result(2))])