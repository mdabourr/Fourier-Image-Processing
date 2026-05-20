```matlab
% 2D FFT -- low and high frequency filter
% WHY: This script separates an image into low-frequency (smooth parts)
% and high-frequency (edges/details) using Fourier Transform

clc;        % WHY: clears command window (removes old outputs)
close all;  % WHY: closes all previous figures to avoid confusion
clear;      % WHY: removes all variables to start fresh execution

%********************

img = imread('kid.png');   
% WHY: load image from file into MATLAB matrix (input data for processing)

radius = 40;
% WHY: defines cutoff threshold for frequency filter
% smaller radius = more blur, larger radius = sharper image

img = rgb2gray(img);  
% WHY: convert RGB image (3 channels) into grayscale (1 matrix only)
% simplifies FFT processing and reduces complexity

figure, imshow(img)  
% WHY: display original image to verify input before processing

%********************

ft2 = fft2(img);  
% WHY: convert image from spatial domain (pixels) → frequency domain
% each value now represents frequency content, not pixel intensity

ft = fftshift(ft2);       
% WHY: shift zero-frequency (low frequency) to the center
% default FFT places low frequencies at corners (hard to filter visually)
% shifting makes circular filtering possible

%********************

Fmag = log(1 + abs(ft2));  
% WHY: compute magnitude spectrum for visualization only
% abs(ft2) = strength of frequencies
% log compresses large values so image becomes visible

fftshiftmag = fftshift(Fmag);  
% WHY: shift magnitude spectrum so low frequencies appear in center
% makes frequency distribution easier to interpret

figure('Name','Magnitude Fourier'); 
imshow(Fmag, []);  
% WHY: show raw frequency magnitude (before shifting)

figure('Name','Fourier frequency shift'); 
imshow(fftshiftmag, []);  
% WHY: show centered frequency view (better human understanding)

%******************
%                     Mask Creation (The Filter)
[row, col] = size(ft);
% WHY: get dimensions of frequency matrix (needed to build filter mask)

rm = floor(row/2);
clm = floor(col/2);
% WHY: find center of frequency image (after fftshift)

[x, y] = meshgrid(-clm:clm-1, -rm:rm-1);
% WHY: create coordinate grid centered at (0,0)
% needed to compute distance from center for circular filter

z = sqrt(x.^2 + y.^2);
% WHY: compute Euclidean distance of each point from center
% this defines circular frequency regions

cL = z < 40;
% WHY: LOW-PASS FILTER mask
% keeps frequencies inside circle (smooth parts of image)
% removes high frequencies (edges/noise)

cH = ~cL;
% WHY: HIGH-PASS FILTER mask (inverse of low-pass)
% keeps edges/details only

%******************

cL = z < radius;   
% WHY: same low-pass filter but using variable radius
% (this overwrites previous cL line → redundant but not harmful)

%cH = ~cL;    
% WHY: recompute high-pass mask based on updated low-pass

%******************

l_ft = ft .* cL;  
% WHY: apply low-pass filter in frequency domain
% multiplication keeps low frequencies, removes others

h_ft = ft .* cH;  
% WHY: apply high-pass filter in frequency domain
% keeps edges/high frequencies only

%******************

low_filtered_image = ifft2(ifftshift(l_ft));  
% WHY: convert filtered signal back to spatial domain
% ifftshift → undo centering
% ifft2 → inverse FFT back to image

high_filtered_image = ifft2(ifftshift(h_ft));  
% WHY: same process for high-frequency image reconstruction

%******************

low_f = uint8((low_filtered_image));  
% WHY: convert result into 8-bit image format for display
% (but better practice: use uint8(real(...)))

high_f = uint8((high_filtered_image));  
% WHY: same conversion for high-frequency image

%******************

figure, imshow(low_f)  
% WHY: display low-frequency (blurred) image result

subplot(2, 2, 1); imshow(cL, []); 
title('Low-frequency filter'); axis on;
% WHY: visualize low-pass mask to confirm circular region

subplot(2, 2, 2); imshow(cH, []); 
title('High-frequency filter'); axis on;
% WHY: visualize high-pass mask (inverse region)

subplot(2, 2, 3); imshow(low_f , []); 
% WHY: show reconstructed low-frequency image

title('Low-frequency-image'); axis on;

subplot(2, 2, 4); imshow(high_f, []); 
% WHY: show reconstructed high-frequency image (edges)

title('High-frequency-image'); axis on;
