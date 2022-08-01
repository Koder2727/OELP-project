x = double(imread('onion.png'))
%figure,imshow(x/255);
y = x
a = zeros(135,198);
a(70:100,100:150) = 1;
figure,imshow(a)

save m.dat a -ascii

%watermarking

x1 = x(:,:,1);
x2 = x(:,:,2);
x3 = x(:,:,3);

dx1 = dct2(x1);dx11 = dx1;
dx2 = dct2(x2);dx22 = dx2;
dx3 = dct2(x3);dx33 = dx3;

load m.dat

g = 100
figure,imshow(dx1);
[rm,cm] = size(m);

for i = 1:rm
    for j = 1:cm
        dx1(i,j) = dx1(i,j) + dx1(i,j)*0.1*m(i,j);
    end
end

for i = 1:rm
    for j = 1:cm
        dx2(i,j) = dx2(i,j) + dx2(i,j)*0.1*m(i,j);
    end
end

for i = 1:rm
    for j = 1:cm
        dx3(i,j) = dx3(i,j) + dx3(i,j)*0.1*m(i,j);
    end
end
%{
dx1(1:rm,1:cm) = dx1(1:rm,1:cm) + g*m;
dx2(1:rm,1:cm) = dx2(1:rm,1:cm) + g*m;
dx3(1:rm,1:cm) = dx3(1:rm,1:cm) + g*m;
%}
figure,imshow(dx1);
%figure,imshow(dx2);
%figure,imshow(dx3);

y1 = idct2(dx1)
y2 = idct2(dx2)
y3 = idct2(dx3)

y(:,:,1) = y1
y(:,:,2) = y2
y(:,:,3) = y3

%compressing the image
imwrite(y/255 , 'x.jpg')
compressed = double(imread('x.jpg'))
%figure,imshow(y1)
%figure,imshow(y2)
%figure,imshow(y3)
%figure,imshow(y)
figure,imshow(y/255)

figure,imshow(compressed)

%finding the difference between the two images
figure,imshow((y-compressed)/255)
figure,imshow((y-x)/255)

%remocing the known maskz
z = y
dy1 = dct2(y(:,:,1))
dy2 = dct2(y(:,:,2))
dy3 = dct2(y(:,:,3))

dy1(1:rm,1:cm) = dy1(1:rm , 1:cm) - g*m
dy2(1:rm,1:cm) = dy2(1:rm , 1:cm) - g*m
dy3(1:rm,1:cm) = dy3(1:rm , 1:cm) - g*m

y11 = idct2(dy1)
y22 = idct2(dy2)
y33 = idct2(dy3)

z(:,:,1) = y11
z(:,:,2) = y22
z(:,:,3) = y33

figure,imshow(z/255)