% atrium.avi
tic
video = VideoReader('atrium.avi');
nFrames = video.NumberOfFrames;
vidHeight = video.Height;
vidWidth = video.Width;

mov(1:nFrames) = struct('cdata', zeros(vidHeight,vidWidth, 3, 'uint8'),'colormap',[]);
parfor k = 1 : nFrames
    mov(k).cdata = read(video,k);
end

hf = figure;
set(hf,'position',[150 150 vidWidth vidHeight])

rgb_mov = mov;
temp_mov = mov;
%%
I = zeros(vidHeight, vidWidth, nFrames);
I2 = zeros(vidHeight, vidWidth, nFrames);
toc
bbox = [2 2 vidWidth-10 vidHeight-10];

for i=1:nFrames
    mov(i).cdata = rgb2gray(mov(i).cdata);
end

parfor i=1:nFrames
%     mov(i).cdata = rgb2gray(mov(i).cdata);
    if i==1
        continue;
    end    
    temp_mov(i).cdata = mov(i).cdata - mov(i-1).cdata;
        
    temp_img = temp_mov(i).cdata;
    points = detectMinEigenFeatures(temp_img,'MinQuality',0.1,'ROI',bbox);
    pointsImage = insertMarker(temp_img,points.Location,'+','Color','white');
    pointsImage = rgb2gray(pointsImage);
    I2(:,:,i) = pointsImage;
     I(:,:,i) = im2bw(temp_mov(i).cdata,0.08);
end
toc
for i=1:nFrames
    temp = I(:,:,i);
    se1 = strel('disk',1);
    
    temp = imerode(temp,se1);
    I(:,:,i) = temp;
end


% 
% implay

%% extract object regions

%% segment out the moving object based on Background subtraction
% b3 = current frame
% se = strel('disk',1);
% b3 = imerode(b2,se);



%% % use the matlab function points = detectMinEigenFeatures(rgb2gray(objectFrame), 'ROI', objectRegion/bbox);
% to extract the features from each of the moving part and then match them
% based on the feature vector in the next frame



% temp = (temp_mov(32).cdata > 0);
% find()
% for i=1:nFrames
%     a = temp_mov(i).cdata;
%     a>0
% end
% 
% movie(hf,temp_mov,1,video.FrameRate);




