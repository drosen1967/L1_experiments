
% Read in a stock image, resize it to something fairly small
% Cast to double and zero mean to drop largest coefficients
image = cast(imread('cameraman.tif'), 'double');
image = image(1:8:end,1:8:end);
image = image./max(image);
carrier = mean(image);
image = image - carrier;
level = 4;
wavelet = 'haar'; % Select a good sparsifying basis for cameraman

rows = size(image,1);
cols = size(image,2);

% There are 1024 pixels in the iamge, but only 512 measurements, so we are
% underdetermined by a factor of 2.
measurement_count = 512;

% Generate random measurements, we're doing a dot product with a random
% amplitude screen. 
measurement_images = randn(measurement_count, rows, cols);
measurements = zeros(measurement_count,1);
for i = 1:measurement_count
   measurements(i) = sum( sum( squeeze(measurement_images(i,:,:)) .* image ));
end

% Create a template image to decompose.
blank_image = zeros(size(image));
[c,s] = wavedec2(blank_image, level, wavelet);
vector_length = size(c,2);
coefficient_count = vector_length * 2; % coefficients to try to solve for

% Choose the number of coefficients to try and recover. In this case all of
% them. Record the interactions of a dot product between our measurements
% images and the basic wavelet building blocks that can be used to build
% the image. Since FISTA won't return a negative coefficient, we have to
% consider the positive and negative of each coefficient.
measurement_matrix = zeros(measurement_count, coefficient_count);
for j = 1:coefficient_count/2
   disp(j);
   c(j) = 1;
   unit_wavelet_image = waverec2(c,s,wavelet);
   for i = 1:measurement_count
      measurement_matrix(i,j*2-1) = sum( sum( squeeze(measurement_images(i,:,:)) .* unit_wavelet_image ));
      measurement_matrix(i,j*2-0) = -sum( sum( squeeze(measurement_images(i,:,:)) .* unit_wavelet_image ));
   end
   c(j) = 0;
end



%% 
% Use FISTA to recover the wavelet coefficients of our image. Compare both
% the vector representations and show the image comparison.
options  = IRfista('defaults');
options.shrink = 'on'; % Apply iterative shrinking
options.RegParam = 7e-3;% Inverse regularizer
options.IterBar = 'on';
options.MaxIter = 10000;

x_rec = IRfista(measurement_matrix,measurements, options);
x_signed = x_rec(1:2:end,:) - x_rec(2:2:end,:);
x_full = [x_signed' , zeros(1,size(c,2) - coefficient_count/2)];
X = wavedec2(image, level, wavelet);
figure();
hold on;
plot(X);
plot(x_signed);
hold off;

figure();
subplot(2,1,1);
out_image = waverec2(x_full, s, wavelet) + carrier;
imshow(out_image);
subplot(2,1,2);
imshow(image + carrier);