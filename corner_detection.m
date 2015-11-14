I = imread('C:\Users\Raghavender Sahdev\Desktop\York University\Computer Vision 5323\Assignment2\room3.jpg');
I = rgb2gray(I);
size_xy = size(I);
size_x = size_xy(1,1);
size_y = size_xy(1,2);
% I = imresize(I,[resize_x resize_y]);

%% create a filter to compute the gradient of the image in x and y direction
dx = [-1 0 1 ; -1 0 1 ; -1 0 1];
dy = [-1 -1 -1 ; 0 0 0 ; 1 1 1];

Ix = conv2(I,dx,'same');
Iy = conv2(I,dy,'same');

%% create the gaussian filter
hsize = 3;
sigma = 0.5;
gauss = fspecial('gaussian', hsize, sigma);

%% convolving the square of the first derivative with the gaussian
Ix2 = conv2(Ix.^2, gauss,'same');  
Iy2 = conv2(Iy.^2, gauss,'same');
Ixy = conv2(Ix.*Iy, gauss,'same');

%% computing the minimum eigen value
tic
M = zeros(4,size_x,size_y);
M(1,:,:) = Ix2;
M(2,:,:) = Ixy;
M(3,:,:) = Ixy;
M(4,:,:) = Iy2;
e = zeros(2,size_x,size_y);
dnt = 1;
for i=1:size_x
    for j=1:size_y
        matrix = [M(1,i,j) M(2,i,j); M(3,i,j) M(4,i,j)];   
        e(:,i,j) = eig(matrix);
        dnt = dnt + 1;
    end
end
e2 = min(e);

e3 = e2(1,:,:);
threshold2 = 800;

output_plot = zeros(size_x,size_y);
for i=1:size_x
    for j=1:size_y
        if(e2(1,i,j)>threshold2)
            output_plot(i,j) = 1;            
        end
    end
end
[x_corner,y_corner] = find(output_plot);
figure,imshow(I), hold on, plot(y_corner,x_corner,'+','Color','yellow');

toc
det_M = Ix2.*Iy2 - Ixy.^2;
trace_M = (Ix2 + Iy2);
R = det_M ./trace_M;

% citation Brown, Szeliski, andWinder (2005) paper use the harmonic mean: source Richard Szeliski book chapter 4
%% do non maximal supression on R and store the computed coordinates as the corners

hsize = 3;
threshold = 900;

Filtered = ordfilt2(R,hsize^2,ones(hsize));  % dilate to retain the local maxima
R =  R>threshold & (R==Filtered) ;

% something really cool happens here we check if after dilation the values are equal to 
%the original values and only retain the values which are equal, this retains the local maxima

[x,y] = find(R);
figure,imshow(I), hold on, plot(y,x,'+'); 
hold off

%% mappping the corners/feature points in the second image from the first one


I2 = imread('C:\Users\Raghavender Sahdev\Desktop\York University\Computer Vision 5323\Assignment2\room4.jpg');
I2 = rgb2gray(I2);


num_corners = numel(x);
w=2;
temp = 57;

p=5;
x2 = 0;
y2 = 0;
for k=1:num_corners
    SSD = 0;
    for i=-w:w
        for j=-w:w

            ssd = 0;
            temp1 = x(k);
            temp2 = y(k);
            
            px_corr = 15;
            if(temp1 <=px_corr || temp2<=px_corr || temp1>=size_x-px_corr || temp2>=size_y-px_corr)
                SSD(i+3,j+3) = 9999;
                break
            end
            mask1 = I(temp1-p:temp1+p,temp2-p:temp2+p);
            mask2 = I2(temp1-p+i:temp1+p+i,temp2-p+j:temp2+p+j);
            dif_mask = mask2-mask1;
            dif_mask = dif_mask.^2;    
            SSD(i+3,j+3) = sum(sum(dif_mask));
        end
    end
    [t1 it1] = min(SSD);
    [t2 it2] = min(t1);
    
    [t3 it3] = min(SSD,[],2);
    [t4 it4] = min(t3);
    
    x2(k) = x(k) + it4 -3;
    y2(k) = y(k) + it2 -3;
    
end
figure, imshow(I);
imshow(I2),hold on, plot(y2,x2,'+','Color','red'),hold off






