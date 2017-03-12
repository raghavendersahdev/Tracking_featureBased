tic
srcFiles = dir('/home/sahdev/Desktop/Fall2015/ComputerVision5323/project_ideas/TrackingDataset/PROST/box/*.jpg');  % the folder in which ur images exists
n = length(srcFiles);
labels = cell(n,1);

parfor i = 1 : n
    filename = strcat('/home/sahdev/Desktop/Fall2015/ComputerVision5323/project_ideas/TrackingDataset/PROST/box/',srcFiles(i).name);
    labels{i} = cellstr(filename);
end
toc
I = imread(char(labels{1}));
sz = size(I);
sz_x = sz(1,1);
sz_y = sz(1,2);

frames = uint8(zeros(sz_x,sz_y,n));
parfor i=1:n
    frame_i = imread(char(labels{i}));
    frame_i = rgb2gray(frame_i);
    frames(:,:,i) = frame_i;
    
end
toc

%%
strt2 = 2;
end2 = 10
for i=strt2:end2
    temp1 = frames(:,:,i) - frames(:,:,i-1);
    temp1_i = frames(:,:,i);
    temp2_i = frames(:,:,i+1);
    
%     pts = detectHarrisFeatures(temp1);
    pts = getCorners(temp1);
    y = floor(pts(:,1));  % this is y
    x = floor(pts(:,2));  % this is x
    n2 = numel(x);
    Features1 = zeros(n2,2);
    Features1(:,1) = y;
    Features1(:,2) = x;
    
    temp2 = frames(:,:,i+1) - frames(:,:,i);
%     pts2 = detectHarrisFeatures(temp2);
    pts2 = getCorners(temp2);
    y2 = floor(pts2(:,1));  % this is y
    x2 = floor(pts2(:,2));  % this is x
    n3 = numel(x2);
    Features2 = zeros(n3,2);
    Features2(:,1) = y2;
    Features2(:,2) = x2;  
    
%     figure, imshow(frames(:,:,i)), hold on, plot(y,x,'+','Color','yellow'),hold off    
       % sample feature points randomly to track them
    if i == strt2
        P = datasample(Features1,1);
        
    end
    %% feature matching based on computing minimum euclidean distance between the detected feaure points
%     distances = pdist2(P,Features2);    
%     [dist, matched_index] = min(distances);    
%     target_point = Features2(matched_index,:);
%     P = target_point;
    
    %% build a convex hull from the features detected in the first 2 frames i and (i-1)
    k = convhull(Features1(:,1),Features1(:,2));
    bounds = zeros(numel(k),2);
    for j=1:numel(k)
        bounds(j,1) = Features1(k(j),1);
        bounds(j,2) = Features1(k(j),2);
    end
    
    %% feature matching based on computing minimum euclidean distance between the detected feaure points
    matched_points = zeros(0,2);
    % following for loops matches each of the points on the convex hull
    % generated from frames i and (i-1) and matched it to the feature
    % points generated from frames (i+1) and i, so after execution of this
    % loop we have points matched in from frames i,(i-1) to that of frames
    % (i+1),i;; here we use this approach and not the SSD method to match
    % the corners as the SSD Method would be computationally expensive
    for j=1:numel(k)
        P_temp = [bounds(j,1) bounds(j,2)];
        
        distances = pdist2(P_temp,Features2);
        [dist, matched_index] = min(distances);    
        temp_target_point = Features2(matched_index,:);
    
        matched_points(j,:) = temp_target_point;
    end
    
    
    %% feature matching based on SSD measure
    % here we use another method to match the corners based on SSD we do
    % not detect the corners a second time in this approach, we dont use
    % Features2 here
    P_t1 = getCorners(temp1);
%     P_t2 = getCorners(temp2);
    for j=1:numel(P_t1)/2
        P_Matched(j,:) = matchCorners(temp1_i,temp2_i,P_t1(j,:));       
    end
    
    k2 = convhull(P_Matched(:,1),P_Matched(:,2));
    bounds2 = zeros(numel(k2),2);
    for j=1:numel(k2)
        bounds2(j,1) = P_Matched(k2(j),1);
        bounds2(j,2) = P_Matched(k2(j),2);
    end
    figure, imshow(frames(:,:,i+1)), hold on, plot(y,x,'+','Color','red'), plot(bounds2(:,2),bounds2(:,1),'Color','cyan'),hold off
        
    figure, imshow(frames(:,:,i+1)), hold on, plot(y2,x2,'+','Color','yellow'), plot(matched_points(:,1),matched_points(:,2),'Color','red'),hold off
    
    
%     figure, imshow(frames(:,:,i+1)), hold on, plot(target_point(1,1),target_point(1,2),'+','Color','red'),hold off
%     figure, imshow(temp2);% hold on, plot(y,x,'+','Color','yellow'),hold off    
%     
    
end

