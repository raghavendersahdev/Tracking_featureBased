
function P = getCorners(I)
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


    %% computing Harris Features
   
    det_M = Ix2.*Iy2 - Ixy.^2;
    trace_M = (Ix2 + Iy2);
    R = det_M ./trace_M;


    % citation Brown, Szeliski, andWinder (2005) paper use the harmonic mean: source Richard Szeliski book chapter 4
    %% do non maximal supression on R and store the computed coordinates as the corners
    hsize = 3;
    threshold = 2000;
    Filtered = ordfilt2(R,hsize^2,ones(hsize)); % dilate to retain the local maxima
    R = R>threshold & (R==Filtered) ;
    % something really cool happens here we check if after dilation the values are equal to
    %the original values and only retain the values which are equal, this retains the local maxima
    [x,y] = find(R);
%     figure,imshow(I), hold on, plot(y,x,'+');
    hold off
    P = [y x];
end

