%reading coverimage from the 
coverimage = imread('Lena.bmp');
CI = coverimage;
coverimage = double(coverimage);
%watermark = imread('wm1.bmp');
watermark = imread(num2str('wm1.bmp'));
WMO = watermark;

figure
subplot(1,2,1);
imshow(CI);
title('Cover image');
subplot(1,2,2);
imshow(watermark);
title('Watermark');

%dwt parameters
N = 1;
L = 2^N;
K = 2;

%dwt different types of dwt
wavetype = 'bior6.8';

%matching the size of image and watermark
[Mc, Nc] = size(coverimage); 
[Mwmo, Nwmo] = size(watermark);


wmvector = reshape(watermark, Mwmo*Nwmo, 1);

%--------------embedding---------------

%generating the pseudo random sequence
key = 1000;
rng(key, 'twister');

%random
pnsequence = round(2*(rand(Mc/L, Nc/L)-0.5));

%dwtmode
dwtmode('per')


[C1, S1] = wavedec2(coverimage, N, wavetype); 

%approxiamte coefficients
cA1 = appcoef2(C1, S1, wavetype, N);

%deecomposing the image
[cH1, cV1, cD1] = detcoef2('all', C1, S1, N);

%avoid watermark in horizontal as lot of data is present
for i=1:length(wmvector)
    if wmvector(i) == 0
        cD1 = cD1 + K*pnsequence;
    end
    pnsequence = round(2*(rand(Mc/L, Nc/L)-0.5));
end

x = size (cA1, 1); 
y = size (cA1, 2); 
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
cD2 = detcoef2 ('d',C2, S2, N) ;
key=1000;
rng(key, 'twister');

pnsequence = round(2*(rand (Mw/L, Nw/L)-0.5));
for i=1:length(wmvector)
    correlation(i) = corr2(cD2, pnsequence);
    pnsequence=round (2* (rand (Mw/L, Nw/L) -0.5));
end

T = mean(correlation); T = 1.5*T; 
Tvec = T*ones(1, length(correlation));

figure (2); plot (correlation); hold on; plot(Tvec);
title('Correlation Pattern'); hold off;

for i=1:length (wmvector)
    if correlation (i)>T
    end
end

WMR = reshape(wmvector, Mwmo, Nwmo); 
figure (3)
subplot (121)
imshow (WMO); title('Original Watermark')
subplot (122)
imshow (WMR); title ('Recovered Watermark')
