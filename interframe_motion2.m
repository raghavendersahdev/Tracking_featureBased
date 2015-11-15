tic
video = VideoReader('atrium.avi');
nFrames = video.NumberOfFrames;
vidHeight = video.Height;
vidWidth = video.Width;

mov(1:nFrames) = struct('cdata', zeros(vidHeight,vidWidth, 3, 'uint8'),'colormap',[]);
parfor k = 1 : nFrames
    mov(k).cdata = read(video,k);
    mov(k).cdata = rgb2gray(mov(k).cdata);
end
toc
a1 = mov(458).cdata;


a2 = mov(459).cdata;

bbox = [2 2 350 630];

pts = detectHarrisFeatures(a1);
y2 = pts.Location(:,1);
x2 = pts.Location(:,2);

imshow(a1),hold on, plot(y2,x2,'+','Color','red'),hold off

a3 = a2-a1;
pts = detectHarrisFeatures(a3);
y3 = pts.Location(:,1);
x3 = pts.Location(:,2);

figure, imshow(a3),hold on, plot(y3,x3,'+','Color','yellow'), hold off

I = zeros(vidHeight,vidWidth,3,nFrames);
temp2 =3;
%% 
P=6;
strt2 = 400;
end_it = 410;
occlusion_threshold = 90;
for i=strt2:end_it
    temp1 = mov(i).cdata - mov(i-2).cdata;
    
    
    pts = detectHarrisFeatures(temp1);
    y = floor(pts.Location(:,1));  % this is y
    x = floor(pts.Location(:,2));  % this is x
    n = numel(x);
    Features1 = zeros(n,2);
    Features1(:,1) = y;
    Features1(:,2) = x;
    
    temp2 = mov(i+2).cdata - mov(i).cdata;
    pts2 = detectHarrisFeatures(temp2);
    y2 = floor(pts2.Location(:,1));  % this is y
    x2 = floor(pts2.Location(:,2));  % this is x
    n2 = numel(x2);
    Features2 = zeros(n2,2);
    Features2(:,1) = y2;
    Features2(:,2) = x2;  
    
    figure, imshow(mov(i).cdata), hold on, plot(y,x,'+','Color','yellow'),hold off    
    figure, imshow(mov(i).cdata), hold on, plot(y,x,'+','Color','yellow'),hold off    
    
    % sample feature points randomly to track them
    if i == strt2
        P = datasample(Features1,1);
        
    end
    distances = pdist2(P,Features2);    
    [dist, matched_index] = min(distances);    
    target_point = Features2(matched_index,:);
    
   
    figure, imshow(mov(i+1).cdata), hold on, plot(target_point(1,1),target_point(1,2),'+','Color','red'),hold off
    figure, imshow(temp1), hold on, plot(y,x,'+','Color','yellow'),hold off    
    
        
%     %case1
%     w=3;
%     P1 = [px(1) py(1)];
%     mask1 = temp2(px(1)-w:px(1)+w, py(1)-w:py(1)+w);
    
    
    figure, imshow(mov(i+1).cdata), hold on, plot(y,x,'+','Color','yellow'),hold off
    
end

toc
