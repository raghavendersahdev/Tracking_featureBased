tic

I = imread('C:\Users\Raghavender Sahdev\Desktop\York University\Computer Vision 5323\Assignment2\circle7.png');
I = imread('C:\Users\Raghavender Sahdev\Desktop\York University\Computer Vision 5323\Assignment2\6circles.gif');
% I = rgb2gray(I);
I_org = I;
% I = rgb2gray(I);
%% do edge detection using the canny edge detector
I_e = edge(I,'canny');
imshow(I_e);
sz = size(I);
sz1 = sz(1,1);
sz2 = sz(1,2);

%% store all the edges as a set of points
cnt = 1;
for i=1:sz1
    for j=1:sz2
        if(I_e(i,j) == 1)
            Points(cnt,1) = i;
            Points(cnt,2) = j;
            cnt = cnt + 1;
        end
    end
end

%% chosse 3 randomly and compute the N circles fitting them, compute the center and radius of the circles
N=200;
centers = zeros(N,2);
radius = zeros(N,1);


%% checking how many points lie in the generated 100 circles
len = cnt-1;
w = 5;
num_points = zeros(N,1);
num_circles = 5;
Circles = zeros(num_circles,3);
I_circles = I_org;
remove_threshold = 10; % while removing points after exact circle fitting
len2 = len;

Points2 = Points;
for k=1:num_circles
    
    zero_pts = 0;
    
    for i=1:N
        sum_points = 0;  
        
        % chosse 3 randomly and compute the N circles fitting them, compute the center and radius of the circles
       
        P = datasample(Points2,3);        
        [centers(i,:),radius(i,1)] = generateCircle(P(1,:),P(2,:),P(3,:));
        len2 = size(Points2);
        len2 = len2(1,1);
        for j=1:len2-1
            
            if((len2) > j)
                flag = (checkIfIn(Points2(j,:),centers(i,:),radius(i,1),w) == 1);   
                if(flag == 1)
                    sum_points = sum_points+1;
                end
            end
        end
        num_points(i,1) = sum_points;
    end
    
    [value idx] = max(num_points);
    I_circles = insertShape(I_circles, 'circle', [centers(idx,2) centers(idx,1) radius(idx,1)],'Color','blue');
    I_circles = insertText(I_circles,[centers(idx,2) centers(idx,1)], 'CIRCLE');
    figure, imshow(I_circles);
    size(Points2)


%   following code removes the detected circle
    len2 = size(Points2);
    len2 = len2(1,1);
    for i=1:len2
       
        flag2 = checkIfIn(Points2(i,:),centers(idx,:),radius(idx,1),w);
        if(flag2 == 1)
            Points2(i,:) = [0 0];            
            flag2 = 0;
        end        
    end
    
    bnt = 1;    
    for i=1:len2
        if(Points2(i,1) ~=0 && Points2(i,2) ~=0)
            Points2(bnt,:) = Points2(i,:);
            bnt = bnt+1;
        end
    end
    for i=bnt:len2
        if(k == num_circles)
            break;
        end
        Points2 = removerows(Points2,(bnt));
    end

end
toc
figure,imshow(I_circles);
