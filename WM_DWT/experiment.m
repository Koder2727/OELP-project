coverimage = imread('Barbara.bmp');
if (size(coverimage,3)>1) %Converting to gray scale in case image is rgb
    coverimage = rgb2gray(coverimage);
end
CI = coverimage;
coverimage = double(coverimage);
%watermark = imread('wm1.bmp');
watermark = imread(num2str('wm1.bmp'));
WMO = watermark;

%display the image and watermark
figure
subplot(1,2,1);
imshow(CI);
title('Cover image');
subplot(1,2,2);
imshow(watermark);
title('Watermark');


N = 1;
L = 2^N;
K = 2;
wavetype = 'bior6.8';

[Mc, Nc] = size(coverimage); 
[Mwmo, Nwmo] = size(watermark);
wmvector = reshape(watermark, Mwmo*Nwmo, 1);

%--------------embedding---------------

key = 1000;
rng(key, 'twister');
pnsequence = round(2*(rand(Mc/L, Nc/L)-0.5));

dwtmode('per')
[C1, S1] = wavedec2(coverimage, N, wavetype); 
cA1 = appcoef2(C1, S1, wavetype, N);
[cH1, cV1, cD1] = detcoef2('all', C1, S1, N);

Hist_before_DWT = cD1;
cD1 = dct2(cD1);
for i=1:length(wmvector)
    if wmvector(i) == 0
        cD1 = cD1 + K*pnsequence;
    end
    pnsequence = round(2*(rand(Mc/L, Nc/L)-0.5));
end
cD1 = idct2(cD1);
x = size (cD1, 1); 
y = size (cD1, 2); 
cAlrow = reshape (cA1, 1, x*y); cHlrow = reshape (cH1, 1, x*y); 
cV1row = reshape (cV1, 1, x*y); cD1row = reshape (cD1, 1, x*y); 
cc = [cAlrow, cHlrow, cV1row, cD1row]; 
ccl = length (cc); 
C1(1:ccl) = cc;

watermarked_image = waverec2(C1, S1, wavetype);  
watermarked_image_uint8 = uint8(watermarked_image);

imwrite(watermarked_image_uint8, 'dwt_watermarked.jpg', 'quality', 100);

%------------------------retrival------------------

watermarked_image = double(imread('dwt_watermarked.jpg'));

[Mw, Nw] = size(watermarked_image);
wmvector = ones(1, Mwmo*Nwmo);
[C2, S2] = wavedec2(watermarked_image, N, wavetype); %DWT 
cA2 = appcoef2(C2, S2, wavetype, N);
[cH2, cV2, cD2] = detcoef2('all', C2, S2, N);
% cD2 = detcoef2 ('d',C2, S2, N) ;
key=1000;
rng(key, 'twister');
correlation  = zeros(1,length(wmvector));
pnsequence = round(2*(rand (Mw/L, Nw/L)-0.5));
cD2 = dct2(cD2);
for i=1:length(wmvector)
    correlation(i) = corr2(cD2, pnsequence);
    pnsequence=round (2* (rand (Mw/L, Nw/L) -0.5));
end

T = mean(correlation);
T = 2*T; 
Tvec = T*ones(1, length(correlation));

figure (2); plot (correlation); hold on; plot(Tvec);
title('Correlation Pattern'); hold off;

for i=1:length (wmvector)
    if correlation (i)>T
        wmvector(i) = 0;
    end
end

WMR = reshape(wmvector, Mwmo, Nwmo); 
figure (3)
subplot (121)
imshow (WMO); title('Original Watermark')
subplot (122)
imshow (WMR); title ('Recovered Watermark')
figure(4)
pdfplot(Hist_before_DWT);
title('cD coefficients before addition of message');
figure(5)
pdfplot(cD1);
title('cD coefficients after addition of message ');
